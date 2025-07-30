import 'package:flutter/foundation.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/user_stats.dart';
import 'package:star_frontend/data/models/activity.dart';
import 'package:star_frontend/data/models/achievement.dart';
import 'package:star_frontend/data/services/user_stats_service.dart';

/// Provider for managing user statistics and activities
class UserStatsProvider with ChangeNotifier {
  final UserStatsService _userStatsService = UserStatsService();
  
  // State
  UserStats? _userStats;
  List<Activity> _activities = [];
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  UserStats? get userStats => _userStats;
  List<Activity> get activities => _activities;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load user overview statistics
  Future<void> loadUserOverview(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppLogger.info('Loading user overview for: $userId');
      
      final stats = await _userStatsService.getUserOverview(userId);
      _userStats = stats;
      
      AppLogger.info('User overview loaded successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load user overview', e);
      _setError('Impossible de charger les statistiques utilisateur');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load user recent activities
  Future<void> loadUserActivities(String userId, {int limit = 10}) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppLogger.info('Loading user activities for: $userId');
      
      final activities = await _userStatsService.getUserActivities(userId, limit: limit);
      _activities = activities;
      
      AppLogger.info('User activities loaded successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load user activities', e);
      _setError('Impossible de charger les activités récentes');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load user achievements
  Future<void> loadUserAchievements(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppLogger.info('Loading user achievements for: $userId');
      
      final achievements = await _userStatsService.getUserAchievements(userId);
      _achievements = achievements;
      
      AppLogger.info('User achievements loaded successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load user achievements', e);
      _setError('Impossible de charger les accomplissements');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load all user data
  Future<void> loadAllUserData(String userId) async {
    await Future.wait([
      loadUserOverview(userId),
      loadUserActivities(userId),
      loadUserAchievements(userId),
    ]);
  }
  
  /// Refresh user data
  Future<void> refreshUserData(String userId) async {
    await loadAllUserData(userId);
  }
  
  /// Clear all data
  void clearData() {
    _userStats = null;
    _activities = [];
    _achievements = [];
    _clearError();
    notifyListeners();
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  // Computed properties
  
  /// Get total stars from user stats
  int get totalStars => _userStats?.stats.totalStars ?? 0;
  
  /// Get current level name
  String get currentLevelName => _userStats?.level.current.nom ?? 'Débutant';
  
  /// Get progress percentage to next level
  int get levelProgress => _userStats?.level.progress ?? 0;
  
  /// Get stars needed for next level
  int get starsToNextLevel => _userStats?.level.starsToNext ?? 0;
  
  /// Get success rate percentage
  int get successRate => _userStats?.stats.successRate ?? 0;
  
  /// Get active challenges count
  int get activeChallenges => _userStats?.stats.activeChallenges ?? 0;
  
  /// Get weekly stars count
  int get weeklyStars => _userStats?.stats.weeklyStars ?? 0;
  
  /// Get recent activities (last 5)
  List<Activity> get recentActivities => _activities.take(5).toList();
  
  /// Get latest achievements (last 3)
  List<Achievement> get latestAchievements => _achievements.take(3).toList();
  
  /// Check if user has any achievements
  bool get hasAchievements => _achievements.isNotEmpty;
  
  /// Check if user has any activities
  bool get hasActivities => _activities.isNotEmpty;
}
