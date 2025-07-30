import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/core/navigation/app_router.dart';
import 'package:star_frontend/presentation/widgets/common/custom_button.dart';
import 'package:star_frontend/presentation/widgets/common/custom_text_field.dart';

/// Challenges screen showing all available challenges
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.challenges),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'À venir'),
            Tab(text: 'Terminés'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChallengesList('active'),
                _buildChallengesList('upcoming'),
                _buildChallengesList('completed'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: Icons.add,
        onPressed: () {
          // TODO: Navigate to create challenge screen
        },
        tooltip: 'Créer un challenge',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: SearchTextField(
        controller: _searchController,
        hintText: 'Rechercher un challenge...',
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onClear: () {
          setState(() {
            _searchQuery = '';
          });
        },
      ),
    );
  }

  Widget _buildChallengesList(String type) {
    // Mock data - replace with actual data from provider
    final challenges = _getMockChallenges(type);
    
    if (challenges.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;
    
    switch (type) {
      case 'active':
        message = 'Aucun challenge actif';
        icon = Icons.emoji_events_outlined;
        break;
      case 'upcoming':
        message = 'Aucun challenge à venir';
        icon = Icons.schedule;
        break;
      case 'completed':
        message = 'Aucun challenge terminé';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'Aucun challenge';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les challenges apparaîtront ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => AppRouter.goChallengeDetail(context, challenge['id']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      challenge['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(challenge['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                challenge['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge['participants']} participants',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    challenge['duration'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (challenge['progress'] != null) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(challenge['progress'] * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: challenge['progress'],
                      backgroundColor: AppColors.greyLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(challenge['status']),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (challenge['isParticipating'] == true)
                    SmallButton(
                      text: 'Quitter',
                      onPressed: () {
                        // TODO: Implement leave challenge
                      },
                      isOutlined: true,
                      textColor: AppColors.error,
                    )
                  else
                    SmallButton(
                      text: 'Rejoindre',
                      onPressed: () {
                        // TODO: Implement join challenge
                      },
                      backgroundColor: AppColors.primary,
                    ),
                  const Spacer(),
                  SmallButton(
                    text: 'Détails',
                    onPressed: () => AppRouter.goChallengeDetail(context, challenge['id']),
                    isOutlined: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    String text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.challengeActive;
      case 'upcoming':
        return AppColors.challengePending;
      case 'completed':
        return AppColors.challengeCompleted;
      case 'cancelled':
        return AppColors.challengeCancelled;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'upcoming':
        return 'À venir';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  List<Map<String, dynamic>> _getMockChallenges(String type) {
    // Mock data - replace with actual API calls
    switch (type) {
      case 'active':
        return [
          {
            'id': '1',
            'title': 'Innovation Challenge 2024',
            'description': 'Développez une solution innovante pour améliorer l\'expérience utilisateur',
            'status': 'active',
            'participants': 45,
            'duration': '2 semaines restantes',
            'progress': 0.6,
            'isParticipating': true,
          },
          {
            'id': '2',
            'title': 'Code Quality Sprint',
            'description': 'Améliorez la qualité du code et réduisez la dette technique',
            'status': 'active',
            'participants': 23,
            'duration': '5 jours restants',
            'progress': 0.8,
            'isParticipating': false,
          },
        ];
      case 'upcoming':
        return [
          {
            'id': '3',
            'title': 'Green Tech Challenge',
            'description': 'Créez des solutions technologiques durables et écologiques',
            'status': 'upcoming',
            'participants': 0,
            'duration': 'Commence dans 3 jours',
            'isParticipating': false,
          },
        ];
      case 'completed':
        return [
          {
            'id': '4',
            'title': 'Mobile App Contest',
            'description': 'Développement d\'une application mobile native',
            'status': 'completed',
            'participants': 67,
            'duration': 'Terminé il y a 1 semaine',
            'progress': 1.0,
            'isParticipating': true,
          },
        ];
      default:
        return [];
    }
  }
}
