import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/user_stats.dart';
import 'package:star_frontend/data/models/activity.dart';
import 'package:star_frontend/data/models/achievement.dart';
import 'package:star_frontend/data/services/api_service.dart';

/// Service for managing user statistics and activities
class UserStatsService {
  static final UserStatsService _instance = UserStatsService._internal();
  factory UserStatsService() => _instance;
  UserStatsService._internal();
  
  final ApiService _apiService = ApiService();
  
  /// Get user overview statistics
  Future<UserStats> getUserOverview(String userId) async {
    try {
      AppLogger.info('Fetching user overview for: $userId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/user-stats/overview/$userId',
      );
      
      final userStats = UserStats.fromJson(response['data']);
      
      AppLogger.info('Fetched user overview successfully');
      return userStats;
    } catch (e) {
      AppLogger.error('Failed to fetch user overview: $userId', e);
      rethrow;
    }
  }
  
  /// Get user recent activities
  Future<List<Activity>> getUserActivities(String userId, {int limit = 10}) async {
    try {
      AppLogger.info('Fetching user activities for: $userId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/user-stats/activities/$userId?limit=$limit',
      );
      
      final activities = (response['data'] as List)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Fetched ${activities.length} activities');
      return activities;
    } catch (e) {
      AppLogger.error('Failed to fetch user activities: $userId', e);
      rethrow;
    }
  }
  
  /// Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      AppLogger.info('Fetching user achievements for: $userId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/user-stats/achievements/$userId',
      );
      
      final data = response['data'] as Map<String, dynamic>;
      final achievements = <Achievement>[];
      
      // Add rewards as achievements
      if (data['rewards'] != null) {
        achievements.addAll(
          (data['rewards'] as List)
              .map((json) => Achievement.fromReward(json as Map<String, dynamic>))
        );
      }
      
      // Add special badges as achievements
      if (data['specialBadges'] != null) {
        achievements.addAll(
          (data['specialBadges'] as List)
              .map((json) => Achievement.fromBadge(json as Map<String, dynamic>))
        );
      }
      
      AppLogger.info('Fetched ${achievements.length} achievements');
      return achievements;
    } catch (e) {
      AppLogger.error('Failed to fetch user achievements: $userId', e);
      rethrow;
    }
  }
}
