# Flutter Performance Audit & Remediation Plan

Platforms: Android, iOS
Stack: Flutter + Firebase (Auth, Firestore, Storage)

## Executive Summary

Top issues and expected impact:

- P0
  - Eager Firestore load at startup in `lib/main.dart` (~150–400ms faster first frame; fewer jank risks).
  - Stream re-subscription churn in `ProfilePage` followed-stores list (reduces extra Firestore listeners; smoother rebuilds).
  - Non-cached images in lists (switch to cached providers; lowers bandwidth, decode jank, scroll hitching).

- P1
  - Categories `Future` recreated on every `HomePage` build (eliminates duplicate queries and spinner flashes).
  - `FollowController.watchIsFollowing()` lacks per-store cleanup (prevents steady memory growth over long sessions).
  - Heavy list item repaints (add `RepaintBoundary` to isolate paints; reduce overdraw).

- P2
  - Shimmer-heavy skeletons and large gradients (lighter placeholders improve frame budget on low-end devices).
  - Release build size not optimized (enable R8, shrinkResources, split-per-ABI, tree-shake icons, split-debug-info).
  - Asset redundancy in `pubspec.yaml` (minor size/clarity improvement).

All changes are modular and keep current UX/features intact.

---

## Findings and Fixes

### P0. Startup trims

- Symptom
  - Eager Firestore work at app start: `lib/main.dart:36–38`
    - `ChangeNotifierProvider(create: (_) => CartController()..loadCartsFromFirestore(),)`
  - Performs network/IO before first frame, risking slower TTI and frame jank.

- Root Cause
  - Work scheduled during provider creation in `main.dart` instead of after the first frame.

- Fix (code-ready)
  - Defer the load to a post-frame callback (or the first screen that needs it):
  ```dart
  // lib/main.dart
  ChangeNotifierProvider(
    create: (_) => CartController(), // remove eager load here
  );
  ```
  Then trigger later (e.g., in your first visible Stateful widget):
  ```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartController>().loadCartsFromFirestore();
    });
  }
  ```

- Verification
  - DevTools Performance: record startup; compare first frame time and stutters.
  - `flutter run --profile`: compare logs and frame chart.

- Risk & Rollback
  - Low. Roll back by restoring the eager call if needed.

---

### P0. Stream churn in followed stores list

- Symptom
  - `ProfilePage` builds a new stream each rebuild: `lib/Home/pages/profile_page.dart:366–368`
    - `stream: followCtrl.getFollowingPage(limit: 20),`
  - Causes re-subscriptions, extra Firestore listeners, and redundant updates during rebuilds.

- Root Cause
  - Creating stream inside `build()`; not stabilizing the reference across rebuilds.

- Fix (code-ready)
  - Hoist the stream to state so it’s created once per page lifecycle:
  ```dart
  // Inside _ProfilePageState
  Stream<List<StoreSummary>>? _followingStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctrl = Provider.of<FollowController?>(context, listen: false);
    if (ctrl != null && _followingStream == null) {
      _followingStream = ctrl.getFollowingPage(limit: 20);
    }
  }

  // Then in build:
  StreamBuilder<List<StoreSummary>>(
    stream: _followingStream,
    ...
  )
  ```

- Verification
  - Firestore emulator logs/DevTools network: fewer re-listens when navigating or causing rebuilds.
  - DevTools frame chart: fewer rebuild-related spikes when switching tabs.

- Risk & Rollback
  - Low. Revert to inline stream in `build()` if needed.

---

### P0. Use cached image providers in lists

- Symptom
  - Inline images use `NetworkImage` in lists, e.g. `lib/Home/pages/profile_page.dart:409–412`.
  - Increases repeated downloads and image decode cost during scroll.

- Root Cause
  - `NetworkImage` lacks disk caching and targeted decode sizing.

- Fix (code-ready)
  - Replace with `CachedNetworkImageProvider` or `CachedNetworkImage` (already in `pubspec.yaml`).
  ```dart
  // Before
  foregroundImage: s.logoUrl != null && s.logoUrl!.isNotEmpty
      ? NetworkImage(s.logoUrl!)
      : null,

  // After
  import 'package:cached_network_image/cached_network_image.dart';

  foregroundImage: (s.logoUrl?.isNotEmpty ?? false)
      ? CachedNetworkImageProvider(s.logoUrl!)
      : null,
  ```
  - For card/grids, prefer the widget with size hints to reduce decode jank:
  ```dart
  CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    memCacheWidth: 400,  // tune to expected display size
    memCacheHeight: 400,
    maxWidthDiskCache: 800,
    maxHeightDiskCache: 800,
    placeholder: (_, __) => const ColoredBox(color: Colors.black12),
    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
  )
  ```
  - Standardize across list-heavy widgets flagged by grep:
    - `lib/Home/widgets/big_store_card.dart`
    - `lib/Home/widgets/big_store_card_enhanced.dart`
    - `lib/Home/widgets/store_card.dart`
    - `lib/store/widgets/product_grid_card.dart`
    - `lib/store/widgets/featured_product_card.dart`

- Verification
  - Fewer network fetches on revisits; smoother scroll (DevTools frame chart).

- Risk & Rollback
  - Low; revert to `NetworkImage` if any regressions.

- Follow-up (server-side)
  - Set appropriate Cache-Control metadata on Firebase Storage objects for better cache hits.

---

### P1. Categories `Future` recreated each `HomePage` build

- Symptom
  - `HomePage` (stateless) calls `CategoryService().fetchActiveCategories()` in `build()`: `lib/Home/pages/home_page_new.dart:96–101`.
  - Rebuilds recreate the `Future`, causing repeated queries and UI spinners.

- Root Cause
  - Non-memoized `Future` in a `StatelessWidget`.

- Fix (code-ready)
  - Convert to `StatefulWidget` and hoist the `Future`:
  ```dart
  class HomePage extends StatefulWidget {
    const HomePage({super.key});
    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    late final Future<List<Category>> _categoriesFuture =
        CategoryService().fetchActiveCategories();

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        // ... existing builder
      );
    }
  }
  ```

- Verification
  - DevTools network: single fetch; no repeated requests when switching tabs.

- Risk & Rollback
  - Low; revert to stateless if desired.

---

### P1. `FollowController.watchIsFollowing()` cleanup to prevent leaks

- Symptom
  - Per-store stream, subscription, and cache are kept in maps without lifecycle cleanup: `lib/follow/presentation/controllers/follow_controller.dart`.
  - Visiting many stores over a session may increase retained memory.

- Root Cause
  - Broadcast controller without `onCancel` cleanup.

- Fix (code-ready)
  - Add `onCancel` to close and remove per-store resources:
  ```dart
  Stream<bool> watchIsFollowing(String storeId) {
    if (_controllers.containsKey(storeId)) return _controllers[storeId]!.stream;

    late final StreamSubscription<bool> sub;
    final ctrl = StreamController<bool>.broadcast(
      onCancel: () {
        sub.cancel();
        _subs.remove(storeId);
        _controllers.remove(storeId)?.close();
        _lastFollowing.remove(storeId);
      },
    );
    _controllers[storeId] = ctrl;

    final cached = _lastFollowing[storeId];
    if (cached != null) ctrl.add(cached);

    sub = _isFollowing(uid: _uid, storeId: storeId).listen((value) {
      _lastFollowing[storeId] = value;
      ctrl.add(value);
    }, onError: (e, st) {
      lastError = e.toString();
      notifyListeners();
    });
    _subs[storeId] = sub;

    return ctrl.stream;
  }
  ```

- Verification
  - DevTools Memory: stable heap after navigating across many stores; no steady growth of controllers/subscriptions.

- Risk & Rollback
  - Low; revert to prior method if needed.

---

### P1. List virtualization and paint isolation

- Symptom
  - Complex cards (store/product) can trigger large repaints during scroll.

- Root Cause
  - Missing `RepaintBoundary` around heavy tiles; some sections may use non-builder lists.

- Fix (code-ready)
  - Ensure list/grid sections use builder constructors (`ListView.builder`, `GridView.builder`).
  - Wrap heavy items:
  ```dart
  RepaintBoundary(
    child: StoreCard(...),
  )
  ```
  - Keep `cacheExtent` reasonable (3–4 screens) to avoid excessive off-screen decoding.

- Verification
  - DevTools frame/raster time improves during rapid scroll.

- Risk & Rollback
  - Low; easy to revert.

---

### P2. Shimmer and gradients

- Symptom
  - Large shimmer skeletons on `ProfilePage` (`lib/Home/pages/profile_page.dart:170–226`) and full-page gradients.

- Root Cause
  - Animated effects and overdraw increase raster cost on low-end devices.

- Fix (code-ready)
  - Replace large-area shimmer with static placeholders; keep shimmer for small components.
  - Reduce gradient layers/scope where not visible.

- Verification
  - Fewer missed frames in DevTools on older devices.

- Risk & Rollback
  - Low.

---

### P2. Build size optimization

- Symptom
  - Android release config does not enable minification/resource shrinking: `android/app/build.gradle.kts:36–41`.

- Root Cause
  - Default release settings.

- Fix (Android)
  - Enable R8 and resource shrinking and use tree-shake icons:
  ```kotlin
  android {
    buildTypes {
      release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
          getDefaultProguardFile("proguard-android-optimize.txt"),
          "proguard-rules.pro"
        )
        // TODO: set real signingConfig for release
      }
    }
  }
  ```
  - Build with:
    - `flutter build apk --release --split-per-abi --tree-shake-icons`
    - `flutter build appbundle --release --tree-shake-icons`

- Fix (Flutter)
  - Split debug info and obfuscate for smaller symbols:
    - `flutter build <apk|appbundle> --split-debug-info=build/symbols --obfuscate --tree-shake-icons`

- Fix (iOS)
  - In Xcode Release config: Dead Code Stripping = Yes; Swift Optimization = `-Osize`; Strip Symbols = Yes.

- Verification
  - `flutter build apk --analyze-size` before/after. Track download/install size.

- Risk & Rollback
  - Medium: minify can break reflection-heavy code. Keep a known-good `proguard-rules.pro` and test thoroughly.

---

### P2. Asset pruning

- Symptom
  - `pubspec.yaml` duplicates app icon path: `assets/app_icon/` and `assets/app_icon/icon.png`.

- Root Cause
  - Redundant declaration; minor but cleaner to avoid duplication.

- Fix (code-ready)
  - Keep only the folder include:
  ```yaml
  assets:
    - assets/images/
    - assets/app_icon/
  ```

- Verification
  - Clean build; asset logs clearer; marginal size savings.

- Risk & Rollback
  - Low.

---

## Measurement & Tooling

- DevTools
  - Performance: record startup and scroll interactions; inspect frame budget and shader compilation.
  - CPU Profiler: find unexpected work on UI isolate.
  - Memory: watch heap/retained sizes while navigating between many stores.

- Commands
  - `flutter run --profile`
  - `flutter build apk --analyze-size`
  - Optional SkSL warm-up flow: `flutter run --profile --cache-sksl` to capture shaders.

- Android
  - Profile HWUI rendering in Developer Options; inspect bars for jank.
  - `adb shell dumpsys gfxinfo <package>` for frame stats.

- iOS
  - Instruments: Time Profiler + Core Animation to spot layout/paint hotspots.

- Firestore
  - Emulator + logs: count listeners/queries before/after stream stabilization.
  - Check index suggestions in Firebase console as needed.

---

## Quick Wins Checklist

- [ ] Defer `CartController.loadCartsFromFirestore()` to post-frame.
- [ ] Stabilize followed-stores stream in `ProfilePage` (hoist to state).
- [ ] Replace `NetworkImage/Image.network` with cached image provider in list-heavy widgets; add size hints.
- [ ] Memoize categories fetch (convert `HomePage` to Stateful, hoist `Future`).
- [ ] Add `onCancel` cleanup in `FollowController.watchIsFollowing()`.
- [ ] Add `RepaintBoundary` to heavy cards; verify builder lists.
- [ ] Lighten shimmer usage and large gradients.
- [ ] Enable Android minify + shrinkResources; build with `--split-per-abi` and `--tree-shake-icons`.
- [ ] Remove duplicate asset entry in `pubspec.yaml`.

---

## Commit Plan (small PRs)

1) P0 startup trims (main.dart defers cart load)
2) P0 image caching + Profile followed-stream stabilization
3) P1 categories future memoization (HomePage → Stateful)
4) P1 FollowController watcher cleanup
5) P1 list paint isolation (RepaintBoundary/builder checks)
6) P2 UI skeleton/gradient simplifications
7) P2 build-size optimization (Gradle/iOS flags, build flags)
8) P2 asset pruning and const/lint passes

Minimal tests:
- Widget test to ensure `HomePage` categories fetch only once per lifecycle.
- Unit test for `FollowController.watchIsFollowing()` verifies cleanup on last subscriber cancel.
- Integration smoke for Followed Stores stream stabilization (no duplicate listeners on tab switch).
