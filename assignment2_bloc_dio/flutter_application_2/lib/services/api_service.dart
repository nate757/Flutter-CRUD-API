import 'package:dio/dio.dart';
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Logging interceptor (visible in debug console)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        error: true,
        requestHeader: false,
      ),
    );
  }

  // ── READ (all) ──────────────────────────────────────────────────────────────
  Future<List<Product>> fetchProducts({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── CREATE ──────────────────────────────────────────────────────────────────
  Future<Product> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
  }) async {
    try {
      final response = await _dio.post(
        '/products/add',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'category': category,
        },
      );
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────────
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _dio.put(
        '/products/${product.id}',
        data: {
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'category': product.category,
        },
      );
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error helper ────────────────────────────────────────────────────────────
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Check your internet.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        return Exception('Server error ($status). Please try again.');
      default:
        return Exception('Something went wrong: ${e.message}');
    }
  }
}