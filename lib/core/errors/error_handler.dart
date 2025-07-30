import 'package:flutter/material.dart';
import 'package:star_frontend/core/errors/app_exceptions.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/core/utils/logger.dart';

/// Global error handler for the application
class ErrorHandler {
  /// Handle and convert exceptions to user-friendly messages
  static String getErrorMessage(dynamic error) {
    AppLogger.error('Error occurred', error);
    
    if (error is AppException) {
      return _getAppExceptionMessage(error);
    }
    
    if (error is Exception) {
      return _getGenericExceptionMessage(error);
    }
    
    return AppStrings.errorGeneric;
  }
  
  /// Get user-friendly message for AppException
  static String _getAppExceptionMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return AppStrings.errorNetwork;
      case AuthException:
      case UnauthorizedException:
        return AppStrings.errorUnauthorized;
      case ValidationException:
        return AppStrings.errorValidation;
      case NotFoundException:
        return AppStrings.errorNotFound;
      case TimeoutException:
        return AppStrings.errorTimeout;
      case ServerException:
      case InternalServerErrorException:
        return AppStrings.errorServer;
      case ApiException:
        final apiException = exception as ApiException;
        return _getApiExceptionMessage(apiException);
      default:
        return exception.message.isNotEmpty ? exception.message : AppStrings.errorGeneric;
    }
  }
  
  /// Get user-friendly message for API exceptions based on status code
  static String _getApiExceptionMessage(ApiException exception) {
    switch (exception.statusCode) {
      case 400:
        return 'Requête invalide';
      case 401:
        return AppStrings.errorUnauthorized;
      case 403:
        return 'Accès interdit';
      case 404:
        return AppStrings.errorNotFound;
      case 409:
        return 'Conflit de données';
      case 422:
        return AppStrings.errorValidation;
      case 429:
        return 'Trop de requêtes, veuillez réessayer plus tard';
      case 500:
        return AppStrings.errorServer;
      case 502:
        return 'Service temporairement indisponible';
      case 503:
        return 'Service en maintenance';
      default:
        return exception.message.isNotEmpty ? exception.message : AppStrings.errorGeneric;
    }
  }
  
  /// Get user-friendly message for generic exceptions
  static String _getGenericExceptionMessage(Exception exception) {
    final errorString = exception.toString().toLowerCase();
    
    if (errorString.contains('socket') || errorString.contains('network')) {
      return AppStrings.errorNetwork;
    }
    
    if (errorString.contains('timeout')) {
      return AppStrings.errorTimeout;
    }
    
    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Format de données invalide';
    }
    
    if (errorString.contains('permission')) {
      return 'Permissions insuffisantes';
    }
    
    return AppStrings.errorGeneric;
  }
  
  /// Show error dialog
  static void showErrorDialog(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
    final message = getErrorMessage(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text(AppStrings.retry),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
  
  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.ok,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Handle authentication errors
  static void handleAuthError(BuildContext context, dynamic error) {
    AppLogger.auth('Authentication error', error.toString());
    
    if (error is UnauthorizedException || error is AuthException) {
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      showErrorSnackBar(context, error);
    }
  }
  
  /// Handle network errors with retry option
  static void handleNetworkError(BuildContext context, dynamic error, VoidCallback onRetry) {
    if (error is NetworkException || error is TimeoutException) {
      showErrorDialog(context, error, onRetry: onRetry);
    } else {
      showErrorSnackBar(context, error);
    }
  }
  
  /// Log error for debugging and analytics
  static void logError(dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.error(
      'Application error',
      error,
      stackTrace,
    );
    
    // Here you could also send to crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
    if (context != null) {
      AppLogger.debug('Error context', context);
    }
  }
  
  /// Check if error is recoverable
  static bool isRecoverableError(dynamic error) {
    if (error is NetworkException || 
        error is TimeoutException ||
        error is ServerException) {
      return true;
    }
    
    if (error is ApiException) {
      // 5xx errors are usually recoverable
      return error.statusCode != null && error.statusCode! >= 500;
    }
    
    return false;
  }
  
  /// Get error severity level
  static ErrorSeverity getErrorSeverity(dynamic error) {
    if (error is AuthException || error is UnauthorizedException) {
      return ErrorSeverity.critical;
    }
    
    if (error is NetworkException || error is TimeoutException) {
      return ErrorSeverity.warning;
    }
    
    if (error is ValidationException) {
      return ErrorSeverity.info;
    }
    
    if (error is ServerException || error is InternalServerErrorException) {
      return ErrorSeverity.high;
    }
    
    return ErrorSeverity.medium;
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  medium,
  high,
  critical,
}
