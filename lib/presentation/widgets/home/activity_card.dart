import 'package:flutter/material.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/data/models/activity.dart';
import 'package:intl/intl.dart';

/// Widget for displaying user activity cards
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  
  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildActivityIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.formattedDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(activity.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActivityValue(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityIcon() {
    Color iconColor;
    switch (activity.type) {
      case ActivityType.etoile:
        iconColor = AppColors.warning;
        break;
      case ActivityType.participation:
        iconColor = AppColors.primary;
        break;
      case ActivityType.victoire:
        iconColor = AppColors.success;
        break;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          activity.icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
  
  Widget _buildActivityValue() {
    String valueText;
    Color valueColor;
    
    switch (activity.type) {
      case ActivityType.etoile:
        valueText = '+${activity.value.toInt()}';
        valueColor = AppColors.warning;
        break;
      case ActivityType.participation:
        valueText = '${activity.value.toInt()} pts';
        valueColor = AppColors.primary;
        break;
      case ActivityType.victoire:
        valueText = '#${activity.value.toInt()}';
        valueColor = AppColors.success;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: valueColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        valueText,
        style: TextStyle(
          color: valueColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
