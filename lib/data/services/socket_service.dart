import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';

/// Service pour gérer les connexions Socket.IO et les mises à jour en temps réel
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final Logger _logger = Logger();
  bool _isConnected = false;
  String? _currentChallengeId;

  // Streams pour les mises à jour en temps réel
  final StreamController<Map<String, dynamic>> _leaderboardController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _performanceChangeController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Getters pour les streams
  Stream<Map<String, dynamic>> get leaderboardStream =>
      _leaderboardController.stream;
  Stream<Map<String, dynamic>> get statsStream => _statsController.stream;
  Stream<Map<String, dynamic>> get performanceChangeStream =>
      _performanceChangeController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;
  String? get currentChallengeId => _currentChallengeId;

  /// Initialise la connexion Socket.IO
  Future<void> connect({String serverUrl = 'http://localhost:3000'}) async {
    if (_socket != null && _isConnected) {
      _logger.i('[SocketService] Already connected');
      return;
    }

    try {
      _logger.i('[SocketService] Connecting to $serverUrl');

      // Déconnecter l'ancien socket s'il existe
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
      }

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports([
              'websocket',
              'polling',
            ]) // WebSocket en premier, polling en fallback
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(3)
            .setReconnectionDelay(1000)
            .setTimeout(15000)
            .enableForceNew()
            .build(),
      );

      _setupEventHandlers();

      // Attendre la connexion avec un timeout plus long
      await _waitForConnection();
    } catch (e) {
      _logger.e('[SocketService] Connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  /// Configure les gestionnaires d'événements
  void _setupEventHandlers() {
    _socket?.onConnect((_) {
      _logger.i('[SocketService] Connected to server');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket?.onDisconnect((_) {
      _logger.w('[SocketService] Disconnected from server');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket?.onConnectError((error) {
      _logger.e('[SocketService] Connection error: $error');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket?.onReconnect((_) {
      _logger.i('[SocketService] Reconnected to server');
      _isConnected = true;
      _connectionController.add(true);

      // Re-souscrire au challenge actuel si nécessaire
      if (_currentChallengeId != null) {
        subscribeToChallenge(_currentChallengeId!);
      }
    });

    // Événements de données
    _socket?.on('leaderboard_update', (data) {
      _logger.d('[SocketService] Leaderboard update received');
      _leaderboardController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('stats_update', (data) {
      _logger.d('[SocketService] Stats update received');
      _statsController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('performance_change', (data) {
      _logger.d('[SocketService] Performance change received');
      _performanceChangeController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('subscription_confirmed', (data) {
      _logger.i('[SocketService] Subscription confirmed: $data');
    });

    _socket?.on('pong', (data) {
      _logger.d('[SocketService] Pong received: $data');
    });
  }

  /// Attend que la connexion soit établie
  Future<void> _waitForConnection() async {
    final completer = Completer<void>();
    Timer? timeout;

    void onConnect(_) {
      if (!completer.isCompleted) {
        timeout?.cancel();
        completer.complete();
      }
    }

    void onError(error) {
      if (!completer.isCompleted) {
        timeout?.cancel();
        completer.completeError(error);
      }
    }

    _socket?.onConnect(onConnect);
    _socket?.onConnectError(onError);

    // Timeout après 30 secondes
    timeout = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.completeError('Connection timeout after 30 seconds');
      }
    });

    return completer.future;
  }

  /// Souscrit aux mises à jour d'un challenge
  void subscribeToChallenge(String challengeId) {
    if (!_isConnected) {
      _logger.w('[SocketService] Not connected, cannot subscribe');
      return;
    }

    _logger.i('[SocketService] Subscribing to challenge: $challengeId');
    _currentChallengeId = challengeId;
    _socket?.emit('subscribe_challenge', challengeId);
  }

  /// Se désabonne des mises à jour d'un challenge
  void unsubscribeFromChallenge(String challengeId) {
    if (!_isConnected) {
      _logger.w('[SocketService] Not connected, cannot unsubscribe');
      return;
    }

    _logger.i('[SocketService] Unsubscribing from challenge: $challengeId');
    _socket?.emit('unsubscribe_challenge', challengeId);

    if (_currentChallengeId == challengeId) {
      _currentChallengeId = null;
    }
  }

  /// Demande le classement actuel
  void requestLeaderboard(String challengeId) {
    if (!_isConnected) {
      _logger.w('[SocketService] Not connected, cannot request leaderboard');
      return;
    }

    _logger.d('[SocketService] Requesting leaderboard for: $challengeId');
    _socket?.emit('request_leaderboard', challengeId);
  }

  /// Demande les statistiques actuelles
  void requestStats(String challengeId) {
    if (!_isConnected) {
      _logger.w('[SocketService] Not connected, cannot request stats');
      return;
    }

    _logger.d('[SocketService] Requesting stats for: $challengeId');
    _socket?.emit('request_stats', challengeId);
  }

  /// Envoie un ping pour maintenir la connexion
  void ping() {
    if (!_isConnected) return;
    _socket?.emit('ping');
  }

  /// Démarre un ping automatique
  Timer? _pingTimer;
  void startAutoPing({Duration interval = const Duration(seconds: 30)}) {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(interval, (_) => ping());
  }

  /// Arrête le ping automatique
  void stopAutoPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Déconnecte le socket
  void disconnect() {
    _logger.i('[SocketService] Disconnecting');

    stopAutoPing();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _currentChallengeId = null;
    _connectionController.add(false);
  }

  /// Nettoie les ressources
  void dispose() {
    disconnect();
    _leaderboardController.close();
    _statsController.close();
    _performanceChangeController.close();
    _connectionController.close();
  }
}
