import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/data/models/global_participant_entry.dart';
import 'package:star_frontend/data/models/challenge.dart';
import 'package:star_frontend/presentation/providers/global_participants_provider.dart';

/// Widget for displaying global participants leaderboard
class GlobalParticipantsWidget extends StatefulWidget {
  const GlobalParticipantsWidget({super.key});

  @override
  State<GlobalParticipantsWidget> createState() =>
      _GlobalParticipantsWidgetState();
}

class _GlobalParticipantsWidgetState extends State<GlobalParticipantsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GlobalParticipantsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalParticipantsProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: Column(
            children: [
              _buildFilterSection(provider),
              Expanded(child: _buildContent(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(GlobalParticipantsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Filtrer par challenge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (provider.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (provider.isFiltered)
                TextButton(
                  onPressed: provider.clearFilter,
                  child: const Text('Effacer'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildChallengeDropdown(provider),
          const SizedBox(height: 8),
          _buildStatsRow(provider),
        ],
      ),
    );
  }

  Widget _buildChallengeDropdown(GlobalParticipantsProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: provider.selectedChallengeId,
          hint: const Text(
            'Tous les challenges',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.all_inclusive, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Tous les challenges',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            ...provider.challenges.map(
              (challenge) => DropdownMenuItem<String?>(
                value: challenge.id,
                child: Row(
                  children: [
                    Icon(
                      _getChallengeIcon(challenge.statut),
                      size: 16,
                      color: _getChallengeStatusColor(challenge.statut),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            challenge.nom,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _getChallengeStatusText(challenge.statut),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getChallengeStatusColor(challenge.statut),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: provider.isLoading
              ? null
              : (value) async {
                  await provider.filterByChallenge(value);
                },
        ),
      ),
    );
  }

  Widget _buildStatsRow(GlobalParticipantsProvider provider) {
    return Row(
      children: [
        _buildStatChip(
          'Total: ${provider.totalParticipants}',
          AppColors.primary,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          provider.filterDisplayName,
          provider.isFiltered ? AppColors.success : AppColors.grey,
        ),
      ],
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContent(GlobalParticipantsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _buildErrorWidget(provider);
    }

    if (!provider.hasData) {
      return _buildEmptyWidget();
    }

    return _buildLeaderboardList(provider);
  }

  Widget _buildErrorWidget(GlobalParticipantsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            provider.error!,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.refresh,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard_outlined, size: 64, color: AppColors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun participant trouvé',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(GlobalParticipantsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.leaderboard!.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.leaderboard!.entries[index];
        return _buildParticipantCard(entry);
      },
    );
  }

  Widget _buildParticipantCard(GlobalParticipantEntry entry) {
    final isTopThree = entry.rang <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTopThree ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTopThree
            ? BorderSide(color: _getRankColor(entry.rang), width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isTopThree
              ? LinearGradient(
                  colors: [
                    _getRankColor(entry.rang).withValues(alpha: 0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildRankBadge(entry),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.utilisateur.nom,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getChallengeIcon(entry.challenge.statut),
                          size: 14,
                          color: _getChallengeStatusColor(
                            entry.challenge.statut,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.challenge.nom,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChallengeStatusChip(entry),
                        const Spacer(),
                        Text(
                          entry.utilisateur.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      entry.scoreDisplay,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'points',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(GlobalParticipantEntry entry) {
    final isTopThree = entry.rang <= 3;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isTopThree
            ? _getRankColor(entry.rang)
            : AppColors.grey.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          isTopThree ? _getRankEmoji(entry.rang) : '#${entry.rang}',
          style: TextStyle(
            fontSize: isTopThree ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: isTopThree ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeStatusChip(GlobalParticipantEntry entry) {
    Color statusColor;
    switch (entry.challenge.statut.toLowerCase()) {
      case 'en_cours':
        statusColor = AppColors.success;
        break;
      case 'termine':
      case 'terminé':
        statusColor = AppColors.grey;
        break;
      case 'en_attente':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        entry.challengeStatusDisplay,
        style: TextStyle(
          fontSize: 10,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.grey;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  IconData _getChallengeIcon(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_cours':
        return Icons.play_circle_filled;
      case 'termine':
      case 'terminé':
        return Icons.check_circle;
      case 'en_attente':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  Color _getChallengeStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_cours':
        return AppColors.success;
      case 'termine':
      case 'terminé':
        return AppColors.grey;
      case 'en_attente':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  String _getChallengeStatusText(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_cours':
        return 'En cours';
      case 'termine':
      case 'terminé':
        return 'Terminé';
      case 'en_attente':
        return 'En attente';
      default:
        return statut;
    }
  }
}
