import 'package:flutter/foundation.dart';
import '../core/api_constants.dart';
import '../models/product.dart';
import '../services/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider(this.repository);

  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  String? errorMessage;

  String _search = '';
  int _total = 0;
  int _generation = 0;

  Future<void> loadProducts({String search = ''}) async {
    final requestId = ++_generation;

    _search = search.trim();
    _products.clear();

    isLoading = true;
    isLoadingMore = false;
    hasMore = true;
    errorMessage = null;

    notifyListeners();

    try {
      final page = await repository.getProducts(
        limit: ApiConstants.pageSize,
        skip: 0,
        search: _search,
      );

      if (requestId != _generation) return;

      _products.addAll(page.products);
      _total = page.total;

      hasMore = _products.length < _total;
    } catch (error) {
      if (requestId != _generation) return;

      errorMessage = _readableError(error);
    } finally {
      if (requestId == _generation) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading ||
        isLoadingMore ||
        !hasMore ||
        errorMessage != null) {
      return;
    }

    final requestId = _generation;

    isLoadingMore = true;
    notifyListeners();

    try {
      final page = await repository.getProducts(
        limit: ApiConstants.pageSize,
        skip: _products.length,
        search: _search,
      );

      if (requestId != _generation) return;

      _products.addAll(page.products);
      _total = page.total;

      hasMore = _products.length < _total;
      errorMessage = null;
    } catch (error) {
      if (requestId != _generation) return;

      errorMessage = _readableError(error);
    } finally {
      if (requestId == _generation) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> retry() async {
    if (_products.isEmpty) {
      await loadProducts(search: _search);
    } else {
      errorMessage = null;
      await loadMore();
    }
  }

  String _readableError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
