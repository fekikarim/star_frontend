import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/data/models/challenge_with_details.dart';
import 'package:intl/intl.dart';

/// Widget for displaying challenge cards
class ChallengeCard extends StatelessWidget {
  final ChallengeWithDetails challenge;
  final VoidCallback? onTap;
  final bool showParticipationStatus;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.showParticipationStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildDates(context),
              const SizedBox(height: 12),
              _buildStats(context),
              if (showParticipationStatus) ...[
                const SizedBox(height: 12),
                _buildParticipationStatus(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildStatusBadge(),
        const Spacer(),
        if (challenge.isEndingSoon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  'Bientôt fini',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = Color(
      int.parse(challenge.statusColorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(challenge.statusIcon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            challenge.statusDisplayName,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      challenge.nom,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDates(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '${dateFormat.format(challenge.dateDebut)} - ${dateFormat.format(challenge.dateFin)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        if (challenge.daysRemainingText != null) ...[
          const SizedBox(width: 12),
          Text(
            '• ${challenge.daysRemainingText}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: challenge.isEndingSoon
                  ? AppColors.error
                  : AppColors.textSecondary,
              fontWeight: challenge.isEndingSoon ? FontWeight.w600 : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people,
          value: challenge.participantsCount.toString(),
          label: 'Participants',
          color: AppColors.primary,
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          icon: Icons.emoji_events,
          value: challenge.winnersCount.toString(),
          label: 'Gagnants',
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildParticipationStatus(BuildContext context) {
    if (challenge.isParticipating) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 16, color: AppColors.success),
            const SizedBox(width: 6),
            Text(
              'Vous participez',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else if (challenge.isFinished) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Challenge terminé',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              challenge.isPending
                  ? 'Pas encore commencé'
                  : 'Rejoindre le challenge',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }
}
