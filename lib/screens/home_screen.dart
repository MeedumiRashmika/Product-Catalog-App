import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/status_view.dart';
import '../screens/product_details_screen.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController =
      TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProductProvider>().loadProducts();
    });
  }

  // Load next products when user scrolls near the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ProductProvider>().loadMore();
    }
  }

  // Wait 450ms after typing before searching.
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () {
        if (!mounted) return;

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }

        context.read<ProductProvider>().loadProducts(
          search: value,
        );
      },
    );

    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header, search bar, banner
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // Loading state
                if (provider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )

                // Error state
                else if (provider.errorMessage != null &&
                    provider.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: StatusView(
                      icon: Icons.wifi_off_rounded,
                      title: 'Something went wrong',
                      message: provider.errorMessage!,
                      buttonText: 'Retry',
                      onPressed: provider.retry,
                    ),
                  )

                // Empty state
                else if (provider.products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: StatusView(
                      icon: Icons.search_off_rounded,
                      title: 'No products found',
                      message:
                          'Try searching with a different product name.',
                    ),
                  )

                // Product grid
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18, 4, 18, 14,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildSectionTitle(),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width =
                            constraints.crossAxisExtent;

                        int columns = 2;

                        if (width >= 900) {
                          columns = 5;
                        } else if (width >= 650) {
                          columns = 4;
                        } else if (width >= 480) {
                          columns = 3;
                        }

                        return SliverGrid.builder(
                          itemCount: provider.products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            mainAxisExtent: 265,
                          ),
                          itemBuilder: (context, index) {
                            final Product product =
                                provider.products[index];

                            return ProductCard(
  product: product,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductDetailsScreen(
          product: product,
        ),
      ),
    );
  },
);
                          },
                        );
                      },
                    ),
                  ),

                  // Pagination loading or retry
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: provider.isLoadingMore
                            ? const CircularProgressIndicator()
                            : provider.errorMessage != null
                                ? Column(
                                    children: [
                                      Text(
                                        provider.errorMessage!,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: provider.retry,
                                        icon: const Icon(
                                          Icons.refresh,
                                        ),
                                        label: const Text(
                                          'Retry loading',
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NexCart',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Discover More. Shop Smarter.',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find something you love',
                    style: TextStyle(
                      color: Color(0xFF857990),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
         Consumer<CartProvider>(
  builder: (context, cart, child) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const CartScreen(),
          ),
        );
      },
      child: Badge(
        isLabelVisible: cart.totalItems > 0,
        label: Text('${cart.totalItems}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppTheme.lavender,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppTheme.primary,
            size: 26,
          ),
        ),
      ),
    );
  },
),
            ],
          ),

          const SizedBox(height: 24),

          // Search field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 23),

          // Promotion banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME TO NexCart',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.lavender,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Discover something\namazing.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Explore our collection of products.',
                  style: TextStyle(
                    color: Color(0xFFEDE9FE),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    final searching = _searchController.text.trim().isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          searching ? 'Search Results' : 'Popular Products',
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const Icon(
          Icons.grid_view_rounded,
          color: AppTheme.primary,
          size: 22,
        ),
      ],
    );
  }
}
