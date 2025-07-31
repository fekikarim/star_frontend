import 'package:flutter/foundation.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/challenge_with_details.dart';
import 'package:star_frontend/data/services/challenge_service.dart';

/// Provider for managing challenges
class ChallengeProvider with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  
  // State
  List<ChallengeWithDetails> _allChallenges = [];
  List<ChallengeWithDetails> _pendingChallenges = [];
  List<ChallengeWithDetails> _activeChallenges = [];
  List<ChallengeWithDetails> _finishedChallenges = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  
  // Getters
  List<ChallengeWithDetails> get allChallenges => _allChallenges;
  List<ChallengeWithDetails> get pendingChallenges => _pendingChallenges;
  List<ChallengeWithDetails> get activeChallenges => _activeChallenges;
  List<ChallengeWithDetails> get finishedChallenges => _finishedChallenges;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Set current user ID
  void setCurrentUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      // Reload challenges with new user context
      if (userId != null) {
        loadAllChallenges();
      }
    }
  }
  
  /// Load all challenges
  Future<void> loadAllChallenges() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppLogger.info('Loading all challenges for user: $_currentUserId');
      
      final challenges = await _challengeService.getChallengesForApp(
        userId: _currentUserId,
      );
      
      _allChallenges = challenges;
      _categorizesChallenges();
      
      AppLogger.info('Loaded ${challenges.length} challenges');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load challenges', e);
      _setError('Impossible de charger les challenges');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load challenges by status
  Future<void> loadChallengesByStatus(String status) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppLogger.info('Loading challenges with status: $status');
      
      final challenges = await _challengeService.getChallengesByStatusForApp(
        status,
        userId: _currentUserId,
      );
      
      switch (status.toLowerCase()) {
        case 'en_attente':
          _pendingChallenges = challenges;
          break;
        case 'en_cours':
          _activeChallenges = challenges;
          break;
        case 'termine':
        case 'terminé':
          _finishedChallenges = challenges;
          break;
      }
      
      AppLogger.info('Loaded ${challenges.length} challenges with status: $status');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load challenges by status: $status', e);
      _setError('Impossible de charger les challenges $status');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh all challenges
  Future<void> refreshChallenges() async {
    await loadAllChallenges();
  }
  
  /// Clear all data
  void clearData() {
    _allChallenges = [];
    _pendingChallenges = [];
    _activeChallenges = [];
    _finishedChallenges = [];
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
  
  void _categorizesChallenges() {
    _pendingChallenges = _allChallenges.where((c) => c.isPending).toList();
    _activeChallenges = _allChallenges.where((c) => c.isActive).toList();
    _finishedChallenges = _allChallenges.where((c) => c.isFinished).toList();
  }
  
  // Computed properties
  
  /// Get total number of challenges
  int get totalChallenges => _allChallenges.length;
  
  /// Get number of challenges user is participating in
  int get participatingChallenges => _allChallenges.where((c) => c.isParticipating).length;
  
  /// Get number of active challenges
  int get activeChallengesCount => _activeChallenges.length;
  
  /// Get number of pending challenges
  int get pendingChallengesCount => _pendingChallenges.length;
  
  /// Get number of finished challenges
  int get finishedChallengesCount => _finishedChallenges.length;
  
  /// Get challenges ending soon (less than 3 days)
  List<ChallengeWithDetails> get challengesEndingSoon => 
      _activeChallenges.where((c) => c.isEndingSoon).toList();
  
  /// Get user's participating challenges
  List<ChallengeWithDetails> get userParticipatingChallenges => 
      _allChallenges.where((c) => c.isParticipating).toList();
  
  /// Check if user has any challenges
  bool get hasChallenges => _allChallenges.isNotEmpty;
  
  /// Check if user is participating in any challenges
  bool get hasParticipatingChallenges => participatingChallenges > 0;
  
  /// Get challenge by ID
  ChallengeWithDetails? getChallengeById(String id) {
    try {
      return _allChallenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
