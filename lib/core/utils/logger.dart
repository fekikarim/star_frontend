import 'package:logger/logger.dart';
import 'package:star_frontend/core/config/app_config.dart';

/// Custom logger utility for the application
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: AppConfig.enableLogging ? Level.debug : Level.off,
  );
  
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
  
  // API specific logging
  static void apiRequest(String method, String url, [Map<String, dynamic>? data]) {
    if (AppConfig.enableLogging) {
      _logger.d('🌐 API Request: $method $url', error: data);
    }
  }
  
  static void apiResponse(String method, String url, int statusCode, [dynamic data]) {
    if (AppConfig.enableLogging) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      _logger.d('$emoji API Response: $method $url [$statusCode]', error: data);
    }
  }
  
  static void apiError(String method, String url, dynamic error, [StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.e('🚨 API Error: $method $url', error: error, stackTrace: stackTrace);
    }
  }
  
  // Navigation logging
  static void navigation(String from, String to) {
    if (AppConfig.enableLogging) {
      _logger.d('🧭 Navigation: $from → $to');
    }
  }
  
  // Authentication logging
  static void auth(String action, [String? details]) {
    if (AppConfig.enableLogging) {
      _logger.d('🔐 Auth: $action${details != null ? ' - $details' : ''}');
    }
  }
  
  // Performance logging
  static void performance(String operation, Duration duration) {
    if (AppConfig.enableLogging) {
      _logger.d('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }
}
