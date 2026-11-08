
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/models/product.dart';

void main() {
  test('Product converts JSON data correctly', () {
    final json = {
      'id': 1,
      'title': 'Test Headphones',
      'description': 'Wireless headphones',
      'price': 49.99,
      'rating': 4.5,
      'stock': 12,
      'thumbnail': 'https://example.com/image.png',
      'images': ['https://example.com/image.png'],
    };

    final product = Product.fromJson(json);

    expect(product.id, 1);
    expect(product.title, 'Test Headphones');
    expect(product.price, 49.99);
    expect(product.rating, 4.5);
    expect(product.stock, 12);
    expect(product.images.length, 1);
  });
}
