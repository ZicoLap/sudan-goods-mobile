/// Future hook for push notifications topic subscriptions per store.
///
/// Later, implement this with FCM topics like `store_{storeId}` where
/// each app instance subscribes/unsubscribes when user follows/unfollows.
abstract class NotificationsGateway {
  Future<void> subscribeToStore(String storeId);
  Future<void> unsubscribeFromStore(String storeId);
}
