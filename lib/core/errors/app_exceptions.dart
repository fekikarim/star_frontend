/// Custom exceptions for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// API related exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(
    super.message, {
    this.statusCode,
    super.code,
    super.details,
  });

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.details,
  });
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.details});
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

/// Timeout related exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.details});
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details});
}

/// Unauthorized exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code, super.details});
}

/// Forbidden exceptions
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.code, super.details});
}

/// Conflict exceptions
class ConflictException extends AppException {
  const ConflictException(super.message, {super.code, super.details});
}

/// Bad request exceptions
class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.code, super.details});
}

/// Internal server error exceptions
class InternalServerErrorException extends AppException {
  const InternalServerErrorException(
    super.message, {
    super.code,
    super.details,
  });
}

/// Service unavailable exceptions
class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException(super.message, {super.code, super.details});
}

/// Exception factory for creating exceptions from HTTP status codes
class ExceptionFactory {
  static AppException fromStatusCode(
    int statusCode,
    String message, {
    String? code,
    dynamic details,
  }) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message, code: code, details: details);
      case 401:
        return UnauthorizedException(message, code: code, details: details);
      case 403:
        return ForbiddenException(message, code: code, details: details);
      case 404:
        return NotFoundException(message, code: code, details: details);
      case 409:
        return ConflictException(message, code: code, details: details);
      case 422:
        return ValidationException(message, code: code, details: details);
      case 500:
        return InternalServerErrorException(
          message,
          code: code,
          details: details,
        );
      case 503:
        return ServiceUnavailableException(
          message,
          code: code,
          details: details,
        );
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ApiException(
            message,
            statusCode: statusCode,
            code: code,
            details: details,
          );
        } else if (statusCode >= 500) {
          return ServerException(message, code: code, details: details);
        } else {
          return ApiException(
            message,
            statusCode: statusCode,
            code: code,
            details: details,
          );
        }
    }
  }

  static AppException fromException(Exception exception) {
    if (exception is AppException) {
      return exception;
    }

    // Handle common Dart exceptions
    if (exception.toString().contains('SocketException') ||
        exception.toString().contains('HandshakeException')) {
      return const NetworkException('Erreur de connexion réseau');
    }

    if (exception.toString().contains('TimeoutException')) {
      return const TimeoutException('Délai d\'attente dépassé');
    }

    if (exception.toString().contains('FormatException')) {
      return const ValidationException('Format de données invalide');
    }

    // Default to generic exception
    return NetworkException(exception.toString());
  }
}
