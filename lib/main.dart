
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'services/product_repository.dart';
import 'services/cart_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cartStorage = CartStorageService();

  final cartProvider = CartProvider(
    storage: cartStorage,
  );

  // Load previously saved cart before displaying the app.
  await cartProvider.loadSavedCart();

  runApp(
    PurpleCartApp(cartProvider: cartProvider),
  );
}

class PurpleCartApp extends StatelessWidget {
  final CartProvider cartProvider;

  const PurpleCartApp({
    super.key,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            ProductRepository(),
          ),
        ),

        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
        ),
      ],
      child: MaterialApp(
        title: 'NexCart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
