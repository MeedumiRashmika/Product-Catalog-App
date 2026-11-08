
import '../../lib/models/cart_item.dart';

class FakeCartStorage {
  List<CartItem> savedItems = [];

  @override
  Future<void> saveCart(List<CartItem> items) async {
    savedItems = List<CartItem>.from(items);
  }

  @override
  Future<List<CartItem>> loadCart() async {
    return List<CartItem>.from(savedItems);
  }

  @override
  Future<void> clearCart() async {
    savedItems.clear();
  }
}
