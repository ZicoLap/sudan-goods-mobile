# sudan_goods_mobile

General documentation for the Sudan Goods mobile app.

## Overview
Sudan Goods is a cross‑platform Flutter e‑commerce app for browsing Sudanese stores and products, adding items to a cart, and placing orders. It uses Firebase for authentication, data storage, and media.

## Tech Stack
- Flutter + Dart
- Firebase: Auth, Firestore, Storage (Cloud Functions configured)
- State management: Provider
- UI: Google Fonts, Shimmer loading states

## Platforms
- Android, iOS, Web, Windows, macOS, Linux

## Project Structure (high-level)
- `lib/`
  - `authentication/` — sign in, registration, auth gate
  - `Home/` — home pages and services (stores, categories)
  - `store/` — store details, featured products, collections
  - `cart/` — cart controller and UI widgets
  - `checkout/` — checkout page, sections, services
  - `order/` — order details and services
  - `models/` — data models (Store, Product, Category, Collection, Order, AppUser, Address)
  - `user/` — `UserProvider` for profile data
  - `core/utils/` — timestamp converters and helpers

## Core Features
- **Authentication** — Firebase Auth with user profile documents in Firestore.
- **Stores & Products** — Featured/approved stores, store details, collections, live product updates.
- **Cart** — Per‑store cart, synchronized under the user in Firestore.
- **Checkout** — Pre‑fills user info/address, computes totals, creates orders.
- **Orders** — List and detail views; filter by user; live status updates.

## Firestore Data (high-level)
- **`users/{uid}`** (AppUser)
  - `uid`, `email`, `firstName`, `lastName`, `role`, `gender`, `birthday` (ISO string), `createdAt` (ISO string), `phoneNumber`, `addresses[]` (Address)
- **`stores/{storeId}`** (Store)
  - Identity/media, `address` (Address), `tags[]`, `isActive`, `isApproved`, `isOpen`, `isFeatured`, `rating`, `ratingCount`, `minimumOrderAmount`, `storeTypes[]`, `categoryIds[]`, `freeDeliveryOver?`, `deliveryPricing[]` (DeliveryRule), `createdAt`/`updatedAt` (Timestamp)
- **`products/{productId}`** (Product)
  - `storeId`, `name`, `description`, `price`, `discountPrice?`, `images[]`, `category?`, `quantity`, `isAvailable`, `weight`, `isFeatured`, `collectionIds[]`, `createdAt`/`updatedAt` (Timestamp)
- **`collections/{collectionId}`** (Collection)
  - `storeId`, `name`, `imageUrl`, `createdAt` (Timestamp)
- **`categories/{categoryId}`** (Category)
  - `name`, `imageUrl?`, `isActive`, `isFeatured`, `createdAt` (DateTime via converter), `updatedAt?`
- **Subcollections**
  - `users/{uid}/carts/{storeId}` — `{ items: CartItem[], updatedAt: serverTimestamp }`

## State Management
- `CartController` — in‑memory cart per store, Firestore sync, totals/weight
- `UserProvider` — current user profile data

## UX
- Shimmer loading skeletons across key sections
- Consistent typography and spacing

## Build & Run
Prerequisites: Flutter SDK, platform toolchains, Firebase project.

Install dependencies:
```bash
flutter pub get
```

Generate JSON code (after model changes):
```bash
dart run build_runner build -d
```

Run the app:
```bash
flutter run
```

Firebase config:
- Android: `android/app/google-services.json` is present.
- Ensure Apple/desktop platforms have corresponding Firebase configs before release builds.

---
This app delivers a full e‑commerce flow backed by Firebase, with Provider state, Firestore‑driven UI, and a polished, consistent UX.
