import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/models/product.dart';
import '../lib/providers/cart_provider.dart';
import '../lib/services/cart_storage_service.dart';
import 'helpers/fake_cart_storage.dart' as fake_cart_storage;

Future<CartProvider> createCart() async {
  SharedPreferences.setMockInitialValues({});
  final storage = await SharedPreferences.getInstance();
  return CartProvider(
    storage: fake_cart_storage.FakeCartStorage() as CartStorageService,
  );
}

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

  test('Adding a product increases cart quantity', () async {
    final cart = await createCart();

    cart.addToCart(product);
    cart.addToCart(product);

    expect(cart.totalItems, 2);
    expect(cart.quantityFor(product.id), 2);
    expect(cart.totalPrice, 100.0);
  });

  test('Cart cannot exceed product stock', () async {
    final cart = await createCart();

    expect(cart.addToCart(product), true);
    expect(cart.addToCart(product), true);
    expect(cart.addToCart(product), true);

    // Fourth attempt must fail because stock is 3.
    expect(cart.addToCart(product), false);

    expect(cart.totalItems, 3);
    expect(cart.totalPrice, 150.0);
  });

  test('Out-of-stock product cannot be added', () async {
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

    final cart = await createCart();

    expect(cart.addToCart(outOfStockProduct), false);
    expect(cart.totalItems, 0);
  });
  
  test('Increase quantity updates cart total', () async {
    final cart = await createCart();

    cart.addToCart(product);

    final result = cart.addToCart(product);

    expect(result, true);
    expect(cart.quantityFor(product.id), 2);
    expect(cart.totalPrice, 100.0);
  });

  test('Quantity respects stock limits', () async {
    final cart = await createCart();

    cart.addToCart(product);

    // Product stock is three.
    expect(cart.addToCart(product), true);
    expect(cart.addToCart(product), true);

    // Cannot increase beyond stock.
    expect(cart.addToCart(product), false);

    expect(cart.quantityFor(product.id), 3);
  });
}


