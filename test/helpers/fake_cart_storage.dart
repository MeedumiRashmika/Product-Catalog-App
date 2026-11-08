import 'package:shared_preferences/shared_preferences.dart';

import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:product_catalog_app/models/cart_item.dart';
import 'package:product_catalog_app/services/cart_storage_service.dart';

class FakeCartStorage extends CartStorageService {
  // Initialize mock storage for the Async API.
  static SharedPreferencesAsync createPreferences() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    return SharedPreferencesAsync();
  }

  FakeCartStorage() : super(preferences: createPreferences());

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
