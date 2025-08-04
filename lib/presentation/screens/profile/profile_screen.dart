import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/core/navigation/app_router.dart';
import 'package:star_frontend/data/models/achievement.dart';
import 'package:star_frontend/presentation/providers/auth_provider.dart';
import 'package:star_frontend/presentation/providers/user_stats_provider.dart';
import 'package:star_frontend/presentation/screens/profile/edit_profile_screen.dart';
import 'package:star_frontend/presentation/screens/profile/privacy_screen.dart';
import 'package:star_frontend/presentation/screens/profile/about_screen.dart';
import 'package:star_frontend/presentation/widgets/common/custom_button.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final statsProvider = Provider.of<UserStatsProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated) {
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        statsProvider.loadAllUserData(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, authProvider),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileCard(context, authProvider),
                    const SizedBox(height: 24),
                    _buildStatsSection(context),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(context),
                    const SizedBox(height: 24),
                    _buildSettingsSection(context, authProvider),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: const Text(
          AppStrings.profile,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.white),
          onPressed: () {
            _navigateToEditProfile(context);
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                authProvider.userInitials,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.userDisplayName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.userEmail,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                authProvider.getUserStatus(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<UserStatsProvider>(
              builder: (context, statsProvider, child) {
                if (statsProvider.isLoading) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileStat('Niveau', '...', Icons.star),
                      _buildProfileStat('Étoiles', '...', Icons.star_border),
                      _buildProfileStat('Rang', '...', Icons.leaderboard),
                    ],
                  );
                }

                final userStats = statsProvider.userStats;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat(
                      'Niveau',
                      userStats?.level.current.nom ?? 'Débutant',
                      Icons.star,
                    ),
                    _buildProfileStat(
                      'Étoiles',
                      '${userStats?.stats.totalStars ?? 0}',
                      Icons.star_border,
                    ),
                    _buildProfileStat(
                      'Rang',
                      '#${_calculateUserRank(userStats?.stats.totalStars ?? 0)}',
                      Icons.leaderboard,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<UserStatsProvider>(
          builder: (context, statsProvider, child) {
            final userStats = statsProvider.userStats;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Challenges terminés',
                        '${userStats?.stats.challengesWon ?? 0}',
                        Icons.emoji_events,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Challenges actifs',
                        '${userStats?.stats.activeChallenges ?? 0}',
                        Icons.play_circle,
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Récompenses',
                        '${statsProvider.achievements.length}',
                        Icons.card_giftcard,
                        AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Taux de réussite',
                        '${userStats?.stats.successRate ?? 0}%',
                        Icons.trending_up,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Derniers accomplissements',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<UserStatsProvider>(
          builder: (context, statsProvider, child) {
            final achievements = statsProvider.achievements;

            if (achievements.isEmpty) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun accomplissement pour le moment',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Participez à des challenges pour débloquer des accomplissements !',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: achievements.take(3).map((achievement) {
                    final index = achievements.indexOf(achievement);
                    return Column(
                      children: [
                        if (index > 0) const Divider(),
                        _buildAchievementItem(
                          achievement.title,
                          achievement.description,
                          _getAchievementIcon(achievement.type),
                          _getAchievementColor(achievement.type),
                          _formatAchievementDate(achievement.dateAwarded),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                'Modifier le profil',
                'Nom d\'utilisateur',
                Icons.edit,
                () {
                  _navigateToEditProfile(context);
                },
              ),

              const Divider(height: 1),
              _buildSettingItem(
                'Confidentialité',
                'Paramètres de confidentialité',
                Icons.privacy_tip,
                () {
                  _navigateToPrivacy(context);
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                'À propos',
                'Version et informations',
                Icons.info,
                () {
                  _navigateToAbout(context);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: AppStrings.logout,
            icon: Icons.logout,
            onPressed: () => _handleLogout(context, authProvider),
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                AppRouter.goLogin(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditProfileScreen()));
  }

  void _navigateToPrivacy(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PrivacyScreen()));
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AboutScreen()));
  }

  /// Calculate user rank based on total stars (simplified calculation)
  int _calculateUserRank(int totalStars) {
    // Simple ranking algorithm - in a real app, this would come from the backend
    if (totalStars >= 500) return 1;
    if (totalStars >= 300) return 2;
    if (totalStars >= 200) return 3;
    if (totalStars >= 100) return 4;
    if (totalStars >= 50) return 5;
    return totalStars ~/ 10 + 6; // Approximate ranking
  }

  /// Get icon for achievement type
  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.badge:
        return Icons.military_tech;
      case AchievementType.bonAchat:
        return Icons.card_giftcard;
      case AchievementType.certificat:
        return Icons.workspace_premium;
      case AchievementType.trophee:
        return Icons.emoji_events;
    }
  }

  /// Get color for achievement type
  Color _getAchievementColor(AchievementType type) {
    switch (type) {
      case AchievementType.badge:
        return AppColors.primary;
      case AchievementType.bonAchat:
        return AppColors.secondary;
      case AchievementType.certificat:
        return AppColors.info;
      case AchievementType.trophee:
        return AppColors.warning;
    }
  }

  /// Format achievement date
  String _formatAchievementDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Il y a ${difference.inMinutes} minutes';
      }
      return 'Il y a ${difference.inHours} heures';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      final months = difference.inDays ~/ 30;
      return 'Il y a $months mois';
    }
  }
}
