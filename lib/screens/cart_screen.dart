import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),

      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Show empty cart message
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppTheme.lavender,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 65,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Start adding products you love!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Explore Products'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Display cart products
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final product = item.product;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product image
                          Container(
                            width: 90,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.lavender,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }

                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppTheme.primary,
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Product information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product title

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product title
                                    Expanded(
                                      child: Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ),

                                    // Delete button
                                    IconButton(
                                      tooltip: 'Remove product',
                                      onPressed: () {
                                        _showRemoveConfirmation(
                                          context,
                                          product.id,
                                          product.title,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 22,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Product unit price
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Quantity increase/decrease buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Minus button
                                    IconButton(
                                      onPressed: item.quantity > 1
                                          ? () {
                                              context
                                                  .read<CartProvider>()
                                                  .decreaseQuantity(product.id);
                                            }
                                          : null,
                                      icon: const Icon(Icons.remove, size: 18),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppTheme.lavender,
                                        foregroundColor: AppTheme.primary,
                                        disabledForegroundColor: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Current quantity
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Plus button
                                    IconButton(
                                      onPressed: item.quantity < product.stock
                                          ? () {
                                              context
                                                  .read<CartProvider>()
                                                  .addToCart(product);
                                            }
                                          : null,
                                      icon: const Icon(Icons.add, size: 18),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppTheme.lavender,
                                        foregroundColor: AppTheme.primary,
                                        disabledForegroundColor: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Total price for this product
                                Text(
                                  'Subtotal: \$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Order summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.lavender)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Items',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      const Divider(color: AppTheme.lavender),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRemoveConfirmation(
    BuildContext context,
    int productId,
    String productTitle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove product?'),
        content: Text('Remove "$productTitle" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CartProvider>().removeFromCart(productId);
    }
  }
}
