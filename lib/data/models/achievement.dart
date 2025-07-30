import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

/// Achievement model representing user achievements
@JsonSerializable()
class Achievement {
  final String id;
  final AchievementType type;
  final String description;
  @JsonKey(name: 'dateAttribution')
  final DateTime dateAwarded;
  final String? icon;
  @JsonKey(name: 'palierNom')
  final String? levelName;
  @JsonKey(name: 'etoilesMin')
  final int? minStars;

  const Achievement({
    required this.id,
    required this.type,
    required this.description,
    required this.dateAwarded,
    this.icon,
    this.levelName,
    this.minStars,
  });

  /// Create achievement from reward data
  factory Achievement.fromReward(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'].toString(),
      type: AchievementType.fromString(json['type'] as String),
      description: json['description'] as String,
      dateAwarded: _parseDate(json['dateAttribution']),
      levelName: json['palierNom'] as String?,
      minStars: json['etoilesMin'] as int?,
    );
  }

  /// Create achievement from badge data
  factory Achievement.fromBadge(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'].toString(),
      type: AchievementType.badge,
      description: json['description'] as String,
      dateAwarded: DateTime.parse(json['dateAttribution'] as String),
      icon: json['icon'] as String?,
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      return DateTime.now();
    }
  }

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  /// Get achievement icon
  String get displayIcon {
    if (icon != null) return icon!;

    switch (type) {
      case AchievementType.badge:
        return '🏅';
      case AchievementType.bonAchat:
        return '🎁';
      case AchievementType.certificat:
        return '📜';
      case AchievementType.trophee:
        return '🏆';
    }
  }

  /// Get achievement color
  String get color {
    switch (type) {
      case AchievementType.badge:
        return '#FFD700';
      case AchievementType.bonAchat:
        return '#E91E63';
      case AchievementType.certificat:
        return '#9C27B0';
      case AchievementType.trophee:
        return '#FF9800';
    }
  }

  /// Get formatted title
  String get title {
    if (levelName != null) {
      return 'Palier $levelName atteint';
    }
    return type.displayName;
  }
}

/// Achievement type enumeration
enum AchievementType {
  badge,
  bonAchat,
  certificat,
  trophee;

  static AchievementType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'badge':
        return AchievementType.badge;
      case 'bon d\'achat':
      case 'bon_achat':
        return AchievementType.bonAchat;
      case 'certificat':
        return AchievementType.certificat;
      case 'trophee':
      case 'trophée':
        return AchievementType.trophee;
      default:
        return AchievementType.badge;
    }
  }

  String get displayName {
    switch (this) {
      case AchievementType.badge:
        return 'Badge';
      case AchievementType.bonAchat:
        return 'Bon d\'achat';
      case AchievementType.certificat:
        return 'Certificat';
      case AchievementType.trophee:
        return 'Trophée';
    }
  }
}
