/// Application constants and configuration
class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const String apiVersion = 'v1';
  
  // Authentication
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  
  // API Endpoints
  static const String loginEndpoint = '/utilisateurs/login';
  static const String usersEndpoint = '/utilisateurs';
  static const String challengesEndpoint = '/challenges';
  static const String participantsEndpoint = '/participants';
  static const String performancesEndpoint = '/performances';
  static const String etoilesEndpoint = '/etoiles';
  static const String paliersEndpoint = '/paliers';
  static const String recompensesEndpoint = '/recompenses';
  static const String criteresEndpoint = '/criteres';
  static const String gagnantsEndpoint = '/gagnants';
  static const String statisticsEndpoint = '/stats';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
