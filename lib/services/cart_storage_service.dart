import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class CartStorageService {
  static const String _cartKey = 'purplecart_saved_cart';

  final SharedPreferencesAsync _preferences;

  CartStorageService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  // Convert the cart items to JSON and save on the device.
  Future<void> saveCart(List<CartItem> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();

    final jsonString = jsonEncode(jsonList);

    await _preferences.setString(_cartKey, jsonString);
  }

  // Read the saved JSON and recreate cart items.
  Future<List<CartItem>> loadCart() async {
    final jsonString = await _preferences.getString(_cartKey);

    // No previously saved cart.
    if (jsonString == null) {
      return [];
    }

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;

      return decoded.map((item) {
        return CartItem.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    } on FormatException {
      throw const FormatException('Saved cart data is invalid.');
    } on TypeError {
      throw const FormatException('Saved cart data has an unexpected format.');
    }
  }

  // Delete the saved cart from local storage.
  Future<void> clearCart() async {
    await _preferences.remove(_cartKey);
  }
}
