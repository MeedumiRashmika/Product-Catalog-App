import 'package:flutter_test/flutter_test.dart';
import 'package:nexcart/models/product.dart';
import 'package:nexcart/providers/cart_provider.dart' show CartProvider;
import 'helpers/fake_cart_storage.dart';

void main() {
  final product = Product(
    id: 1,
    title: 'Wireless Headphones',
    description: 'Bluetooth headphones',
    price: 50.0,
    rating: 4.5,
    stock: 10,
    thumbnail: 'https://example.com/image.png',
    images: const [],
  );

  CartProvider createCart(FakeCartStorage storage) {
  return CartProvider(storage: storage);
}

  // TEST 1: Adding a product saves the cart.
  test('Adding a product automatically saves cart', () async {
    final storage = FakeCartStorage();
    final cart = createCart(storage);

    await cart.loadSavedCart();

    final result = cart.addToCart(product);

    await cart.waitForPendingSave();

    expect(result, true);
    expect(storage.savedItems.length, 1);
    expect(storage.savedItems.first.quantity, 1);
    expect(storage.savedItems.first.product.id, 1);
  });

  // TEST 2: Saved products are restored.
  test('Saved cart restores when a new provider starts', () async {
    final storage = FakeCartStorage();

    // First app session
    final firstCart = createCart(storage);

    await firstCart.loadSavedCart();

    firstCart.addToCart(product);
    firstCart.addToCart(product);

    await firstCart.waitForPendingSave();

    expect(firstCart.totalItems, 2);
    expect(firstCart.totalPrice, 100.0);

    // Simulate restarting the application
    final secondCart = createCart(storage);

    await secondCart.loadSavedCart();

    expect(secondCart.totalItems, 2);
    expect(secondCart.quantityFor(product.id), 2);
    expect(secondCart.totalPrice, 100.0);
  });

  // TEST 3: Quantity changes are saved.
  test('Quantity changes are saved', () async {
    final storage = FakeCartStorage();
    final cart = createCart(storage);

    await cart.loadSavedCart();

    cart.addToCart(product);

    cart.increaseQuantity(product.id);
    cart.increaseQuantity(product.id);
    cart.decreaseQuantity(product.id);

    await cart.waitForPendingSave();

    expect(cart.quantityFor(product.id), 2);
    expect(storage.savedItems.first.quantity, 2);
    expect(storage.savedItems.first.totalPrice, 100.0);
  });

  // TEST 4: Removing a product updates storage.
  test('Removing a product updates saved cart', () async {
    final storage = FakeCartStorage();
    final cart = createCart(storage);

    await cart.loadSavedCart();

    cart.addToCart(product);

    await cart.waitForPendingSave();

    expect(storage.savedItems.length, 1);

    final removed = cart.removeFromCart(product.id);

    await cart.waitForPendingSave();

    expect(removed, true);
    expect(cart.items, isEmpty);
    expect(storage.savedItems, isEmpty);
    expect(cart.totalPrice, 0.0);
  });

  // TEST 5: Empty saved cart.
  test('Empty saved cart loads correctly', () async {
    final storage = FakeCartStorage();
    final cart = createCart(storage);

    await cart.loadSavedCart();

    expect(cart.items, isEmpty);
    expect(cart.totalItems, 0);
    expect(cart.totalPrice, 0.0);
    expect(cart.storageError, isNull);
  });
}
