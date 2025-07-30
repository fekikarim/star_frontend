import 'package:star_frontend/core/constants/app_constants.dart';

/// Application configuration and environment settings
class AppConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  static bool get isStaging => _environment == 'staging';
  
  // API Configuration based on environment
  static String get baseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.starchallenge.com/api';
      case 'staging':
        return 'https://staging-api.starchallenge.com/api';
      case 'development':
      default:
        return AppConstants.baseUrl;
    }
  }
  
  // Debug settings
  static bool get enableLogging => isDevelopment || isStaging;
  static bool get enableDebugMode => isDevelopment;
  
  // Feature flags
  static bool get enableAnalytics => isProduction || isStaging;
  static bool get enableCrashReporting => isProduction || isStaging;
  static bool get enablePerformanceMonitoring => isProduction || isStaging;
  
  // Cache settings
  static Duration get cacheExpiration => const Duration(hours: 1);
  static int get maxCacheSize => 50 * 1024 * 1024; // 50MB
  
  // Network settings
  static Duration get connectionTimeout => AppConstants.connectionTimeout;
  static Duration get receiveTimeout => AppConstants.receiveTimeout;
  static int get maxRetries => 3;
  
  // UI settings
  static bool get enableAnimations => true;
  static bool get enableHapticFeedback => true;
  static bool get enableDarkMode => true;
  
  // Security settings
  static bool get enableBiometricAuth => true;
  static Duration get sessionTimeout => const Duration(hours: 24);
  static int get maxLoginAttempts => 5;
  
  // Pagination settings
  static int get defaultPageSize => AppConstants.defaultPageSize;
  static int get maxPageSize => AppConstants.maxPageSize;
  
  // Image settings
  static int get maxImageSize => 5 * 1024 * 1024; // 5MB
  static List<String> get supportedImageFormats => ['jpg', 'jpeg', 'png', 'webp'];
  
  // Validation settings
  static int get minPasswordLength => 6;
  static int get maxPasswordLength => 128;
  static int get maxNameLength => 100;
  static int get maxDescriptionLength => 500;
  
  // Print configuration summary
  static void printConfig() {
    if (enableLogging) {
      print('=== App Configuration ===');
      print('Environment: $_environment');
      print('Base URL: $baseUrl');
      print('Debug Mode: $enableDebugMode');
      print('Logging: $enableLogging');
      print('Analytics: $enableAnalytics');
      print('========================');
    }
  }
}
