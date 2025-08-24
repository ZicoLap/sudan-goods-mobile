# Follow/Unfollow Stores — Architecture and Setup

This module adds a production-ready, layered implementation for following stores using Firestore. UI stays unchanged; you wire the controller/use-cases into your existing widgets.

## Firestore schema

- users/{userId}/following/{storeId}
  - storeId: string
  - followedAt: server timestamp (set by client write)
  - storeName: string
  - storeLogoUrl: string|null
  - storeIsActive: bool

- stores/{storeId}/followers/{userId} (mirror, future)
  - userId: string
  - followedAt: server timestamp

- stores/{storeId}
  - followersCount: number (maintained later by Cloud Functions)

Rationale: supports “is user following this store?” and “list my followed stores” without joins. Subcollections do not count against parent doc size.

## Domain interfaces (lib/follow/domain)

- entities/store_summary.dart — denormalized minimal store info
- repositories/follow_repo.dart — follow/unfollow/isFollowing/getFollowing
- repositories/store_repo.dart — lookup StoreSummary by storeId
- gateways/notifications_gateway.dart — future hook for FCM topics

## Data (lib/follow/data)

- firestore/firestore_follow_repository.dart
  - Writes use batched writes
  - Mirrors and counter increments are prepared but commented for later Functions
  - Reads implement: isFollowing via doc exists; getFollowing with orderBy('followedAt', desc) + cursor

- firestore/firestore_store_repository.dart
  - getSummary by reading stores/{id} and mapping to StoreSummary

## Use-cases (lib/follow/domain/usecases)

- FollowStore — checks not already following; reads StoreSummary; writes follow doc; optional notification subscribe
- UnfollowStore — deletes follow doc; optional notification unsubscribe
- IsFollowing — stream<bool>
- GetFollowingList — paginated stream of StoreSummary

## UI controller (lib/follow/presentation/controllers)

- FollowController (ChangeNotifier)
  - watchIsFollowing(storeId): stream<bool> with optimistic updates
  - toggleFollow(storeId): optimistic flip, revert on error
  - getFollowingPage(limit, startAfterStoreId): paginated list stream

## Wiring example (Provider)

See lib/follow/presentation/wiring/follow_wiring_example.dart for a ready-to-copy Provider setup and a simple follow button adapter.

## Security rules (emulator)

See emulator_tests/rules/firestore.rules. Highlights:
- Only the authenticated user can read/write their own following docs
- Follow create requires target store isActive && isApproved
- Mirror writes at stores/{storeId}/followers are blocked (reserved for Functions)

## Emulator tests (rules)

Node-based tests (no Cloud Functions needed):

1) Install node deps

```
cd emulator_tests
npm i
```

2) Run tests (downloads ephemeral Firestore emulator if needed)

```
npm test
```

Tests cover:
- Can follow an active & approved store
- Cannot follow an inactive store
- Can unfollow and read own following

## Dart tests

- test/follow/controller_test.dart — unit tests for optimistic toggle and error handling using in-memory fake repo (no emulator).

You can run:

```
flutter test test/follow
```

Optional: to integration-test the Firestore repository in Dart, run the Firestore emulator first and point Firestore to it inside the test. For now, repo-level rule correctness is covered by Node rules tests.

## Indexes

Current queries need only orderBy('followedAt', desc). Composite indexes will be required if you add more filters later; Firestore will prompt with a creation link.

## Future hooks

- Cloud Functions: onCreate/onDelete of users/{uid}/following/{storeId}
  - Mirror to stores/{storeId}/followers/{uid}
  - Update stores/{storeId}.followersCount using FieldValue.increment(+/-1)

- Notifications: implement NotificationsGateway with FCM topic subscribe/unsubscribe to topic name `store_{storeId}`.

## Short commit messages (suggested)

1) feat(follow): domain interfaces & StoreSummary entity
2) feat(follow): Firestore repositories (writes/reads) with TODOs for Functions/FCM
3) feat(follow): use-cases (follow/unfollow/isFollowing/getFollowingList)
4) feat(follow): FollowController (optimistic + pagination) and wiring example
5) chore(rules): add Firestore rules and emulator tests for follow
6) docs(follow): add README_follow.md with setup & future hooks
