import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/participant.dart';

part 'performance.g.dart';

/// Performance model representing a participant's performance in a challenge
@JsonSerializable()
class Performance {
  final String id;
  @JsonKey(name: 'participantId')
  final String participantId;
  final double valeur;
  final int rang;
  final String? details; // JSON string
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Participant? participant;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic>? parsedDetails;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? category;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? recordedAt;
  
  const Performance({
    required this.id,
    required this.participantId,
    required this.valeur,
    required this.rang,
    this.details,
    this.createdAt,
    this.participant,
    this.parsedDetails,
    this.category,
    this.recordedAt,
  });
  
  /// Create Performance from JSON
  factory Performance.fromJson(Map<String, dynamic> json) => _$PerformanceFromJson(json);
  
  /// Convert Performance to JSON
  Map<String, dynamic> toJson() => _$PerformanceToJson(this);
  
  /// Create a copy with updated fields
  Performance copyWith({
    String? id,
    String? participantId,
    double? valeur,
    int? rang,
    String? details,
    DateTime? createdAt,
    Participant? participant,
    Map<String, dynamic>? parsedDetails,
    String? category,
    DateTime? recordedAt,
  }) {
    return Performance(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      valeur: valeur ?? this.valeur,
      rang: rang ?? this.rang,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      participant: participant ?? this.participant,
      parsedDetails: parsedDetails ?? this.parsedDetails,
      category: category ?? this.category,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
  
  /// Get formatted value
  String get formattedValue {
    if (valeur == valeur.toInt()) {
      return valeur.toInt().toString();
    }
    return valeur.toStringAsFixed(2);
  }
  
  /// Get value with unit
  String get valueWithUnit => '$formattedValue pts';
  
  /// Get rank display
  String get rankDisplay => '#$rang';
  
  /// Get rank suffix (1st, 2nd, 3rd, etc.)
  String get rankSuffix {
    switch (rang % 10) {
      case 1:
        return rang % 100 == 11 ? 'ème' : 'er';
      case 2:
        return rang % 100 == 12 ? 'ème' : 'ème';
      case 3:
        return rang % 100 == 13 ? 'ème' : 'ème';
      default:
        return 'ème';
    }
  }
  
  /// Get full rank display with suffix
  String get fullRankDisplay => '$rang$rankSuffix';
  
  /// Check if performance is in top 3
  bool get isTopThree => rang <= 3;
  
  /// Check if performance is winner (1st place)
  bool get isWinner => rang == 1;
  
  /// Get performance level based on rank
  PerformanceLevel get level {
    if (rang == 1) return PerformanceLevel.excellent;
    if (rang <= 3) return PerformanceLevel.great;
    if (rang <= 10) return PerformanceLevel.good;
    if (rang <= 50) return PerformanceLevel.average;
    return PerformanceLevel.poor;
  }
  
  /// Get performance score (0.0 to 1.0 based on rank)
  double getPerformanceScore(int totalParticipants) {
    if (totalParticipants <= 0) return 0.0;
    return 1.0 - ((rang - 1) / totalParticipants);
  }
  
  /// Parse details JSON string
  Map<String, dynamic> getDetailsMap() {
    if (parsedDetails != null) return parsedDetails!;
    if (details == null || details!.isEmpty) return {};
    
    try {
      // In a real app, you'd use dart:convert
      // For now, return empty map
      return {};
    } catch (e) {
      return {};
    }
  }
  
  /// Get specific detail value
  T? getDetailValue<T>(String key) {
    final detailsMap = getDetailsMap();
    return detailsMap[key] as T?;
  }
  
  /// Get participant display name
  String get participantName => participant?.displayName ?? 'Participant $participantId';
  
  /// Get performance category display
  String get categoryDisplay => category ?? 'Général';
  
  /// Check if performance is recent (within last 24 hours)
  bool get isRecent {
    final date = recordedAt ?? createdAt;
    if (date == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inHours < 24;
  }
  
  /// Get time since performance
  String get timeSince {
    final date = recordedAt ?? createdAt;
    if (date == null) return 'Date inconnue';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Performance &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Performance{id: $id, participantId: $participantId, valeur: $valeur, rang: $rang}';
  }
}

/// Performance level enum
enum PerformanceLevel {
  excellent,
  great,
  good,
  average,
  poor,
}

/// Create performance request model
@JsonSerializable()
class CreatePerformanceRequest {
  final String id;
  @JsonKey(name: 'participantId')
  final String participantId;
  final double valeur;
  final int rang;
  final String details;
  
  const CreatePerformanceRequest({
    required this.id,
    required this.participantId,
    required this.valeur,
    required this.rang,
    required this.details,
  });
  
  factory CreatePerformanceRequest.fromJson(Map<String, dynamic> json) => _$CreatePerformanceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePerformanceRequestToJson(this);
}

/// Performance statistics model
@JsonSerializable()
class PerformanceStats {
  final double averageScore;
  final double bestScore;
  final double worstScore;
  final int totalPerformances;
  final int improvementCount;
  final double improvementRate;
  
  const PerformanceStats({
    required this.averageScore,
    required this.bestScore,
    required this.worstScore,
    required this.totalPerformances,
    required this.improvementCount,
    required this.improvementRate,
  });
  
  factory PerformanceStats.fromJson(Map<String, dynamic> json) => _$PerformanceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceStatsToJson(this);
  
  /// Get formatted average score
  String get formattedAverageScore => averageScore.toStringAsFixed(1);
  
  /// Get formatted best score
  String get formattedBestScore => bestScore.toStringAsFixed(1);
  
  /// Get formatted worst score
  String get formattedWorstScore => worstScore.toStringAsFixed(1);
  
  /// Get improvement percentage
  String get improvementPercentage => '${(improvementRate * 100).toInt()}%';
}
