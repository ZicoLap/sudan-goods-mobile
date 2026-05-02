import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sudan_goods/models/store/cart_item_model.dart';
import 'package:sudan_goods/models/store/live_cart_item.dart';
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

  ///  Is the cart system empty?
  bool get isEmpty => _storeCarts.isEmpty;

  /// 💡 Get cart for a store
  List<CartItem> getItemsByStore(String storeId) => _storeCarts[storeId] ?? [];

  /// Combines cart references with live product data for display.
  ///
  /// Listens to both the cart document AND each product document in real time.
  /// Any change to cart quantity OR product price/stock immediately re-emits
  /// the merged [LiveCartItem] list.
  ///
  /// Uses [asyncExpand] as a switchMap: when the cart doc changes (items
  /// added/removed) the previous product listeners are cancelled and fresh
  /// ones are opened for the new set of product IDs.
  Stream<List<LiveCartItem>> watchCartWithProducts(String storeId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('carts')
        .doc(storeId)
        .snapshots()
        .asyncExpand((cartSnap) {
          if (!cartSnap.exists) return Stream.value(<LiveCartItem>[]);

          final rawItems = (cartSnap.data()?['items'] as List? ?? []);
          final cartItems =
              rawItems
                  .map(
                    (e) =>
                        CartItem.fromJson(Map<String, dynamic>.from(e as Map)),
                  )
                  .toList();

          if (cartItems.isEmpty) return Stream.value(<LiveCartItem>[]);

          // Open a real-time .snapshots() listener for every product doc.
          final productStreams =
              cartItems
                  .map(
                    (item) =>
                        FirebaseFirestore.instance
                            .collection('products')
                            .doc(item.productId)
                            .snapshots(),
                  )
                  .toList();

          // Merge all product streams and re-emit the full list on every change.
          return _mergeProductStreams(cartItems, productStreams, storeId);
        });
  }

  /// Fans in [productStreams] and re-emits the full merged [LiveCartItem] list
  /// whenever any single product document changes.
  Stream<List<LiveCartItem>> _mergeProductStreams(
    List<CartItem> cartItems,
    List<Stream<DocumentSnapshot<Map<String, dynamic>>>> productStreams,
    String storeId,
  ) {
    final controller = StreamController<List<LiveCartItem>>();
    final latestData = List<Map<String, dynamic>?>.filled(
      productStreams.length,
      null,
    );
    final subs = <StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>[];
    var cancelled = false;

    void tryEmit() {
      if (cancelled) return;
      // Wait until every product has been received at least once.
      if (latestData.any((d) => d == null)) return;

      final result = <LiveCartItem>[];
      for (var i = 0; i < cartItems.length; i++) {
        final p = latestData[i];
        if (p == null) continue;
        final rawPrice = (p['price'] as num).toDouble();
        final discount = p['discountPrice'] as num?;
        final effectivePrice =
            (discount != null && discount > 0) ? discount.toDouble() : rawPrice;
        result.add(
          LiveCartItem(
            productId: cartItems[i].productId,
            storeId: storeId,
            quantity: cartItems[i].quantity,
            name: (p['name'] as String?) ?? '',
            price: effectivePrice,
            imageUrl:
                (p['images'] as List?)?.isNotEmpty == true
                    ? (p['images'] as List).first as String?
                    : null,
            weight: (p['weight'] as num? ?? 0).toDouble(),
            stock: (p['quantity'] as num? ?? 0).toInt(),
            isAvailable: (p['isAvailable'] as bool?) ?? true,
          ),
        );
      }
      controller.add(result);
    }

    for (var i = 0; i < productStreams.length; i++) {
      final idx = i;
      subs.add(
        productStreams[idx].listen((snap) {
          latestData[idx] = snap.data();
          tryEmit();
        }, onError: controller.addError),
      );
    }

    controller.onCancel = () {
      cancelled = true;
      for (final s in subs) {
        s.cancel();
      }
    };

    return controller.stream;
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
              orElse: () => CartItem(productId: '', storeId: '', quantity: 0),
            )
            .quantity ??
        0;
  }
}
