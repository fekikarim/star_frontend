import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/data/models/participant.dart';
import 'package:star_frontend/data/models/challenge.dart';
import 'package:star_frontend/data/services/participant_service.dart';
import 'package:star_frontend/data/services/challenge_service.dart';
import 'package:star_frontend/presentation/providers/auth_provider.dart';
import 'package:star_frontend/presentation/screens/challenges/challenge_detail_screen.dart';

/// Screen showing user's challenge participations with their validation status
class UserParticipationsScreen extends StatefulWidget {
  const UserParticipationsScreen({super.key});

  @override
  State<UserParticipationsScreen> createState() =>
      _UserParticipationsScreenState();
}

class _UserParticipationsScreenState extends State<UserParticipationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ParticipantService _participantService = ParticipantService();
  final ChallengeService _challengeService = ChallengeService();

  List<Participant> _allParticipations = [];
  List<Participant> _validatedParticipations = [];
  List<Participant> _pendingParticipations = [];
  List<Participant> _rejectedParticipations = [];
  Map<String, Challenge> _challengesMap = {};

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadParticipations();
  }

  void _onTabChanged() {
    // Optionnel: rafraîchir les données quand l'utilisateur change d'onglet
    if (_tabController.indexIsChanging) {
      // Vous pouvez ajouter une logique de rafraîchissement ici si nécessaire
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger toutes les participations en parallèle pour optimiser les performances
      final results = await Future.wait([
        _participantService.getUserParticipationsWithStatus(
          authProvider.userId,
        ),
        _participantService.getValidatedParticipations(authProvider.userId),
        _participantService.getPendingParticipations(authProvider.userId),
        _participantService.getRejectedParticipations(authProvider.userId),
      ]);

      // Récupérer les informations des challenges
      final challenges = await _challengeService.getAllChallenges();
      final challengesMap = <String, Challenge>{};
      for (final challenge in challenges) {
        challengesMap[challenge.id] = challenge;
      }

      setState(() {
        _allParticipations = results[0];
        _validatedParticipations = results[1];
        _pendingParticipations = results[2];
        _rejectedParticipations = results[3];
        _challengesMap = challengesMap;
      });
    } catch (e) {
      setState(() {
        _error =
            'Erreur lors du chargement des participations: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Participations'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          tabs: [
            Tab(text: 'Toutes (${_allParticipations.length})'),
            Tab(text: 'Validées (${_validatedParticipations.length})'),
            Tab(text: 'En attente (${_pendingParticipations.length})'),
            Tab(text: 'Rejetées (${_rejectedParticipations.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildParticipationsList(_allParticipations),
                _buildParticipationsList(_validatedParticipations),
                _buildParticipationsList(_pendingParticipations),
                _buildParticipationsList(_rejectedParticipations),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: AppColors.error, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadParticipations,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationsList(List<Participant> participations) {
    if (participations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'Aucune participation trouvée',
              style: TextStyle(color: AppColors.textHint, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParticipations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: participations.length,
        itemBuilder: (context, index) {
          final participation = participations[index];
          return _buildParticipationCard(participation);
        },
      ),
    );
  }

  Widget _buildParticipationCard(Participant participation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChallengeDetailScreen(challengeId: participation.challengeId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _challengesMap[participation.challengeId]?.nom ??
                          'Challenge ${participation.challengeId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(participation),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.score, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Score: ${participation.scoreTotal.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (participation.createdAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rejoint le ${_formatDate(participation.createdAt!)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Participant participation) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (participation.validationStatus) {
      case ParticipantValidationStatus.validated:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case ParticipantValidationStatus.pending:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        icon = Icons.access_time;
        break;
      case ParticipantValidationStatus.rejected:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            participation.validationStatusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
