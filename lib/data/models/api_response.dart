import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API response wrapper
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;
  
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });
  
  /// Create ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
  
  /// Convert ApiResponse to JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
  
  /// Create successful response
  factory ApiResponse.success({
    T? data,
    String? message,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      meta: meta,
    );
  }
  
  /// Create error response
  factory ApiResponse.error({
    String? message,
    Map<String, dynamic>? errors,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      meta: meta,
    );
  }
  
  /// Check if response has data
  bool get hasData => data != null;
  
  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Get error message
  String get errorMessage => message ?? 'Une erreur est survenue';
  
  /// Get success message
  String get successMessage => message ?? 'Opération réussie';
  
  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, hasData: $hasData}';
  }
}

/// Paginated API response
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta pagination;
  
  const PaginatedResponse({
    required this.data,
    required this.pagination,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
  
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
  
  /// Check if there are more pages
  bool get hasNextPage => pagination.hasNextPage;
  
  /// Check if there are previous pages
  bool get hasPreviousPage => pagination.hasPreviousPage;
  
  /// Get total items count
  int get totalItems => pagination.totalItems;
  
  /// Get current page
  int get currentPage => pagination.currentPage;
  
  /// Get total pages
  int get totalPages => pagination.totalPages;
}

/// Pagination metadata
@JsonSerializable()
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  
  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  
  factory PaginationMeta.fromJson(Map<String, dynamic> json) => _$PaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
  
  /// Get page range display (e.g., "1-20 of 100")
  String get rangeDisplay {
    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (start + itemsPerPage - 1).clamp(start, totalItems);
    return '$start-$end sur $totalItems';
  }
  
  /// Get page display (e.g., "Page 1 of 5")
  String get pageDisplay => 'Page $currentPage sur $totalPages';
}

/// Error details for validation errors
@JsonSerializable()
class ValidationError {
  final String field;
  final String message;
  final String? code;
  final dynamic value;
  
  const ValidationError({
    required this.field,
    required this.message,
    this.code,
    this.value,
  });
  
  factory ValidationError.fromJson(Map<String, dynamic> json) => _$ValidationErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}

/// API error response
@JsonSerializable()
class ApiError {
  final String message;
  final String? code;
  final int? statusCode;
  final List<ValidationError>? validationErrors;
  final Map<String, dynamic>? details;
  final DateTime timestamp;
  
  const ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.validationErrors,
    this.details,
    required this.timestamp,
  });
  
  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
  
  /// Check if error has validation errors
  bool get hasValidationErrors => validationErrors != null && validationErrors!.isNotEmpty;
  
  /// Get validation error for specific field
  ValidationError? getValidationError(String field) {
    if (!hasValidationErrors) return null;
    return validationErrors!.where((error) => error.field == field).firstOrNull;
  }
  
  /// Get all validation messages
  List<String> get validationMessages {
    if (!hasValidationErrors) return [];
    return validationErrors!.map((error) => error.message).toList();
  }
}

/// Statistics response model
@JsonSerializable()
class StatsResponse {
  final Map<String, dynamic> overview;
  final Map<String, dynamic> challenges;
  final Map<String, dynamic> performances;
  final Map<String, dynamic> rewards;
  final DateTime generatedAt;
  
  const StatsResponse({
    required this.overview,
    required this.challenges,
    required this.performances,
    required this.rewards,
    required this.generatedAt,
  });
  
  factory StatsResponse.fromJson(Map<String, dynamic> json) => _$StatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatsResponseToJson(this);
  
  /// Get overview stat value
  T? getOverviewStat<T>(String key) => overview[key] as T?;
  
  /// Get challenge stat value
  T? getChallengeStat<T>(String key) => challenges[key] as T?;
  
  /// Get performance stat value
  T? getPerformanceStat<T>(String key) => performances[key] as T?;
  
  /// Get reward stat value
  T? getRewardStat<T>(String key) => rewards[key] as T?;
}
