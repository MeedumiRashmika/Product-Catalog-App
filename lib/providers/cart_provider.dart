import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int quantityFor(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  bool addToCart(Product product) {
    final currentQuantity = quantityFor(product.id);

    if (product.stock <= 0) {
      return false;
    }

    if (currentQuantity >= product.stock) {
      return false;
    }

    final existingItem = _items[product.id];

    if (existingItem == null) {
      _items[product.id] = CartItem(product: product, quantity: 1);
    } else {
      _items[product.id] = existingItem.copyWith(quantity: currentQuantity + 1);
    }

    notifyListeners();
    return true;
  }

  // Increase quantity by one.
  bool increaseQuantity(int productId) {
    final item = _items[productId];

    // Product must already exist in the cart.
    if (item == null) {
      return false;
    }

    // Do not exceed available stock.
    if (item.quantity >= item.product.stock) {
      return false;
    }

    _items[productId] = item.copyWith(quantity: item.quantity + 1);

    notifyListeners();
    return true;
  }

  // Decrease quantity by one.
  bool decreaseQuantity(int productId) {
    final item = _items[productId];

    // Product must already exist in the cart.
    if (item == null) {
      return false;
    }

    // Quantity cannot go below 1.
    if (item.quantity <= 1) {
      return false;
    }

    _items[productId] = item.copyWith(quantity: item.quantity - 1);

    notifyListeners();
    return true;
  }
}
