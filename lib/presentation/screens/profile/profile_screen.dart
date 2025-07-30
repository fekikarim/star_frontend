import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/core/navigation/app_router.dart';
import 'package:star_frontend/presentation/providers/auth_provider.dart';
import 'package:star_frontend/presentation/widgets/common/custom_button.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: const Text(
          AppStrings.profile,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.white),
          onPressed: () {
            // TODO: Navigate to edit profile screen
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.userEmail,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat('Niveau', '12', Icons.star),
                _buildProfileStat('Étoiles', '127', Icons.star_border),
                _buildProfileStat('Rang', '#5', Icons.leaderboard),
              ],
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
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Challenges terminés',
                '8',
                Icons.emoji_events,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Challenges actifs',
                '3',
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
                '12',
                Icons.card_giftcard,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Taux de réussite',
                '85%',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAchievementItem(
                  'Champion Innovation',
                  '1ère place au Challenge Innovation 2024',
                  Icons.emoji_events,
                  AppColors.warning,
                  'Il y a 2 jours',
                ),
                const Divider(),
                _buildAchievementItem(
                  'Expert Niveau 10',
                  'Niveau Expert atteint',
                  Icons.star,
                  AppColors.primary,
                  'Il y a 1 semaine',
                ),
                const Divider(),
                _buildAchievementItem(
                  'Collaborateur Actif',
                  '50 challenges terminés',
                  Icons.group,
                  AppColors.success,
                  'Il y a 2 semaines',
                ),
              ],
            ),
          ),
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
              color: color.withOpacity(0.1),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
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
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
                'Nom, email, photo',
                Icons.edit,
                () {
                  // TODO: Navigate to edit profile
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                'Notifications',
                'Gérer les notifications',
                Icons.notifications,
                () {
                  // TODO: Navigate to notifications settings
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                'Confidentialité',
                'Paramètres de confidentialité',
                Icons.privacy_tip,
                () {
                  // TODO: Navigate to privacy settings
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                'À propos',
                'Version et informations',
                Icons.info,
                () {
                  _showAboutDialog(context);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: AppStrings.appVersion,
      applicationIcon: const Icon(
        Icons.star,
        size: 48,
        color: AppColors.primary,
      ),
      children: [
        const Text('Application de gestion des challenges et récompenses.'),
        const SizedBox(height: 16),
        const Text('© 2024 STAR Challenge Team'),
      ],
    );
  }
}
