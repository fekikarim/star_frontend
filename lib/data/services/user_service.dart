import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/user.dart';
import 'package:star_frontend/data/services/api_service.dart';

/// Service for managing users
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  
  final ApiService _apiService = ApiService();
  
  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      AppLogger.info('Fetching all users');
      
      final response = await _apiService.get<List<dynamic>>(
        AppConstants.usersEndpoint,
      );
      
      final users = response.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      
      AppLogger.info('Fetched ${users.length} users');
      return users;
    } catch (e) {
      AppLogger.error('Failed to fetch users', e);
      rethrow;
    }
  }
  
  /// Get user by ID
  Future<User> getUserById(String id) async {
    try {
      AppLogger.info('Fetching user: $id');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.usersEndpoint}/$id',
      );
      
      final user = User.fromJson(response);
      
      AppLogger.info('Fetched user: ${user.email}');
      return user;
    } catch (e) {
      AppLogger.error('Failed to fetch user: $id', e);
      rethrow;
    }
  }
  
  /// Create new user
  Future<User> createUser(CreateUserRequest request) async {
    try {
      AppLogger.info('Creating user: ${request.email}');
      
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.usersEndpoint,
        data: request.toJson(),
      );
      
      final user = User.fromJson(response);
      
      AppLogger.info('Created user: ${user.email}');
      return user;
    } catch (e) {
      AppLogger.error('Failed to create user: ${request.email}', e);
      rethrow;
    }
  }
  
  /// Update user
  Future<User> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      AppLogger.info('Updating user: $id');
      
      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.usersEndpoint}/$id',
        data: updates,
      );
      
      final user = User.fromJson(response);
      
      AppLogger.info('Updated user: ${user.email}');
      return user;
    } catch (e) {
      AppLogger.error('Failed to update user: $id', e);
      rethrow;
    }
  }
  
  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      AppLogger.info('Deleting user: $id');
      
      await _apiService.delete(
        '${AppConstants.usersEndpoint}/$id',
      );
      
      AppLogger.info('Deleted user: $id');
    } catch (e) {
      AppLogger.error('Failed to delete user: $id', e);
      rethrow;
    }
  }
  
  /// Check if email exists
  Future<bool> checkEmailExists(String email, {String? excludeUserId}) async {
    try {
      AppLogger.info('Checking email existence: $email');
      
      final endpoint = excludeUserId != null 
        ? '${AppConstants.usersEndpoint}/$excludeUserId/check-email'
        : '${AppConstants.usersEndpoint}/check-email';
      
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'email': email},
      );
      
      final exists = response['exists'] as bool? ?? false;
      
      AppLogger.info('Email $email exists: $exists');
      return exists;
    } catch (e) {
      AppLogger.error('Failed to check email: $email', e);
      return false;
    }
  }
  
  /// Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      AppLogger.info('Fetching users by role: $role');
      
      final allUsers = await getAllUsers();
      final filteredUsers = allUsers.where((user) => 
        user.role.toLowerCase() == role.toLowerCase()).toList();
      
      AppLogger.info('Found ${filteredUsers.length} users with role: $role');
      return filteredUsers;
    } catch (e) {
      AppLogger.error('Failed to fetch users by role: $role', e);
      rethrow;
    }
  }
  
  /// Get admin users
  Future<List<User>> getAdminUsers() async {
    return getUsersByRole('admin');
  }
  
  /// Get participant users
  Future<List<User>> getParticipantUsers() async {
    return getUsersByRole('participant');
  }
  
  /// Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    try {
      AppLogger.info('Searching users: $query');
      
      final allUsers = await getAllUsers();
      final searchResults = allUsers.where((user) => 
        user.nom.toLowerCase().contains(query.toLowerCase()) ||
        user.email.toLowerCase().contains(query.toLowerCase())).toList();
      
      AppLogger.info('Found ${searchResults.length} users matching: $query');
      return searchResults;
    } catch (e) {
      AppLogger.error('Failed to search users: $query', e);
      rethrow;
    }
  }
  
  /// Get user profile with additional data
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      AppLogger.info('Fetching user profile: $userId');
      
      final user = await getUserById(userId);
      
      // You can extend this to include additional profile data
      // like participation history, achievements, etc.
      final profile = {
        'user': user.toJson(),
        'isOnline': user.isOnline,
        'memberSince': user.createdAt?.toIso8601String(),
        'role': user.role,
        'isAdmin': user.isAdmin,
        'isParticipant': user.isParticipant,
      };
      
      AppLogger.info('Fetched profile for user: ${user.email}');
      return profile;
    } catch (e) {
      AppLogger.error('Failed to fetch user profile: $userId', e);
      rethrow;
    }
  }
  
  /// Update user profile
  Future<User> updateUserProfile(String userId, {
    String? nom,
    String? email,
  }) async {
    try {
      AppLogger.info('Updating user profile: $userId');
      
      final updates = <String, dynamic>{};
      if (nom != null) updates['nom'] = nom;
      if (email != null) updates['email'] = email;
      
      if (updates.isEmpty) {
        throw Exception('No updates provided');
      }
      
      final user = await updateUser(userId, updates);
      
      AppLogger.info('Updated profile for user: ${user.email}');
      return user;
    } catch (e) {
      AppLogger.error('Failed to update user profile: $userId', e);
      rethrow;
    }
  }
  
  /// Change user role (admin only)
  Future<User> changeUserRole(String userId, String newRole) async {
    try {
      AppLogger.info('Changing role for user: $userId to $newRole');
      
      final user = await updateUser(userId, {'role': newRole});
      
      AppLogger.info('Changed role for user: ${user.email} to $newRole');
      return user;
    } catch (e) {
      AppLogger.error('Failed to change role for user: $userId', e);
      rethrow;
    }
  }
  
  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      AppLogger.info('Calculating statistics for user: $userId');
      
      final user = await getUserById(userId);
      
      // Basic user statistics
      // In a real app, you might fetch additional data from other services
      final stats = {
        'user': user.toJson(),
        'memberSince': user.createdAt?.toIso8601String(),
        'accountAge': user.createdAt != null 
          ? DateTime.now().difference(user.createdAt!).inDays 
          : 0,
        'role': user.role,
        'isActive': true, // You could implement activity tracking
        'lastLogin': DateTime.now().toIso8601String(), // Placeholder
      };
      
      AppLogger.info('Calculated statistics for user: ${user.email}');
      return stats;
    } catch (e) {
      AppLogger.error('Failed to calculate statistics for user: $userId', e);
      rethrow;
    }
  }
  
  /// Validate user data
  Map<String, String> validateUserData({
    required String nom,
    required String email,
    String? password,
    required String role,
  }) {
    final errors = <String, String>{};
    
    // Validate name
    if (nom.trim().isEmpty) {
      errors['nom'] = 'Le nom est requis';
    } else if (nom.trim().length < 2) {
      errors['nom'] = 'Le nom doit contenir au moins 2 caractères';
    }
    
    // Validate email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.trim().isEmpty) {
      errors['email'] = 'L\'email est requis';
    } else if (!emailRegex.hasMatch(email.trim())) {
      errors['email'] = 'Format d\'email invalide';
    }
    
    // Validate password (if provided)
    if (password != null) {
      if (password.isEmpty) {
        errors['password'] = 'Le mot de passe est requis';
      } else if (password.length < 6) {
        errors['password'] = 'Le mot de passe doit contenir au moins 6 caractères';
      }
    }
    
    // Validate role
    final validRoles = ['admin', 'participant'];
    if (role.trim().isEmpty) {
      errors['role'] = 'Le rôle est requis';
    } else if (!validRoles.contains(role.toLowerCase())) {
      errors['role'] = 'Rôle invalide';
    }
    
    return errors;
  }
}
