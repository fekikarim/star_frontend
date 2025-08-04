import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';

/// Privacy policy screen
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              'Collecte des données',
              'Nous collectons uniquement les informations nécessaires au fonctionnement de l\'application STAR Challenge, notamment :\n\n• Votre nom d\'utilisateur\n• Votre adresse email\n• Vos participations aux challenges\n• Vos performances et récompenses',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Utilisation des données',
              'Vos données personnelles sont utilisées exclusivement pour :\n\n• Gérer votre compte utilisateur\n• Suivre vos participations aux challenges\n• Calculer vos performances et classements\n• Vous attribuer des récompenses\n• Améliorer l\'expérience utilisateur',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Protection des données',
              'Nous nous engageons à protéger vos données personnelles :\n\n• Chiffrement des données sensibles\n• Accès restreint aux données\n• Stockage sécurisé\n• Pas de partage avec des tiers\n• Conformité aux réglementations en vigueur',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Vos droits',
              'Vous disposez des droits suivants concernant vos données :\n\n• Droit d\'accès à vos données\n• Droit de rectification\n• Droit de suppression\n• Droit à la portabilité\n• Droit d\'opposition au traitement',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Conservation des données',
              'Vos données sont conservées pendant la durée nécessaire aux finalités pour lesquelles elles ont été collectées, et conformément aux obligations légales.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Cookies et technologies similaires',
              'L\'application peut utiliser des technologies de stockage local pour améliorer votre expérience utilisateur et maintenir votre session.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Modifications de la politique',
              'Cette politique de confidentialité peut être mise à jour. Nous vous informerons de tout changement significatif.',
            ),
            const SizedBox(height: 20),
            _buildContactSection(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.privacy_tip,
              size: 48,
              color: AppColors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'Politique de Confidentialité',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre vie privée est importante pour nous',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
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
                Icon(
                  Icons.contact_support,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Pour toute question concernant cette politique de confidentialité ou pour exercer vos droits, contactez-nous :',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.email,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'contact@starchallenge.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '© 2025 STAR Challenge - Tous droits réservés',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
