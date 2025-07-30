import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/presentation/widgets/common/custom_button.dart';

/// Challenge detail screen
class ChallengeDetailScreen extends StatelessWidget {
  final String challengeId;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual API call
    final challenge = _getMockChallenge(challengeId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, challenge),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildChallengeInfo(context, challenge),
                const SizedBox(height: 24),
                _buildDescription(context, challenge),
                const SizedBox(height: 24),
                _buildParticipants(context, challenge),
                const SizedBox(height: 24),
                _buildLeaderboard(context, challenge),
                const SizedBox(height: 100), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButton(context, challenge),
    );
  }

  Widget _buildAppBar(BuildContext context, Map<String, dynamic> challenge) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          challenge['title'],
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                bottom: 60,
                child: Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: AppColors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeInfo(BuildContext context, Map<String, dynamic> challenge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip(challenge['status']),
                const Spacer(),
                Text(
                  'ID: ${challenge['id']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.schedule, 'Durée', challenge['duration']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.people, 'Participants', '${challenge['participants']} inscrits'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.star, 'Récompense', '${challenge['reward']} étoiles'),
            if (challenge['progress'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Progression',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: challenge['progress'],
                backgroundColor: AppColors.greyLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(challenge['status']),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(challenge['progress'] * 100).toInt()}% terminé',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, Map<String, dynamic> challenge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              challenge['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Objectifs',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...challenge['objectives'].map<Widget>((objective) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(objective)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipants(BuildContext context, Map<String, dynamic> challenge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Participants',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${challenge['participants']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8, // Mock participant count
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            'U${index + 1}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, Map<String, dynamic> challenge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Classement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(3, (index) {
              final rank = index + 1;
              final score = 100 - (index * 15);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
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
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'U$rank',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Utilisateur $rank',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$score pts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full leaderboard
                },
                child: const Text('Voir le classement complet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Map<String, dynamic> challenge) {
    final isParticipating = challenge['isParticipating'] ?? false;
    
    return CustomFloatingActionButton(
      icon: isParticipating ? Icons.exit_to_app : Icons.add,
      onPressed: () {
        // TODO: Implement join/leave challenge
        _showActionDialog(context, isParticipating);
      },
      tooltip: isParticipating ? 'Quitter le challenge' : 'Rejoindre le challenge',
    );
  }

  void _showActionDialog(BuildContext context, bool isParticipating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isParticipating ? 'Quitter le challenge' : 'Rejoindre le challenge'),
        content: Text(
          isParticipating 
            ? 'Êtes-vous sûr de vouloir quitter ce challenge ?'
            : 'Voulez-vous rejoindre ce challenge ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual join/leave logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isParticipating 
                      ? 'Vous avez quitté le challenge'
                      : 'Vous avez rejoint le challenge',
                  ),
                ),
              );
            },
            child: Text(isParticipating ? 'Quitter' : 'Rejoindre'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    String text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return AppColors.primary;
    }
  }

  Map<String, dynamic> _getMockChallenge(String id) {
    // Mock data - replace with actual API call
    return {
      'id': id,
      'title': 'Innovation Challenge 2024',
      'description': 'Développez une solution innovante pour améliorer l\'expérience utilisateur dans notre application. Ce challenge vous permettra de mettre en pratique vos compétences en design thinking et en développement.',
      'status': 'active',
      'participants': 45,
      'duration': '2 semaines restantes',
      'reward': 100,
      'progress': 0.6,
      'isParticipating': true,
      'objectives': [
        'Identifier un problème d\'expérience utilisateur',
        'Proposer une solution innovante',
        'Développer un prototype fonctionnel',
        'Présenter votre solution à l\'équipe',
      ],
    };
  }
}
