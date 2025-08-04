import 'package:flutter/material.dart';
import 'package:star_frontend/data/services/socket_service.dart';
import 'package:star_frontend/core/constants/app_colors.dart';

/// Widget de test pour vérifier la connexion Socket.IO
class SocketTestWidget extends StatefulWidget {
  const SocketTestWidget({super.key});

  @override
  State<SocketTestWidget> createState() => _SocketTestWidgetState();
}

class _SocketTestWidgetState extends State<SocketTestWidget> {
  final SocketService _socketService = SocketService();
  bool _isConnecting = false;
  bool _isConnected = false;
  String _status = 'Déconnecté';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.connectionStream.listen((connected) {
      setState(() {
        _isConnected = connected;
        _status = connected ? 'Connecté' : 'Déconnecté';
        _addLog('État de connexion: ${connected ? 'Connecté' : 'Déconnecté'}');
      });
    });

    _socketService.leaderboardStream.listen((data) {
      _addLog('Données reçues: ${data.toString().substring(0, 100)}...');
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toLocal().toString().substring(11, 19)} - $message',
      );
      if (_logs.length > 10) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _status = 'Connexion en cours...';
    });

    // Essayer différentes URLs
    final urls = [
      'http://127.0.0.1:3000',
      'http://localhost:3000',
      'http://0.0.0.0:3000',
    ];

    for (String url in urls) {
      _addLog('Tentative de connexion à $url');

      try {
        await _socketService.connect(serverUrl: url);
        _addLog('Connexion réussie avec $url !');
        break;
      } catch (e) {
        _addLog('Erreur avec $url: $e');
        if (url == urls.last) {
          _addLog('Toutes les tentatives ont échoué');
        }
      }
    }

    setState(() {
      _isConnecting = false;
    });
  }

  void _disconnect() {
    _socketService.disconnect();
    _addLog('Déconnexion demandée');
  }

  void _subscribeToChallenge() {
    if (_isConnected) {
      _socketService.subscribeToChallenge('challenge_test_2');
      _addLog('Souscription au challenge challenge_test_2');
    } else {
      _addLog('Erreur: Non connecté');
    }
  }

  void _requestData() {
    if (_isConnected) {
      _socketService.requestLeaderboard('challenge_test_2');
      _socketService.requestStats('challenge_test_2');
      _addLog('Demande de données envoyée');
    } else {
      _addLog('Erreur: Non connecté');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Socket.IO'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statut de connexion
            Card(
              color: _isConnected ? AppColors.success : AppColors.error,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _status,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isConnecting) ...[
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Boutons de contrôle
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Connecter'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _disconnect : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Déconnecter'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _subscribeToChallenge : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('S\'abonner'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _requestData : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Demander données'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logs
            const Text(
              'Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
