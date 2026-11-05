import 'package:dio/dio.dart';
import '../core/api_constants.dart';
import '../models/product.dart';

class ProductPage {
  final List<Product> products;
  final int total;

  const ProductPage({
    required this.products,
    required this.total,
  });
}

class ProductRepository {
  final Dio _dio;

  ProductRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            );

  Future<ProductPage> getProducts({
    int limit = ApiConstants.pageSize,
    int skip = 0,
    String search = '',
  }) async {
    try {
      final query = search.trim();

      final response = await _dio.get(
        query.isEmpty
            ? ApiConstants.products
            : ApiConstants.searchProducts,
        queryParameters: {
          'limit': limit,
          'skip': skip,
          if (query.isNotEmpty) 'q': query,
        },
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      final items = (data['products'] as List<dynamic>)
          .map(
            (item) => Product.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      return ProductPage(
        products: items,
        total: (data['total'] as num).toInt(),
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timed out. Please try again.',
        );
      }

      if (error.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect. Check your internet connection.',
        );
      }

      if (error.response != null) {
        throw Exception(
          'Server error (${error.response?.statusCode}). Please retry.',
        );
      }

      throw Exception('Could not load products. Please retry.');
    } on FormatException {
      throw Exception('Invalid product data received.');
    } on TypeError {
      throw Exception('Unexpected product data received.');
    }
  }
}
