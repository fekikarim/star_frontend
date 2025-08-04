import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/presentation/providers/realtime_leaderboard_provider.dart';

/// Widget pour afficher le classement en temps réel
class RealtimeLeaderboardWidget extends StatefulWidget {
  final String challengeId;
  final bool showStats;
  final bool autoRefresh;

  const RealtimeLeaderboardWidget({
    super.key,
    required this.challengeId,
    this.showStats = true,
    this.autoRefresh = true,
  });

  @override
  State<RealtimeLeaderboardWidget> createState() =>
      _RealtimeLeaderboardWidgetState();
}

class _RealtimeLeaderboardWidgetState extends State<RealtimeLeaderboardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLeaderboard();
    });
  }

  Future<void> _initializeLeaderboard() async {
    final provider = context.read<RealtimeLeaderboardProvider>();
    await provider.initialize();
    provider.subscribeToChallenge(widget.challengeId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeLeaderboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider.error!);
        }

        return Column(
          children: [
            if (widget.showStats) _buildStatsCards(provider),
            if (widget.showStats) const SizedBox(height: 16),
            _buildConnectionStatus(provider),
            const SizedBox(height: 8),
            _buildPodium(provider),
            const SizedBox(height: 16),
            Expanded(child: _buildLeaderboardList(provider)),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(color: AppColors.error, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _initializeLeaderboard(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(RealtimeLeaderboardProvider provider) {
    final stats = provider.stats;
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Participants',
            stats.totalParticipants.toString(),
            Icons.people,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Score Max',
            stats.scoreMax.toStringAsFixed(1),
            Icons.trending_up,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Moyenne',
            stats.scoreMoyen.toStringAsFixed(1),
            Icons.analytics,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Score Min',
            stats.scoreMin.toStringAsFixed(1),
            Icons.trending_down,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(RealtimeLeaderboardProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: provider.isConnected ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            provider.isConnected ? Icons.wifi : Icons.wifi_off,
            color: AppColors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            provider.isConnected ? 'Temps réel' : '',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (provider.lastUpdate != null) ...[
            const SizedBox(width: 8),
            Text(
              _formatLastUpdate(provider.lastUpdate!),
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else {
      return 'Il y a ${difference.inHours}h';
    }
  }

  Widget _buildPodium(RealtimeLeaderboardProvider provider) {
    final topThree = provider.topThree;
    if (topThree.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          const Text(
            'Top 3',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length > 1) _buildPodiumPosition(topThree[1], 2),
              if (topThree.isNotEmpty) _buildPodiumPosition(topThree[0], 1),
              if (topThree.length > 2) _buildPodiumPosition(topThree[2], 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(LeaderboardEntry entry, int position) {
    final height = position == 1
        ? 100.0
        : position == 2
        ? 80.0
        : 60.0;
    final iconSize = position == 1 ? 40.0 : 30.0;
    final color = position == 1
        ? Colors.amber
        : position == 2
        ? Colors.grey
        : Colors.brown;

    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.white,
          child: Text(
            entry.initials,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: position == 1 ? 16 : 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.nom,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${entry.scoreTotal.toStringAsFixed(1)} pts',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Icon(
            position == 1 ? Icons.emoji_events : Icons.star,
            color: AppColors.white,
            size: iconSize,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(RealtimeLeaderboardProvider provider) {
    final remaining = provider.remainingParticipants;

    if (remaining.isEmpty) {
      return const Center(child: Text('Aucun autre participant'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: remaining.length,
      itemBuilder: (context, index) {
        final entry = remaining[index];
        return _buildLeaderboardItem(entry);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rang
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(entry.rang),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.rang}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                entry.initials,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Nom et détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.nom,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.scoreTotal.toStringAsFixed(1)} pts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.isValidated != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: entry.isValidated == 'validated'
                          ? AppColors.success
                          : AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.isValidated == 'validated'
                          ? 'Validé'
                          : 'En attente',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 10) {
      return AppColors.primary;
    } else if (rank <= 20) {
      return AppColors.secondary;
    } else {
      return AppColors.grey;
    }
  }
}
