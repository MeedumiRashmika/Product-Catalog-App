import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  // Calculate the total price of this cart item.
  double get totalPrice {
    return product.price * quantity;
  }

  // Create a new CartItem with an updated quantity.
  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  // Convert a CartItem into JSON.
  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  // Convert JSON back into a CartItem.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = Product.fromJson(
      Map<String, dynamic>.from(json['product'] as Map),
    );

    final quantity = (json['quantity'] as num).toInt();

    if (quantity <= 0 || quantity > product.stock) {
      throw const FormatException('Invalid cart quantity');
    }

    return CartItem(product: product, quantity: quantity);
  }
}
