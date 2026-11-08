
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

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
          return Column(
            children: [
              // Show storage error if saving/restoring fails.
              if (cart.storageError != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFFFF3CD),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF8A5700),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cart.storageError!,
                          style: const TextStyle(
                            color: Color(0xFF8A5700),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Show empty cart or cart products.
              Expanded(
                child: cart.items.isEmpty
                    ? _buildEmptyCart(context)
                    : _buildCartItems(context, cart),
              ),

              // Show order summary only when cart has items.
              if (cart.items.isNotEmpty)
                _buildOrderSummary(
                  productCount: cart.items.length,
                  totalItems: cart.totalItems,
                  subtotal: cart.totalPrice,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary({
    required int productCount,
    required int totalItems,
    required double subtotal,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$productCount products · $totalItems items'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY CART UI
  // --------------------------------------------------

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
              textAlign: TextAlign.center,
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.shopping_bag_outlined,
              ),
              label: const Text('Explore Products'),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CART PRODUCT LIST
  // --------------------------------------------------

  Widget _buildCartItems(
    BuildContext context,
    CartProvider cart,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final product = item.product;

        return Container(
          key: ValueKey(product.id),
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
                width: 82,
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
                    loadingBuilder: (
                      context,
                      child,
                      progress,
                    ) {
                      if (progress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
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
                    // Product title and remove button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                    // Quantity controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrease quantity
                        IconButton(
                          tooltip: 'Decrease quantity',
                          onPressed: item.quantity > 1
                              ? () {
                                  context
                                      .read<CartProvider>()
                                      .decreaseQuantity(product.id);
                                }
                              : null,
                          icon: const Icon(
                            Icons.remove,
                            size: 18,
                          ),
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

                        // Increase quantity
                        IconButton(
                          tooltip: 'Increase quantity',
                          onPressed: item.quantity < product.stock
                              ? () {
                                  context
                                      .read<CartProvider>()
                                      .increaseQuantity(product.id);
                                }
                              : null,
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.lavender,
                            foregroundColor: AppTheme.primary,
                            disabledForegroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Product subtotal
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
    );
  }

  // --------------------------------------------------
  // REMOVE PRODUCT CONFIRMATION
  // --------------------------------------------------

  Future<void> _showRemoveConfirmation(
    BuildContext context,
    int productId,
    String productTitle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Product?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to remove '
            '"$productTitle" from your cart?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final removed = context
          .read<CartProvider>()
          .removeFromCart(productId);

      if (removed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product removed from cart',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
