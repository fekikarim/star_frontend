import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/data/models/challenge_with_details.dart';
import 'package:star_frontend/presentation/providers/challenge_provider.dart';
import 'package:star_frontend/presentation/screens/challenges/challenge_detail_screen.dart';

/// Challenges screen showing all available challenges with tabs
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load challenges when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeProvider>(
        context,
        listen: false,
      ).loadAllChallenges();
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
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un challenge...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildChallengesList(String type) {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        if (challengeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (challengeProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  challengeProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => challengeProvider.loadAllChallenges(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        List<ChallengeWithDetails> challenges = [];

        switch (type) {
          case 'active':
            // Challenges 'Actifs' = statut 'en cours'
            challenges = challengeProvider.allChallenges
                .where((c) => c.statut == 'en cours')
                .toList();
            break;
          case 'upcoming':
            // Challenges 'À venir' = statut 'en attente'
            challenges = challengeProvider.allChallenges
                .where((c) => c.statut == 'en attente')
                .toList();
            break;
          case 'completed':
            // Challenges 'Terminés' = statut 'terminé'
            challenges = challengeProvider.allChallenges
                .where((c) => c.statut == 'terminé')
                .toList();
            break;
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          challenges = challenges
              .where(
                (c) => c.nom.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
        }

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
      },
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'active':
        title = 'Aucun challenge actif';
        subtitle = 'Il n\'y a pas de challenges actifs pour le moment';
        icon = Icons.emoji_events_outlined;
        break;
      case 'upcoming':
        title = 'Aucun challenge à venir';
        subtitle = 'Aucun nouveau challenge n\'est prévu';
        icon = Icons.schedule;
        break;
      case 'completed':
        title = 'Aucun challenge terminé';
        subtitle = 'Vous n\'avez pas encore terminé de challenges';
        icon = Icons.flag_outlined;
        break;
      default:
        title = 'Aucun challenge';
        subtitle = 'Aucun challenge trouvé';
        icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeWithDetails challenge) {
    final statusColor = Color(
      int.parse(challenge.statusColorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.nom,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    challenge.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description ??
                  'Développez une solution innovante pour améliorer l\'expérience utilisateur',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${challenge.participantsCount} participants',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _getDurationText(challenge),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            LinearProgressIndicator(
              value: 0.6, // TODO: Get real progress
              backgroundColor: AppColors.textHint.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '60%', // TODO: Get real progress
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (challenge.isParticipating)
                      TextButton(
                        onPressed: () {
                          // TODO: Implement quit challenge
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: const Text('Quitter'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement join challenge
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: const Text('Rejoindre'),
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeDetailScreen(
                              challengeId: challenge.id,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text('Détails'),
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

  String _getDurationText(ChallengeWithDetails challenge) {
    final now = DateTime.now();
    final endDate = challenge.dateFin;
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
}
