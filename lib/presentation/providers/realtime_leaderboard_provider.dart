import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:star_frontend/data/services/socket_service.dart';
import 'package:logger/logger.dart';

/// Modèle pour une entrée de classement
class LeaderboardEntry {
  final String participantId;
  final String utilisateurId;
  final String nom;
  final String email;
  final double scoreTotal;
  final int rang;
  final String? role;
  final String challengeId;
  final String? isValidated;

  LeaderboardEntry({
    required this.participantId,
    required this.utilisateurId,
    required this.nom,
    required this.email,
    required this.scoreTotal,
    required this.rang,
    this.role,
    required this.challengeId,
    this.isValidated,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      participantId: json['participantId'] ?? '',
      utilisateurId: json['utilisateurId'] ?? '',
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      scoreTotal: (json['scoreTotal'] ?? 0).toDouble(),
      rang: json['rang'] ?? 0,
      role: json['role'],
      challengeId: json['challengeId'] ?? '',
      isValidated: json['isValidated'],
    );
  }

  String get initials {
    final names = nom.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  bool get isTopThree => rang <= 3;
  bool get isWinner => rang == 1;
}

/// Modèle pour les statistiques de classement
class LeaderboardStats {
  final int totalParticipants;
  final double scoreMax;
  final double scoreMin;
  final double scoreMoyen;
  final DateTime derniereMiseAJour;

  LeaderboardStats({
    required this.totalParticipants,
    required this.scoreMax,
    required this.scoreMin,
    required this.scoreMoyen,
    required this.derniereMiseAJour,
  });

  factory LeaderboardStats.fromJson(Map<String, dynamic> json) {
    return LeaderboardStats(
      totalParticipants: json['totalParticipants'] ?? 0,
      scoreMax: (json['scoreMax'] ?? 0).toDouble(),
      scoreMin: (json['scoreMin'] ?? 0).toDouble(),
      scoreMoyen: (json['scoreMoyen'] ?? 0).toDouble(),
      derniereMiseAJour: DateTime.parse(
        json['derniereMiseAJour'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

/// Provider pour gérer le classement en temps réel avec Socket.IO
class RealtimeLeaderboardProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  final Logger _logger = Logger();

  // État
  List<LeaderboardEntry> _leaderboard = [];
  LeaderboardStats? _stats;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;
  String? _currentChallengeId;
  DateTime? _lastUpdate;

  // Subscriptions
  StreamSubscription? _leaderboardSubscription;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _performanceChangeSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  LeaderboardStats? get stats => _stats;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChallengeId => _currentChallengeId;
  DateTime? get lastUpdate => _lastUpdate;

  /// Top 3 participants
  List<LeaderboardEntry> get topThree {
    return _leaderboard.take(3).toList();
  }

  /// Participants restants (après le top 3)
  List<LeaderboardEntry> get remainingParticipants {
    return _leaderboard.skip(3).toList();
  }

  /// Initialise la connexion Socket.IO
  Future<void> initialize({String serverUrl = 'http://localhost:3000'}) async {
    try {
      _setLoading(true);
      _clearError();

      _logger.i(
        '[RealtimeLeaderboardProvider] Initializing Socket.IO connection',
      );

      await _socketService.connect(serverUrl: serverUrl);
      _setupSubscriptions();

      _logger.i(
        '[RealtimeLeaderboardProvider] Socket.IO initialized successfully',
      );
    } catch (e) {
      _logger.e(
        '[RealtimeLeaderboardProvider] Failed to initialize Socket.IO: $e',
      );
      _setError('Impossible de se connecter au serveur en temps réel');
    } finally {
      _setLoading(false);
    }
  }

  /// Configure les souscriptions aux événements Socket.IO
  void _setupSubscriptions() {
    // Souscription aux mises à jour de classement
    _leaderboardSubscription = _socketService.leaderboardStream.listen(
      (data) {
        _handleLeaderboardUpdate(data);
      },
      onError: (error) {
        _logger.e(
          '[RealtimeLeaderboardProvider] Leaderboard stream error: $error',
        );
      },
    );

    // Souscription aux mises à jour de statistiques
    _statsSubscription = _socketService.statsStream.listen(
      (data) {
        _handleStatsUpdate(data);
      },
      onError: (error) {
        _logger.e('[RealtimeLeaderboardProvider] Stats stream error: $error');
      },
    );

    // Souscription aux changements de performance
    _performanceChangeSubscription = _socketService.performanceChangeStream.listen(
      (data) {
        _handlePerformanceChange(data);
      },
      onError: (error) {
        _logger.e(
          '[RealtimeLeaderboardProvider] Performance change stream error: $error',
        );
      },
    );

    // Souscription aux changements de connexion
    _connectionSubscription = _socketService.connectionStream.listen((
      connected,
    ) {
      _isConnected = connected;
      notifyListeners();

      if (connected && _currentChallengeId != null) {
        // Re-souscrire au challenge après reconnexion
        subscribeToChallenge(_currentChallengeId!);
      }
    });
  }

  /// Souscrit aux mises à jour d'un challenge
  void subscribeToChallenge(String challengeId) {
    // Éviter les souscriptions multiples
    if (_currentChallengeId == challengeId && _socketService.isConnected) {
      _logger.i(
        '[RealtimeLeaderboardProvider] Already subscribed to challenge: $challengeId',
      );
      return;
    }

    _logger.i(
      '[RealtimeLeaderboardProvider] Subscribing to challenge: $challengeId',
    );

    // Se désabonner du challenge précédent si nécessaire
    if (_currentChallengeId != null && _currentChallengeId != challengeId) {
      unsubscribeFromChallenge();
    }

    _currentChallengeId = challengeId;
    _socketService.subscribeToChallenge(challengeId);

    notifyListeners();
  }

  /// Se désabonne d'un challenge
  void unsubscribeFromChallenge() {
    if (_currentChallengeId != null) {
      _logger.i(
        '[RealtimeLeaderboardProvider] Unsubscribing from challenge: $_currentChallengeId',
      );
      _socketService.unsubscribeFromChallenge(_currentChallengeId!);
      _currentChallengeId = null;
      _clearData();
      notifyListeners();
    }
  }

  /// Gère les mises à jour de classement
  void _handleLeaderboardUpdate(Map<String, dynamic> data) {
    try {
      _logger.d('[RealtimeLeaderboardProvider] Processing leaderboard update');

      final classementData = data['classement'] as List<dynamic>?;
      if (classementData != null) {
        _leaderboard = classementData
            .map(
              (entry) =>
                  LeaderboardEntry.fromJson(entry as Map<String, dynamic>),
            )
            .toList();

        _lastUpdate = DateTime.parse(
          data['timestamp'] ?? DateTime.now().toIso8601String(),
        );
        _clearError();
        notifyListeners();

        _logger.i(
          '[RealtimeLeaderboardProvider] Leaderboard updated with ${_leaderboard.length} entries',
        );
      }
    } catch (e) {
      _logger.e(
        '[RealtimeLeaderboardProvider] Error processing leaderboard update: $e',
      );
      _setError('Erreur lors de la mise à jour du classement');
    }
  }

  /// Gère les mises à jour de statistiques
  void _handleStatsUpdate(Map<String, dynamic> data) {
    try {
      _logger.d('[RealtimeLeaderboardProvider] Processing stats update');

      final statsData = data['statistiques'] as Map<String, dynamic>?;
      if (statsData != null) {
        _stats = LeaderboardStats.fromJson(statsData);
        notifyListeners();

        _logger.i('[RealtimeLeaderboardProvider] Stats updated');
      }
    } catch (e) {
      _logger.e(
        '[RealtimeLeaderboardProvider] Error processing stats update: $e',
      );
    }
  }

  /// Gère les notifications de changement de performance
  void _handlePerformanceChange(Map<String, dynamic> data) {
    _logger.i(
      '[RealtimeLeaderboardProvider] Performance change detected: ${data['action']} for participant ${data['participantId']}',
    );

    // Les mises à jour de classement et statistiques suivront automatiquement
    // via les événements leaderboard_update et stats_update
  }

  /// Actualise manuellement les données
  void refresh() {
    if (_currentChallengeId != null && _isConnected) {
      _logger.i('[RealtimeLeaderboardProvider] Manual refresh requested');
      _socketService.requestLeaderboard(_currentChallengeId!);
      _socketService.requestStats(_currentChallengeId!);
    }
  }

  /// Nettoie les données
  void _clearData() {
    _leaderboard.clear();
    _stats = null;
    _lastUpdate = null;
  }

  /// Définit l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Définit une erreur
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Efface l'erreur
  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _logger.i('[RealtimeLeaderboardProvider] Disposing');

    _leaderboardSubscription?.cancel();
    _statsSubscription?.cancel();
    _performanceChangeSubscription?.cancel();
    _connectionSubscription?.cancel();

    _socketService.disconnect();
    super.dispose();
  }
}
