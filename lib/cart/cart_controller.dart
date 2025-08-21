import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/store_model.dart';

/// Manages carts per store, syncing with Firestore and notifying listeners
/// on changes. Each store has its own list of [CartItem]s.
class CartController extends ChangeNotifier {
  final Map<String, List<CartItem>> _storeCarts = {};

  /// Exposes the in-memory carts keyed by [storeId].
  Map<String, List<CartItem>> get storeCarts => _storeCarts;

  /// 🔢 Get all cart item count across all stores
  int get totalQuantity => _storeCarts.values
      .expand((items) => items)
      .fold(0, (sum, item) => sum + item.quantity);

  /// 💰 Total price across all carts
  double get totalPrice => _storeCarts.values
      .expand((items) => items)
      .fold(0, (sum, item) => sum + item.totalPrice);

  /// 📦 Is the cart system empty?
  bool get isEmpty => _storeCarts.isEmpty;

  /// 💡 Get cart for a store
  List<CartItem> getItemsByStore(String storeId) => _storeCarts[storeId] ?? [];

  /// Calculates the subtotal for all items in the cart for the given [storeId].
  double getSubtotal(String storeId) {
    return getItemsByStore(
      storeId,
    ).fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Calculates the total weight for the current cart of [storeId].
  double getTotalWeight(String storeId) {
    return getItemsByStore(
      storeId,
    ).fold(0, (sum, item) => sum + item.totalWeight);
  }

  /// 🔄 Add or update item
  void addItem(CartItem item) {
    final cart = _storeCarts[item.storeId] ?? [];

    final index = cart.indexWhere((e) => e.productId == item.productId);
    if (index >= 0) {
      cart[index].quantity += item.quantity;
    } else {
      cart.add(item);
    }

    _storeCarts[item.storeId] = cart;
    notifyListeners();
    syncCartToFirestore(item.storeId);
  }

  /// Sets a new [newQuantity] for a [productId] in a specific [storeId] cart.
  /// Removes the item if [newQuantity] is 0 or less, and removes the cart if empty.
  void updateQuantity(String storeId, String productId, int newQuantity) {
    final cart = _storeCarts[storeId];
    if (cart == null) return;

    final index = cart.indexWhere((e) => e.productId == productId);
    if (index >= 0) {
      cart[index].quantity = newQuantity;
      if (newQuantity <= 0) {
        cart.removeAt(index);
      }
    }

    if (cart.isEmpty) {
      _storeCarts.remove(storeId);
    }

    notifyListeners();
    syncCartToFirestore(storeId);
  }

  /// Removes a product from a [storeId] cart by its [productId].
  void removeItem(String storeId, String productId) {
    final cart = _storeCarts[storeId];
    if (cart == null) return;

    cart.removeWhere((e) => e.productId == productId);

    if (cart.isEmpty) {
      _storeCarts.remove(storeId);
    }

    notifyListeners();
    syncCartToFirestore(storeId);
  }

  /// Clears an entire cart for the given [storeId].
  void clearCart(String storeId) {
    _storeCarts.remove(storeId);
    notifyListeners();
    syncCartToFirestore(storeId);
  }

  /// Fetches store details from Firestore for the provided [storeId].
  Future<Store> getStoreDetails(String storeId) async {
    final storeDoc =
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();

    if (!storeDoc.exists) {
      throw Exception('Store not found');
    }

    return Store.fromJson(storeDoc.data()!);
  }

  /// 🔁 Firestore sync (per store)
  Future<void> syncCartToFirestore(String storeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('carts')
        .doc(storeId);

    final items = _storeCarts[storeId];
    if (items == null || items.isEmpty) {
      await cartRef.delete();
      return;
    }

    final itemsMap = {
      'items': items.map((e) => e.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await cartRef.set(itemsMap);
  }

  /// 🔁 Load all carts from Firestore
  Future<void> loadCartsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartCollection =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('carts')
            .get();

    _storeCarts.clear();

    for (var doc in cartCollection.docs) {
      final storeId = doc.id;
      final data = doc.data();
      final List itemsJson = data['items'] ?? [];
      final items = itemsJson.map((e) => CartItem.fromJson(e)).toList();
      _storeCarts[storeId] = items;
    }

    notifyListeners();
  }

  /// Get quantity of a specific product in a store cart
  int getProductQuantity(String storeId, String productId) {
    return _storeCarts[storeId]
            ?.firstWhere(
              (e) => e.productId == productId,
              orElse:
                  () => CartItem(
                    productId: '',
                    storeId: '',
                    name: '',
                    price: 0,
                    weight: 0,
                    quantity: 0,
                  ),
            )
            .quantity ??
        0;
  }
}
