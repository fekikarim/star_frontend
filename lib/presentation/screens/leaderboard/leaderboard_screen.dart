import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';

/// Leaderboard screen showing rankings and top performers
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaderboard),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Cette semaine'),
            Tab(text: 'Ce mois'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPodium(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList('global'),
                _buildLeaderboardList('week'),
                _buildLeaderboardList('month'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
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
              _buildPodiumPosition(2, 'Alice M.', 850, Colors.grey),
              _buildPodiumPosition(1, 'Jean D.', 1200, Colors.amber),
              _buildPodiumPosition(3, 'Marie L.', 720, Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(int position, String name, int score, Color color) {
    final height = position == 1 ? 100.0 : position == 2 ? 80.0 : 60.0;
    final iconSize = position == 1 ? 40.0 : 30.0;

    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.white,
          child: Text(
            name.split(' ').map((n) => n[0]).join(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: position == 1 ? 16 : 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$score pts',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.9),
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

  Widget _buildLeaderboardList(String period) {
    final participants = _getMockLeaderboard(period);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final rank = index + 4; // Starting from 4th position (after podium)
        
        return _buildLeaderboardItem(participant, rank);
      },
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> participant, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
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
                participant['initials'],
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant['name'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${participant['challenges']} challenges',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.starFilled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${participant['stars']} étoiles',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Score and trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${participant['score']} pts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      participant['trend'] > 0 
                        ? Icons.trending_up 
                        : participant['trend'] < 0 
                          ? Icons.trending_down 
                          : Icons.trending_flat,
                      size: 16,
                      color: participant['trend'] > 0 
                        ? AppColors.success 
                        : participant['trend'] < 0 
                          ? AppColors.error 
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      participant['trend'] > 0 
                        ? '+${participant['trend']}'
                        : '${participant['trend']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: participant['trend'] > 0 
                          ? AppColors.success 
                          : participant['trend'] < 0 
                            ? AppColors.error 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

  List<Map<String, dynamic>> _getMockLeaderboard(String period) {
    // Mock data - replace with actual API calls
    return [
      {
        'name': 'Sophie R.',
        'initials': 'SR',
        'score': 680,
        'challenges': 8,
        'stars': 45,
        'trend': 15,
      },
      {
        'name': 'Thomas B.',
        'initials': 'TB',
        'score': 650,
        'challenges': 7,
        'stars': 42,
        'trend': -5,
      },
      {
        'name': 'Emma C.',
        'initials': 'EC',
        'score': 620,
        'challenges': 6,
        'stars': 38,
        'trend': 8,
      },
      {
        'name': 'Lucas M.',
        'initials': 'LM',
        'score': 590,
        'challenges': 9,
        'stars': 35,
        'trend': 0,
      },
      {
        'name': 'Camille D.',
        'initials': 'CD',
        'score': 570,
        'challenges': 5,
        'stars': 33,
        'trend': 12,
      },
      {
        'name': 'Antoine L.',
        'initials': 'AL',
        'score': 550,
        'challenges': 6,
        'stars': 31,
        'trend': -3,
      },
      {
        'name': 'Julie P.',
        'initials': 'JP',
        'score': 530,
        'challenges': 4,
        'stars': 29,
        'trend': 7,
      },
      {
        'name': 'Nicolas F.',
        'initials': 'NF',
        'score': 510,
        'challenges': 5,
        'stars': 27,
        'trend': -8,
      },
      {
        'name': 'Léa G.',
        'initials': 'LG',
        'score': 490,
        'challenges': 3,
        'stars': 25,
        'trend': 20,
      },
      {
        'name': 'Maxime H.',
        'initials': 'MH',
        'score': 470,
        'challenges': 4,
        'stars': 23,
        'trend': 5,
      },
    ];
  }
}
