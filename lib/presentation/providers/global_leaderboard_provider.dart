import 'package:flutter/foundation.dart';
import 'package:star_frontend/data/models/leaderboard.dart';
import 'package:star_frontend/data/services/leaderboard_service.dart';
import 'package:star_frontend/core/utils/logger.dart';

/// Provider pour gérer les classements globaux (global, hebdomadaire, mensuel)
class GlobalLeaderboardProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();

  // État
  Leaderboard? _globalLeaderboard;
  Leaderboard? _weeklyLeaderboard;
  Leaderboard? _monthlyLeaderboard;
  
  bool _isLoadingGlobal = false;
  bool _isLoadingWeekly = false;
  bool _isLoadingMonthly = false;
  
  String? _errorGlobal;
  String? _errorWeekly;
  String? _errorMonthly;

  // Getters
  Leaderboard? get globalLeaderboard => _globalLeaderboard;
  Leaderboard? get weeklyLeaderboard => _weeklyLeaderboard;
  Leaderboard? get monthlyLeaderboard => _monthlyLeaderboard;
  
  bool get isLoadingGlobal => _isLoadingGlobal;
  bool get isLoadingWeekly => _isLoadingWeekly;
  bool get isLoadingMonthly => _isLoadingMonthly;
  
  String? get errorGlobal => _errorGlobal;
  String? get errorWeekly => _errorWeekly;
  String? get errorMonthly => _errorMonthly;

  /// Charge le classement global
  Future<void> loadGlobalLeaderboard({int limit = 50}) async {
    _isLoadingGlobal = true;
    _errorGlobal = null;
    notifyListeners();

    try {
      AppLogger.info('Loading global leaderboard');
      _globalLeaderboard = await _leaderboardService.getGlobalLeaderboard(limit: limit);
      AppLogger.info('Global leaderboard loaded successfully');
    } catch (e) {
      _errorGlobal = 'Erreur lors du chargement du classement global';
      AppLogger.error('Failed to load global leaderboard', e);
    } finally {
      _isLoadingGlobal = false;
      notifyListeners();
    }
  }

  /// Charge le classement hebdomadaire
  Future<void> loadWeeklyLeaderboard({int limit = 50}) async {
    _isLoadingWeekly = true;
    _errorWeekly = null;
    notifyListeners();

    try {
      AppLogger.info('Loading weekly leaderboard');
      _weeklyLeaderboard = await _leaderboardService.getWeeklyLeaderboard(limit: limit);
      AppLogger.info('Weekly leaderboard loaded successfully');
    } catch (e) {
      _errorWeekly = 'Erreur lors du chargement du classement hebdomadaire';
      AppLogger.error('Failed to load weekly leaderboard', e);
    } finally {
      _isLoadingWeekly = false;
      notifyListeners();
    }
  }

  /// Charge le classement mensuel
  Future<void> loadMonthlyLeaderboard({int limit = 50}) async {
    _isLoadingMonthly = true;
    _errorMonthly = null;
    notifyListeners();

    try {
      AppLogger.info('Loading monthly leaderboard');
      _monthlyLeaderboard = await _leaderboardService.getMonthlyLeaderboard(limit: limit);
      AppLogger.info('Monthly leaderboard loaded successfully');
    } catch (e) {
      _errorMonthly = 'Erreur lors du chargement du classement mensuel';
      AppLogger.error('Failed to load monthly leaderboard', e);
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  /// Charge tous les classements
  Future<void> loadAllLeaderboards({int limit = 50}) async {
    await Future.wait([
      loadGlobalLeaderboard(limit: limit),
      loadWeeklyLeaderboard(limit: limit),
      loadMonthlyLeaderboard(limit: limit),
    ]);
  }

  /// Rafraîchit un classement spécifique
  Future<void> refreshLeaderboard(LeaderboardType type, {int limit = 50}) async {
    switch (type) {
      case LeaderboardType.global:
        await loadGlobalLeaderboard(limit: limit);
        break;
      case LeaderboardType.weekly:
        await loadWeeklyLeaderboard(limit: limit);
        break;
      case LeaderboardType.monthly:
        await loadMonthlyLeaderboard(limit: limit);
        break;
    }
  }

  /// Obtient le classement selon le type
  Leaderboard? getLeaderboard(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.global:
        return _globalLeaderboard;
      case LeaderboardType.weekly:
        return _weeklyLeaderboard;
      case LeaderboardType.monthly:
        return _monthlyLeaderboard;
    }
  }

  /// Vérifie si un classement est en cours de chargement
  bool isLoading(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.global:
        return _isLoadingGlobal;
      case LeaderboardType.weekly:
        return _isLoadingWeekly;
      case LeaderboardType.monthly:
        return _isLoadingMonthly;
    }
  }

  /// Obtient l'erreur pour un type de classement
  String? getError(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.global:
        return _errorGlobal;
      case LeaderboardType.weekly:
        return _errorWeekly;
      case LeaderboardType.monthly:
        return _errorMonthly;
    }
  }

  /// Nettoie les erreurs
  void clearErrors() {
    _errorGlobal = null;
    _errorWeekly = null;
    _errorMonthly = null;
    notifyListeners();
  }

  /// Nettoie toutes les données
  void clear() {
    _globalLeaderboard = null;
    _weeklyLeaderboard = null;
    _monthlyLeaderboard = null;
    clearErrors();
  }
}
