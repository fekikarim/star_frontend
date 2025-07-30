import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

/// Activity model representing user activities
@JsonSerializable()
class Activity {
  final String id;
  final ActivityType type;
  final double value;
  final String description;
  @JsonKey(name: 'challengeNom')
  final String? challengeName;
  final DateTime date;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.type,
    required this.value,
    required this.description,
    this.challengeName,
    required this.date,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'].toString(),
      type: ActivityType.fromString(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      description: json['description'] as String,
      challengeName: json['challengeNom'] as String?,
      date: _parseDate(json['date']),
      createdAt: DateTime.parse(json['createdAt'] as String),
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

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  /// Get activity icon based on type
  String get icon {
    switch (type) {
      case ActivityType.etoile:
        return '⭐';
      case ActivityType.participation:
        return '🎯';
      case ActivityType.victoire:
        return '🏆';
    }
  }

  /// Get activity color based on type
  String get color {
    switch (type) {
      case ActivityType.etoile:
        return '#FFD700';
      case ActivityType.participation:
        return '#2196F3';
      case ActivityType.victoire:
        return '#4CAF50';
    }
  }

  /// Get formatted description
  String get formattedDescription {
    switch (type) {
      case ActivityType.etoile:
        return '$description (+${value.toInt()} étoiles)';
      case ActivityType.participation:
        return challengeName != null
            ? 'Participation au challenge "$challengeName"'
            : description;
      case ActivityType.victoire:
        return challengeName != null
            ? 'Victoire dans "$challengeName" (${value.toInt()}${_getOrdinalSuffix(value.toInt())} place)'
            : description;
    }
  }

  String _getOrdinalSuffix(int number) {
    switch (number) {
      case 1:
        return 'ère';
      default:
        return 'ème';
    }
  }
}

/// Activity type enumeration
enum ActivityType {
  etoile,
  participation,
  victoire;

  static ActivityType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'etoile':
        return ActivityType.etoile;
      case 'participation':
        return ActivityType.participation;
      case 'victoire':
        return ActivityType.victoire;
      default:
        throw ArgumentError('Unknown activity type: $value');
    }
  }

  String get displayName {
    switch (this) {
      case ActivityType.etoile:
        return 'Étoiles gagnées';
      case ActivityType.participation:
        return 'Participation';
      case ActivityType.victoire:
        return 'Victoire';
    }
  }
}
