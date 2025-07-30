import 'package:flutter/foundation.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/leaderboard.dart';
import 'package:star_frontend/data/models/user_position.dart';
import 'package:star_frontend/data/services/leaderboard_service.dart';

/// Provider for managing leaderboards
class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  
  // State
  Leaderboard? _globalLeaderboard;
  Leaderboard? _weeklyLeaderboard;
  Leaderboard? _monthlyLeaderboard;
  UserPosition? _userPosition;
  LeaderboardType _currentType = LeaderboardType.global;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Leaderboard? get globalLeaderboard => _globalLeaderboard;
  Leaderboard? get weeklyLeaderboard => _weeklyLeaderboard;
  Leaderboard? get monthlyLeaderboard => _monthlyLeaderboard;
  UserPosition? get userPosition => _userPosition;
  LeaderboardType get currentType => _currentType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get current leaderboard based on selected type
  Leaderboard? get currentLeaderboard {
    switch (_currentType) {
      case LeaderboardType.global:
        return _globalLeaderboard;
      case LeaderboardType.weekly:
        return _weeklyLeaderboard;
      case LeaderboardType.monthly:
        return _monthlyLeaderboard;
    }
  }
  
  /// Set current leaderboard type
  void setCurrentType(LeaderboardType type) {
    if (_currentType != type) {
      _currentType = type;
      notifyListeners();
      
      // Load leaderboard if not already loaded
      if (currentLeaderboard == null) {
        loadLeaderboard(type);
      }
    }
  }
  
  /// Load leaderboard by type
  Future<void> loadLeaderboard(LeaderboardType type, {int limit = 50}) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppLogger.info('Loading ${type.displayName} leaderboard');
      
      final leaderboard = await _leaderboardService.getLeaderboardByType(type, limit: limit);
      
      switch (type) {
        case LeaderboardType.global:
          _globalLeaderboard = leaderboard;
          break;
        case LeaderboardType.weekly:
          _weeklyLeaderboard = leaderboard;
          break;
        case LeaderboardType.monthly:
          _monthlyLeaderboard = leaderboard;
          break;
      }
      
      AppLogger.info('${type.displayName} leaderboard loaded successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load ${type.displayName} leaderboard', e);
      _setError('Impossible de charger le classement ${type.displayName.toLowerCase()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load user position in leaderboard
  Future<void> loadUserPosition(String userId, {LeaderboardType? type}) async {
    try {
      final leaderboardType = type ?? _currentType;
      
      AppLogger.info('Loading user position for: $userId (${leaderboardType.displayName})');
      
      final position = await _leaderboardService.getUserPosition(
        userId, 
        type: leaderboardType.apiValue
      );
      _userPosition = position;
      
      AppLogger.info('User position loaded: ${position.position}');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load user position', e);
      // Don't show error for user position as it's not critical
    }
  }
  
  /// Load all leaderboards
  Future<void> loadAllLeaderboards({int limit = 50}) async {
    await Future.wait([
      loadLeaderboard(LeaderboardType.global, limit: limit),
      loadLeaderboard(LeaderboardType.weekly, limit: limit),
      loadLeaderboard(LeaderboardType.monthly, limit: limit),
    ]);
  }
  
  /// Refresh current leaderboard
  Future<void> refreshCurrentLeaderboard() async {
    await loadLeaderboard(_currentType);
  }
  
  /// Refresh all data
  Future<void> refreshAll({String? userId, int limit = 50}) async {
    await loadAllLeaderboards(limit: limit);
    if (userId != null) {
      await loadUserPosition(userId);
    }
  }
  
  /// Clear all data
  void clearData() {
    _globalLeaderboard = null;
    _weeklyLeaderboard = null;
    _monthlyLeaderboard = null;
    _userPosition = null;
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
  
  /// Get top 3 users from current leaderboard
  List<LeaderboardEntry> get topThree {
    final leaderboard = currentLeaderboard;
    if (leaderboard == null) return [];
    return leaderboard.entries.take(3).toList();
  }
  
  /// Get remaining users (after top 3) from current leaderboard
  List<LeaderboardEntry> get remainingUsers {
    final leaderboard = currentLeaderboard;
    if (leaderboard == null) return [];
    return leaderboard.entries.skip(3).toList();
  }
  
  /// Check if current leaderboard has data
  bool get hasData => currentLeaderboard?.entries.isNotEmpty ?? false;
  
  /// Get total number of users in current leaderboard
  int get totalUsers => currentLeaderboard?.entries.length ?? 0;
  
  /// Check if user is in top 3
  bool get isUserInTopThree => _userPosition?.isTopThree ?? false;
  
  /// Check if user is in top 10
  bool get isUserInTopTen => _userPosition?.isTopTen ?? false;
  
  /// Get user's current rank
  int? get userRank => _userPosition?.position;
  
  /// Get user's current score
  int? get userScore => _userPosition?.score;
}
