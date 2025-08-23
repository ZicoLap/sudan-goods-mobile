# Checkout Module Refactor

This document outlines the new layering for the Checkout feature and the extension point for future Stripe integration.

## Layers

- UI (Widgets)
  - `lib/checkout/pages/`
  - Screens and UI sections only. No business rules or Firestore access.

- Controller (Business Logic / Presentation)
  - `lib/checkout/controller/checkout_controller.dart`
  - Coordinates between UI and services.
  - Exposes `isLoading` and `placeOrderViaService(...)` to the UI.
  - Handles user-facing errors (SnackBars) and navigation to success screen.

- Services (Domain + Data Access)
  - `lib/checkout/services/checkout_service.dart`
    - Orchestrates checkout: reads user profile/address, cart content, calculates delivery fee and totals, builds the `Order` model, and persists via `OrderServices`.
    - Future hook for payment: determine the real `paymentStatus` using a payment gateway before creating the order.
  - `lib/checkout/services/payment_gateway.dart`
    - Provider-agnostic payment gateway interface and normalized `PaymentResult`.

- Orders (Existing)
  - `lib/order/order_service.dart`
    - Firestore access for persisting orders.

## Stripe Integration Hook

When integrating Stripe, implement a concrete gateway (e.g., `StripePaymentGateway`) that conforms to `PaymentGateway` and inject it into `CheckoutService`.

Suggested steps:
1. Implement `StripePaymentGateway implements PaymentGateway` using your Stripe SDK.
2. Add a `PaymentGateway? paymentGateway` field to `CheckoutService` and invoke it before `createOrder`.
3. Map the `PaymentResult` to `paymentStatus` (e.g., `succeeded` -> `paid`, otherwise show an error and abort order creation).
4. Wire the gateway in `main.dart` when constructing `CheckoutService`.

## Navigation and Backstack

Order success navigation preserves the nested tab root using `Navigator.pushAndRemoveUntil(..., (route) => route.isFirst)`. The success page back button pops to the tab root to keep user context (e.g., Search tab).

## Testing Checklist

- Place order end-to-end without payment.
- Failure cases surface SnackBars.
- After success, back navigation returns to the current tab root.
- UI still displays summary and sections correctly.
