import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexcart/models/cart_item.dart';
import 'package:nexcart/models/product.dart';
import 'package:nexcart/services/cart_storage_service.dart';

class MockPreferences extends Mock implements SharedPreferencesAsync {}

void main() {
  late MockPreferences preferences;
  late CartStorageService storage;

  final product = Product(
    id: 1,
    title: 'Wireless Headphones',
    description: 'Bluetooth headphones',
    price: 50.0,
    rating: 4.5,
    stock: 10,
    thumbnail: 'https://example.com/item.png',
    images: const [],
  );

  setUp(() {
    preferences = MockPreferences();

    storage = CartStorageService(preferences: preferences);
  });

  test('Saving and loading restores cart items', () async {
    final savedValues = <String, String>{};

    when(() => preferences.setString(any(), any()))
        .thenAnswer((invocation) async {
          final key = invocation.positionalArguments[0] as String;
          final value = invocation.positionalArguments[1] as String;

          savedValues[key] = value;
        });

    when(() => preferences.getString(any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;

      return savedValues[key];
    });

    final items = [CartItem(product: product, quantity: 2)];

    await storage.saveCart(items);

    final restoredItems = await storage.loadCart();

    expect(restoredItems.length, 1);
    expect(restoredItems.first.product.id, 1);
    expect(restoredItems.first.quantity, 2);
    expect(restoredItems.first.totalPrice, 100.0);
  });

  test('Loading with no saved cart returns empty list', () async {
    when(() => preferences.getString(any())).thenAnswer((_) async => null);

    final items = await storage.loadCart();

    expect(items, isEmpty);
  });

  test('Invalid saved JSON throws FormatException', () async {
    when(() => preferences.getString(any()))
        .thenAnswer((_) async => 'invalid json');

    expect(() => storage.loadCart(), throwsFormatException);
  });

  test('Clearing cart removes saved storage key', () async {
    when(() => preferences.remove(any())).thenAnswer((_) async {});

    await storage.clearCart();

    verify(() => preferences.remove('purplecart_saved_cart')).called(1);
  });
}
