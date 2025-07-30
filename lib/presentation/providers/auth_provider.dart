import 'package:flutter/foundation.dart';
import 'package:star_frontend/core/errors/error_handler.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/user.dart';
import 'package:star_frontend/data/services/auth_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  
  /// Get current loading state
  bool get isLoading => _isLoading;
  
  /// Get initialization state
  bool get isInitialized => _isInitialized;
  
  /// Get current error message
  String? get errorMessage => _errorMessage;
  
  /// Get current authenticated user
  User? get currentUser => _authService.currentUser;
  
  /// Get current authentication token
  String? get currentToken => _authService.currentToken;
  
  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;
  
  /// Check if user is admin
  bool get isAdmin => _authService.isAdmin;
  
  /// Check if user is participant
  bool get isParticipant => _authService.isParticipant;
  
  /// Get user display name
  String get userDisplayName => _authService.userDisplayName;
  
  /// Get user initials
  String get userInitials => _authService.userInitials;
  
  /// Get user email
  String get userEmail => _authService.userEmail;
  
  /// Get user ID
  String get userId => _authService.userId;
  
  /// Initialize the auth provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.initialize();
      _isInitialized = true;
      AppLogger.auth('AuthProvider initialized', 'Authenticated: $isAuthenticated');
    } catch (e) {
      _setError('Failed to initialize authentication');
      AppLogger.error('Failed to initialize AuthProvider', e);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Login with email and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      AppLogger.auth('Login attempt', email);
      
      final response = await _authService.login(email, password);
      
      AppLogger.auth('Login successful', email);
      notifyListeners();
      
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      AppLogger.auth('Login failed', '$email - $errorMessage');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout current user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    
    try {
      AppLogger.auth('Logout attempt', userEmail);
      
      await _authService.logout();
      
      AppLogger.auth('Logout successful');
      notifyListeners();
      
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      AppLogger.error('Logout failed', e);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh authentication token
  Future<void> refreshToken() async {
    if (!isAuthenticated) return;
    
    try {
      AppLogger.auth('Token refresh attempt');
      
      await _authService.refreshToken();
      
      AppLogger.auth('Token refresh successful');
      notifyListeners();
      
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      AppLogger.auth('Token refresh failed', errorMessage);
      
      // If token refresh fails, logout user
      await logout();
    }
  }
  
  /// Validate current token
  Future<bool> validateToken() async {
    if (!isAuthenticated) return false;
    
    try {
      AppLogger.auth('Token validation attempt');
      
      final isValid = await _authService.validateToken();
      
      if (!isValid) {
        AppLogger.auth('Token validation failed - logging out');
        await logout();
      } else {
        AppLogger.auth('Token validation successful');
      }
      
      return isValid;
    } catch (e) {
      AppLogger.auth('Token validation error', e.toString());
      await logout();
      return false;
    }
  }
  
  /// Get current user profile
  Future<void> getCurrentUserProfile() async {
    if (!isAuthenticated) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      AppLogger.auth('Fetching user profile');
      
      await _authService.getCurrentUserProfile();
      
      AppLogger.auth('User profile fetched successfully');
      notifyListeners();
      
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      AppLogger.error('Failed to fetch user profile', e);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (!isAuthenticated) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      AppLogger.auth('Updating user profile');
      
      await _authService.updateUserProfile(updates);
      
      AppLogger.auth('User profile updated successfully');
      notifyListeners();
      
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      AppLogger.error('Failed to update user profile', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (!isAuthenticated) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      AppLogger.auth('Changing password');
      
      await _authService.changePassword(currentPassword, newPassword);
      
      AppLogger.auth('Password changed successfully');
      
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      AppLogger.error('Failed to change password', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check if user has specific role
  bool hasRole(String role) {
    return _authService.hasRole(role);
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  /// Clear all state (for testing)
  void clear() {
    _isLoading = false;
    _isInitialized = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Get user avatar URL or initials
  String getUserAvatar() {
    final user = currentUser;
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return user.avatarUrl!;
    }
    return userInitials;
  }
  
  /// Get user status text
  String getUserStatus() {
    if (!isAuthenticated) return 'Non connecté';
    if (isAdmin) return 'Administrateur';
    if (isParticipant) return 'Participant';
    return 'Utilisateur';
  }
  
  /// Check if user profile is complete
  bool get isProfileComplete {
    final user = currentUser;
    if (user == null) return false;
    
    return user.nom.isNotEmpty && 
           user.email.isNotEmpty;
  }
  
  /// Get profile completion percentage
  double get profileCompletionPercentage {
    if (!isAuthenticated) return 0.0;
    
    final user = currentUser!;
    int completedFields = 0;
    int totalFields = 3; // nom, email, role
    
    if (user.nom.isNotEmpty) completedFields++;
    if (user.email.isNotEmpty) completedFields++;
    if (user.role.isNotEmpty) completedFields++;
    
    return completedFields / totalFields;
  }
  
  /// Auto-refresh token periodically
  void startTokenRefreshTimer() {
    // In a real app, you might want to implement a timer
    // that periodically refreshes the token before it expires
    AppLogger.auth('Token refresh timer started');
  }
  
  /// Stop token refresh timer
  void stopTokenRefreshTimer() {
    AppLogger.auth('Token refresh timer stopped');
  }
}
