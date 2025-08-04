import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/user.dart';
import 'package:star_frontend/data/services/api_service.dart';
import 'package:star_frontend/data/services/storage_service.dart';

/// Authentication service for managing user authentication
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  String? _currentToken;

  /// Get current authenticated user
  User? get currentUser => _currentUser;

  /// Get current authentication token
  String? get currentToken => _currentToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _currentToken != null;

  /// Initialize auth service and check for existing session
  Future<void> initialize() async {
    try {
      // Try to restore session from storage
      await _restoreSession();
      AppLogger.auth(
        'AuthService initialized',
        'User: ${_currentUser?.email ?? 'None'}',
      );
    } catch (e) {
      AppLogger.error('Failed to initialize AuthService', e);
    }
  }

  /// Login with email and password
  Future<LoginResponse> login(String email, String password) async {
    try {
      AppLogger.auth('Login attempt', email);

      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _apiService.post<LoginResponse>(
        AppConstants.loginEndpoint,
        data: loginRequest.toJson(),
        fromJson: (json) =>
            LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      // Save authentication data
      await _saveSession(response.token, response.utilisateur);

      AppLogger.auth('Login successful', email);
      return response;
    } catch (e) {
      AppLogger.auth('Login failed', '$email - $e');
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      AppLogger.auth('Logout', _currentUser?.email ?? 'Unknown');

      // Clear session data
      await _clearSession();

      AppLogger.auth('Logout successful');
    } catch (e) {
      AppLogger.error('Logout failed', e);
      // Still clear local session even if server logout fails
      await _clearSession();
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    try {
      if (_currentToken == null) {
        throw Exception('No token to refresh');
      }

      AppLogger.auth('Refreshing token');

      // Note: Implement token refresh endpoint if available in backend
      // For now, we'll just validate the current token
      await _validateToken();
    } catch (e) {
      AppLogger.auth('Token refresh failed', e.toString());
      await _clearSession();
      rethrow;
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    try {
      if (_currentToken == null) return false;

      await _validateToken();
      return true;
    } catch (e) {
      AppLogger.auth('Token validation failed', e.toString());
      await _clearSession();
      return false;
    }
  }

  /// Get current user profile
  Future<User> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _apiService.get<User>(
        '${AppConstants.usersEndpoint}/${_currentUser!.id}',
        fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
      );

      // Update current user
      _currentUser = response;
      await _storageService.saveUserData(response.toJson());

      return response;
    } catch (e) {
      AppLogger.error('Failed to get user profile', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Make the update request
      await _apiService.put(
        '${AppConstants.usersEndpoint}/${_currentUser!.id}',
        data: updates,
      );

      // Update current user locally
      final updatedUser = User(
        id: _currentUser!.id,
        nom: updates['nom'] ?? _currentUser!.nom,
        email: _currentUser!.email,
        role: _currentUser!.role,
        createdAt: _currentUser!.createdAt,
      );

      _currentUser = updatedUser;
      await _storageService.saveUserData(updatedUser.toJson());

      AppLogger.auth('Profile updated', _currentUser!.email);
      return updatedUser;
    } catch (e) {
      AppLogger.error('Failed to update user profile', e);
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _apiService.put(
        '${AppConstants.usersEndpoint}/${_currentUser!.id}/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      AppLogger.auth('Password changed', _currentUser!.email);
    } catch (e) {
      AppLogger.error('Failed to change password', e);
      rethrow;
    }
  }

  /// Save authentication session
  Future<void> _saveSession(String token, User user) async {
    _currentToken = token;
    _currentUser = user;

    // Save to secure storage
    await _storageService.saveAuthToken(token);
    await _storageService.saveUserData(user.toJson());

    // Set token in API service
    _apiService.setAuthToken(token);
  }

  /// Restore authentication session from storage
  Future<void> _restoreSession() async {
    final token = await _storageService.getAuthToken();
    final userData = _storageService.getUserData();

    if (token != null && userData != null) {
      _currentToken = token;
      _currentUser = User.fromJson(userData);

      // Set token in API service
      _apiService.setAuthToken(token);

      // Validate the restored session
      final isValid = await validateToken();
      if (!isValid) {
        await _clearSession();
      }
    }
  }

  /// Clear authentication session
  Future<void> _clearSession() async {
    _currentToken = null;
    _currentUser = null;

    // Clear from storage
    await _storageService.deleteAuthToken();
    await _storageService.deleteUserData();

    // Clear token from API service
    _apiService.clearAuthToken();
  }

  /// Validate token with server
  Future<void> _validateToken() async {
    // Make a simple authenticated request to validate token
    await _apiService.get('${AppConstants.usersEndpoint}/${_currentUser!.id}');
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is participant
  bool get isParticipant => hasRole('participant');

  /// Get user display name
  String get userDisplayName => _currentUser?.displayName ?? 'Utilisateur';

  /// Get user initials
  String get userInitials => _currentUser?.initials ?? 'U';

  /// Get user email
  String get userEmail => _currentUser?.email ?? '';

  /// Get user ID
  String get userId => _currentUser?.id ?? '';
}
