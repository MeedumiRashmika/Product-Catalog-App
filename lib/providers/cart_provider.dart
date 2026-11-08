
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/cart_storage_service.dart';

class CartProvider extends ChangeNotifier {
  final CartStorageService _storage;

  CartProvider({
    required CartStorageService storage,
  }) : _storage = storage;

  final Map<int, CartItem> _items = {};

  Future<void> _saveQueue = Future<void>.value();

  String? storageError;

  List<CartItem> get items =>
      List.unmodifiable(_items.values);

  int get totalItems {
    return _items.values.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get totalPrice {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  int quantityFor(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  // Restore saved cart when app starts.
  Future<void> loadSavedCart() async {
    try {
      final savedItems = await _storage.loadCart();

      _items.clear();

      for (final item in savedItems) {
        _items[item.product.id] = item;
      }

      storageError = null;
    } catch (error) {
      storageError = 'Unable to restore saved cart: $error';
      debugPrint(storageError);
    }

    notifyListeners();
  }

  // Queue saves in order to avoid overwriting newer changes.
  void _saveCart() {
    final snapshot = List<CartItem>.from(_items.values);

    _saveQueue = _saveQueue.then((_) async {
      try {
        await _storage.saveCart(snapshot);

        if (storageError != null) {
          storageError = null;
          notifyListeners();
        }
      } catch (error) {
        storageError = 'Unable to save cart: $error';
        debugPrint(storageError);
        notifyListeners();
      }
    });
  }

  // Useful for testing pending storage operations.
  Future<void> waitForPendingSave() => _saveQueue;

  bool addToCart(Product product) {
    final currentQuantity = quantityFor(product.id);

    if (product.stock <= 0 ||
        currentQuantity >= product.stock) {
      return false;
    }

    final existingItem = _items[product.id];

    if (existingItem == null) {
      _items[product.id] = CartItem(
        product: product,
        quantity: 1,
      );
    } else {
      _items[product.id] = existingItem.copyWith(
        quantity: currentQuantity + 1,
      );
    }

    notifyListeners();
    _saveCart();

    return true;
  }

  bool increaseQuantity(int productId) {
    final item = _items[productId];

    if (item == null ||
        item.quantity >= item.product.stock) {
      return false;
    }

    _items[productId] = item.copyWith(
      quantity: item.quantity + 1,
    );

    notifyListeners();
    _saveCart();

    return true;
  }

  bool decreaseQuantity(int productId) {
    final item = _items[productId];

    if (item == null || item.quantity <= 1) {
      return false;
    }

    _items[productId] = item.copyWith(
      quantity: item.quantity - 1,
    );

    notifyListeners();
    _saveCart();

    return true;
  }

  bool removeFromCart(int productId) {
    final removedItem = _items.remove(productId);

    if (removedItem == null) {
      return false;
    }

    notifyListeners();
    _saveCart();

    return true;
  }
}
