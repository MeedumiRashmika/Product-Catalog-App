import 'package:flutter_test/flutter_test.dart';
import '../lib/models/product.dart';
import '../lib/providers/cart_provider.dart';

void main() {
  final product = Product(
    id: 1,
    title: 'Headphones',
    description: 'Wireless headphones',
    price: 50.0,
    rating: 4.5,
    stock: 3,
    thumbnail: '',
    images: const [],
  );

  test('Adding a product increases cart quantity', () {
    final cart = CartProvider();

    cart.addToCart(product);
    cart.addToCart(product);

    expect(cart.totalItems, 2);
    expect(cart.quantityFor(product.id), 2);
    expect(cart.totalPrice, 100.0);
  });

  test('Cart cannot exceed product stock', () {
    final cart = CartProvider();

    expect(cart.addToCart(product), true);
    expect(cart.addToCart(product), true);
    expect(cart.addToCart(product), true);

    // Fourth attempt must fail because stock is 3.
    expect(cart.addToCart(product), false);

    expect(cart.totalItems, 3);
    expect(cart.totalPrice, 150.0);
  });

  test('Out-of-stock product cannot be added', () {
    final outOfStockProduct = Product(
      id: 2,
      title: 'Unavailable Item',
      description: 'Out of stock',
      price: 25.0,
      rating: 4.0,
      stock: 0,
      thumbnail: '',
      images: const [],
    );

    final cart = CartProvider();

    expect(cart.addToCart(outOfStockProduct), false);
    expect(cart.totalItems, 0);
  });
  
}


