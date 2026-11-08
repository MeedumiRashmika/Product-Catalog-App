
import 'package:product_catalog_app/models/cart_item.dart';

class FakeCartStorage {
  List<CartItem> savedItems = [];

  Future<void> saveCart(List<CartItem> items) async {
    savedItems = List<CartItem>.from(items);
  }

  Future<List<CartItem>> loadCart() async {
    return List<CartItem>.from(savedItems);
  }

  Future<void> clearCart() async {
    savedItems.clear();
  }
}
