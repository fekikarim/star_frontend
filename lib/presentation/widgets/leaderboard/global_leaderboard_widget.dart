import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/data/models/leaderboard.dart';
import 'package:star_frontend/presentation/providers/global_leaderboard_provider.dart';

/// Widget pour afficher les classements globaux (global, hebdomadaire, mensuel)
class GlobalLeaderboardWidget extends StatefulWidget {
  final LeaderboardType type;
  final bool showPodium;
  final int limit;

  const GlobalLeaderboardWidget({
    super.key,
    required this.type,
    this.showPodium = true,
    this.limit = 50,
  });

  @override
  State<GlobalLeaderboardWidget> createState() =>
      _GlobalLeaderboardWidgetState();
}

class _GlobalLeaderboardWidgetState extends State<GlobalLeaderboardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
    });
  }

  Future<void> _loadLeaderboard() async {
    final provider = context.read<GlobalLeaderboardProvider>();
    await provider.refreshLeaderboard(widget.type, limit: widget.limit);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalLeaderboardProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading(widget.type);
        final error = provider.getError(widget.type);
        final leaderboard = provider.getLeaderboard(widget.type);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null) {
          return _buildErrorWidget(error);
        }

        if (leaderboard == null || leaderboard.entries.isEmpty) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: _loadLeaderboard,
          child: Column(
            children: [
              if (widget.showPodium && leaderboard.entries.length >= 3)
                _buildPodium(leaderboard.entries.take(3).toList()),
              if (widget.showPodium && leaderboard.entries.length >= 3)
                const SizedBox(height: 16),
              Expanded(
                child: _buildLeaderboardList(
                  widget.showPodium && leaderboard.entries.length >= 3
                      ? leaderboard.entries.skip(3).toList()
                      : leaderboard.entries,
                  startRank:
                      widget.showPodium && leaderboard.entries.length >= 3
                      ? 4
                      : 1,
                ),
              ),
            ],
          ),
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
            onPressed: _loadLeaderboard,
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
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Aucun classement disponible',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          Text(
            'Top 3 - ${widget.type.displayName}',
            style: const TextStyle(
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
            _getInitials(entry.user.nom),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: position == 1 ? 16 : 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.user.nom,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          _getScoreText(entry),
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

  Widget _buildLeaderboardList(
    List<LeaderboardEntry> entries, {
    int startRank = 1,
  }) {
    if (entries.isEmpty) {
      return const Center(child: Text('Aucun autre participant'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
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
                _getInitials(entry.user.nom),
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
                    entry.user.nom,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.user.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Score et statistiques
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getScoreText(entry),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatsText(entry),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  String _getScoreText(LeaderboardEntry entry) {
    switch (widget.type) {
      case LeaderboardType.global:
        return '${entry.stats.totalStars ?? 0} ⭐';
      case LeaderboardType.weekly:
        return '${entry.stats.weeklyStars ?? 0} ⭐';
      case LeaderboardType.monthly:
        return '${entry.stats.monthlyStars ?? 0} ⭐';
    }
  }

  String _getStatsText(LeaderboardEntry entry) {
    switch (widget.type) {
      case LeaderboardType.global:
        return '${entry.stats.challengesParticipated ?? 0} challenges';
      case LeaderboardType.weekly:
        return '${entry.stats.weeklyChallenges ?? 0} challenges';
      case LeaderboardType.monthly:
        return '${entry.stats.monthlyChallenges ?? 0} challenges';
    }
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
