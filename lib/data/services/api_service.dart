import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:star_frontend/core/config/app_config.dart';
import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/errors/app_exceptions.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/api_response.dart';

/// Base API service for HTTP communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _authToken;

  /// Initialize the API service
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
    AppLogger.info(
      'ApiService initialized with base URL: ${AppConfig.baseUrl}',
    );
  }

  /// Setup request/response interceptors
  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          AppLogger.apiRequest(
            options.method,
            '${options.baseUrl}${options.path}',
            options.data,
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.apiResponse(
            response.requestOptions.method,
            '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            response.statusCode ?? 0,
            response.data,
          );

          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.apiError(
            error.requestOptions.method,
            '${error.requestOptions.baseUrl}${error.requestOptions.path}',
            error,
          );

          handler.next(error);
        },
      ),
    );

    // Retry interceptor for network errors
    _dio.interceptors.add(RetryInterceptor());
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    AppLogger.auth('Token set');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    AppLogger.auth('Token cleared');
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle successful response
  T _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    final data = response.data;

    if (fromJson != null) {
      return fromJson(data);
    }

    return data as T;
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Délai d\'attente dépassé');

      case DioExceptionType.connectionError:
        return const NetworkException('Erreur de connexion réseau');

      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      case DioExceptionType.cancel:
        return const NetworkException('Requête annulée');

      case DioExceptionType.unknown:
      default:
        return NetworkException('Erreur inconnue: ${error.message}');
    }
  }

  /// Handle HTTP error responses
  AppException _handleHttpError(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ServerException('Erreur serveur');
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    String message = 'Erreur HTTP $statusCode';
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'] as String;
    }

    return ExceptionFactory.fromStatusCode(statusCode, message, details: data);
  }

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;
}

/// Retry interceptor for handling network failures
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      AppLogger.warning('Retrying request (${retryCount + 1}/$maxRetries)');

      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue with original error if retry fails
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }
}
