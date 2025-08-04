import 'package:flutter/foundation.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/global_participant_entry.dart';
import 'package:star_frontend/data/models/challenge.dart';
import 'package:star_frontend/data/services/leaderboard_service.dart';
import 'package:star_frontend/data/services/challenge_service.dart';

/// Provider for managing global participants leaderboard
class GlobalParticipantsProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final ChallengeService _challengeService = ChallengeService();

  // État
  GlobalParticipantsLeaderboard? _leaderboard;
  List<Challenge> _challenges = [];
  String? _selectedChallengeId;
  bool _isLoading = false;
  String? _error;

  // Getters
  GlobalParticipantsLeaderboard? get leaderboard => _leaderboard;
  List<Challenge> get challenges => _challenges;
  String? get selectedChallengeId => _selectedChallengeId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _leaderboard != null && _leaderboard!.entries.isNotEmpty;

  /// Charge le classement global des participants
  Future<void> loadGlobalParticipants({int limit = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info(
        'Loading global participants leaderboard with challengeId: $_selectedChallengeId',
      );
      _leaderboard = await _leaderboardService.getGlobalParticipantsLeaderboard(
        limit: limit,
        challengeId: _selectedChallengeId,
      );
      AppLogger.info(
        'Global participants leaderboard loaded successfully with ${_leaderboard?.entries.length ?? 0} entries',
      );
    } catch (e) {
      _error =
          'Erreur lors du chargement du classement global: ${e.toString()}';
      AppLogger.error('Failed to load global participants leaderboard', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge la liste des challenges pour le filtre
  Future<void> loadChallenges() async {
    try {
      AppLogger.info('Loading challenges for filter');
      _challenges = await _challengeService.getAllChallenges();
      AppLogger.info('Challenges loaded successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load challenges', e);
    }
  }

  /// Filtre par challenge
  Future<void> filterByChallenge(String? challengeId) async {
    if (_selectedChallengeId == challengeId) return;

    _selectedChallengeId = challengeId;
    AppLogger.info('Filtering by challenge: ${challengeId ?? 'all'}');

    await loadGlobalParticipants();
  }

  /// Efface le filtre
  Future<void> clearFilter() async {
    await filterByChallenge(null);
  }

  /// Rafraîchit les données
  Future<void> refresh() async {
    await Future.wait([loadGlobalParticipants(), loadChallenges()]);
  }

  /// Initialise le provider
  Future<void> initialize() async {
    await Future.wait([loadChallenges(), loadGlobalParticipants()]);
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Obtient le challenge sélectionné
  Challenge? get selectedChallenge {
    if (_selectedChallengeId == null) return null;
    try {
      return _challenges.firstWhere((c) => c.id == _selectedChallengeId);
    } catch (e) {
      return null;
    }
  }

  /// Obtient les top performers (top 3)
  List<GlobalParticipantEntry> get topPerformers {
    return _leaderboard?.topPerformers ?? [];
  }

  /// Obtient le nombre total de participants
  int get totalParticipants {
    return _leaderboard?.total ?? 0;
  }

  /// Vérifie si un filtre est appliqué
  bool get isFiltered {
    return _selectedChallengeId != null;
  }

  /// Obtient le nom du filtre actuel
  String get filterDisplayName {
    if (_selectedChallengeId == null) return 'Tous les challenges';
    final challenge = selectedChallenge;
    return challenge?.nom ?? 'Challenge inconnu';
  }
}
