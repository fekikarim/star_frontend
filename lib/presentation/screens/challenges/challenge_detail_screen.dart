import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/data/models/challenge_with_details.dart';
import 'package:star_frontend/data/services/participant_service.dart';
import 'package:star_frontend/presentation/providers/auth_provider.dart';
import 'package:star_frontend/presentation/providers/challenge_provider.dart';

/// Screen for displaying detailed information about a specific challenge
class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  ChallengeWithDetails? challenge;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  void _loadChallenge() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final challengeProvider = Provider.of<ChallengeProvider>(
        context,
        listen: false,
      );
      final foundChallenge = challengeProvider.getChallengeById(
        widget.challengeId,
      );

      setState(() {
        challenge = foundChallenge;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (challenge == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Challenge non trouvé')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChallengeInfo(),
                  const SizedBox(height: 24),
                  _buildProgressSection(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildObjectivesSection(),
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          challenge!.nom,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.emoji_events, size: 80, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusBadge(),
                const Spacer(),
                Text(
                  'ID: ${challenge!.id}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.access_time, 'Durée', _getDurationText()),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people,
              'Participants',
              '${challenge!.participantsCount} inscrits',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.star,
              'Récompense',
              '100 étoiles', // TODO: Get from challenge data
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = Color(
      int.parse(challenge!.statusColorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        challenge!.statusDisplayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    // Mock progress data - TODO: Get from real data
    const progress = 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progression',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: AppColors.textHint.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          '$progress% terminé',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          "Développez une solution innovante pour améliorer l'expérience utilisateur dans notre application. Ce challenge vous permettra de mettre en pratique vos compétences en design thinking et en développement.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildObjectivesSection() {
    final objectives = [
      "Identifier un problème d'expérience utilisateur",
      "Proposer une solution innovante",
      "Développer un prototype fonctionnel",
      "Présenter votre solution à l'équipe",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objectifs',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...objectives.map(
          (objective) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    objective,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (challenge!.isParticipating) {
      return FloatingActionButton.extended(
        onPressed: () {
          _showQuitDialog();
        },
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.exit_to_app, color: Colors.white),
        label: const Text('Quitter', style: TextStyle(color: Colors.white)),
      );
    } else if (challenge!.isFinished) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: AppColors.textSecondary,
        icon: const Icon(Icons.flag, color: Colors.white),
        label: const Text('Terminé', style: TextStyle(color: Colors.white)),
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () {
          _showJoinDialog();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Rejoindre', style: TextStyle(color: Colors.white)),
      );
    }
  }

  String _getDurationText() {
    final now = DateTime.now();
    final endDate = challenge!.dateFin;
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Terminé';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} restant${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} restante${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Moins d\'une heure';
    }
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejoindre le challenge'),
        content: Text('Voulez-vous rejoindre "${challenge!.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _joinChallenge(context),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le challenge'),
        content: Text('Voulez-vous vraiment quitter "${challenge!.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _quitChallenge(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  /// Join challenge
  Future<void> _joinChallenge(BuildContext context) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final challengeProvider = Provider.of<ChallengeProvider>(
      context,
      listen: false,
    );
    final participantService = ParticipantService();

    // Check if user can participate in challenges
    if (!authProvider.currentUser!.canParticipateInChallenges) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Seuls les administrateurs, agents et responsables régionaux peuvent participer aux challenges.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Rejoindre le challenge...'),
              ],
            ),
          ),
        );
      }

      await participantService.joinChallenge(
        authProvider.userId,
        widget.challengeId,
      );

      // Refresh challenges
      await challengeProvider.loadAllChallenges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vous avez rejoint "${challenge?.nom}". Votre participation est en attente de validation.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la participation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Quit challenge
  Future<void> _quitChallenge(BuildContext context) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final challengeProvider = Provider.of<ChallengeProvider>(
      context,
      listen: false,
    );
    final participantService = ParticipantService();

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Quitter le challenge...'),
              ],
            ),
          ),
        );
      }

      await participantService.leaveChallenge(
        authProvider.userId,
        widget.challengeId,
      );

      // Refresh challenges
      await challengeProvider.loadAllChallenges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous avez quitté "${challenge?.nom}".'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sortie: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
