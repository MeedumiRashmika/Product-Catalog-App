import 'package:flutter_test/flutter_test.dart';

import 'package:nexcart/models/cart_item.dart';
import 'package:nexcart/models/product.dart';

void main() {
  final testProduct = Product(
    id: 1,
    title: 'Wireless Headphones',
    description: 'Bluetooth headphones',
    price: 50.0,
    rating: 4.5,
    stock: 10,
    thumbnail: 'https://example.com/headphones.png',
    images: const ['https://example.com/headphones.png'],
  );

  test('CartItem converts to JSON correctly', () {
    final item = CartItem(product: testProduct, quantity: 2);

    final json = item.toJson();

    expect(json['quantity'], 2);
    expect(json['product']['id'], 1);
    expect(json['product']['title'], 'Wireless Headphones');
    expect(json['product']['price'], 50.0);
  });

  test('CartItem restores from JSON correctly', () {
    final item = CartItem(product: testProduct, quantity: 3);

    final json = item.toJson();
    final restoredItem = CartItem.fromJson(json);

    expect(restoredItem.product.id, 1);
    expect(restoredItem.product.title, 'Wireless Headphones');
    expect(restoredItem.quantity, 3);
    expect(restoredItem.totalPrice, 150.0);
  });

  test('CartItem rejects invalid quantity', () {
    final item = CartItem(product: testProduct, quantity: 2);

    final json = item.toJson();
    json['quantity'] = 0;

    expect(() => CartItem.fromJson(json), throwsFormatException);
  });

  test('CartItem rejects quantity greater than stock', () {
    final item = CartItem(product: testProduct, quantity: 2);

    final json = item.toJson();
    json['quantity'] = 11;

    expect(() => CartItem.fromJson(json), throwsFormatException);
  });
}
