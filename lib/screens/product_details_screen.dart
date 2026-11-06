
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : product.thumbnail;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Badge(
                  isLabelVisible: cart.totalItems > 0,
                  label: Text('${cart.totalItems}'),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppTheme.primary,
                    size: 27,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Scrollable product information
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large product image
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: AppTheme.lavender,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (
                            context,
                            child,
                            progress,
                          ) {
                            if (progress == null) return child;

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 65,
                              color: AppTheme.primary,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stock badge and rating
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? const Color(0xFFE3F7EA)
                                : const Color(0xFFFFE4E6),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'In Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                              color: product.stock > 0
                                  ? const Color(0xFF237A44)
                                  : const Color(0xFFBE123C),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Product name
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF81758E),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Stock information
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Available Stock',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${product.stock} items',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed bottom Add to Cart button
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final inCart = cart.quantityFor(product.id);
        final canAdd =
            product.stock > 0 && inCart < product.stock;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFEDE9FE),
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canAdd
                  ? () {
                      final added = context
                          .read<CartProvider>()
                          .addToCart(product);

                      if (!added) return;

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Product added to cart!',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                    }
                  : null,
              icon: const Icon(
                Icons.shopping_bag_outlined,
              ),
              label: Text(
                product.stock <= 0
                    ? 'Out of Stock'
                    : !canAdd
                        ? 'Stock Limit Reached'
                        : 'Add to Cart',
              ),
            ),
          ),
        );
      },
    );
  }
}
