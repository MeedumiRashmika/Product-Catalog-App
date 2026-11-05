import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';
import 'services/product_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PurpleCartApp());
}

class PurpleCartApp extends StatelessWidget {
  const PurpleCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(
        ProductRepository(),
      ),
      child: MaterialApp(
        title: 'PurpleCart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
