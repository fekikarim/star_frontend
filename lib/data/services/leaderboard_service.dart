import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/leaderboard.dart';
import 'package:star_frontend/data/models/user_position.dart';
import 'package:star_frontend/data/services/api_service.dart';

/// Service for managing leaderboards
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();
  
  final ApiService _apiService = ApiService();
  
  /// Get global leaderboard
  Future<Leaderboard> getGlobalLeaderboard({int limit = 50}) async {
    try {
      AppLogger.info('Fetching global leaderboard');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/leaderboard/global?limit=$limit',
      );
      
      final leaderboard = Leaderboard.fromJson(response['data']);
      
      AppLogger.info('Fetched global leaderboard with ${leaderboard.entries.length} entries');
      return leaderboard;
    } catch (e) {
      AppLogger.error('Failed to fetch global leaderboard', e);
      rethrow;
    }
  }
  
  /// Get weekly leaderboard
  Future<Leaderboard> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      AppLogger.info('Fetching weekly leaderboard');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/leaderboard/weekly?limit=$limit',
      );
      
      final leaderboard = Leaderboard.fromJson(response['data']);
      
      AppLogger.info('Fetched weekly leaderboard with ${leaderboard.entries.length} entries');
      return leaderboard;
    } catch (e) {
      AppLogger.error('Failed to fetch weekly leaderboard', e);
      rethrow;
    }
  }
  
  /// Get monthly leaderboard
  Future<Leaderboard> getMonthlyLeaderboard({int limit = 50}) async {
    try {
      AppLogger.info('Fetching monthly leaderboard');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/leaderboard/monthly?limit=$limit',
      );
      
      final leaderboard = Leaderboard.fromJson(response['data']);
      
      AppLogger.info('Fetched monthly leaderboard with ${leaderboard.entries.length} entries');
      return leaderboard;
    } catch (e) {
      AppLogger.error('Failed to fetch monthly leaderboard', e);
      rethrow;
    }
  }
  
  /// Get user position in leaderboard
  Future<UserPosition> getUserPosition(String userId, {String type = 'global'}) async {
    try {
      AppLogger.info('Fetching user position for: $userId ($type)');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/leaderboard/position/$userId?type=$type',
      );
      
      final position = UserPosition.fromJson(response['data']);
      
      AppLogger.info('User position: ${position.position}');
      return position;
    } catch (e) {
      AppLogger.error('Failed to fetch user position: $userId', e);
      rethrow;
    }
  }
  
  /// Get leaderboard by type
  Future<Leaderboard> getLeaderboardByType(LeaderboardType type, {int limit = 50}) async {
    switch (type) {
      case LeaderboardType.global:
        return getGlobalLeaderboard(limit: limit);
      case LeaderboardType.weekly:
        return getWeeklyLeaderboard(limit: limit);
      case LeaderboardType.monthly:
        return getMonthlyLeaderboard(limit: limit);
    }
  }
}
