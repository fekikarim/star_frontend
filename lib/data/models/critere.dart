import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/challenge.dart';

part 'critere.g.dart';

/// Critere (Criteria) model representing evaluation criteria for challenges
@JsonSerializable()
class Critere {
  final String id;
  final String nom;
  final double poids;
  @JsonKey(name: 'challengeId')
  final String challengeId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Challenge? challenge;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? description;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? unit;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? minValue;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? maxValue;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final CritereType? type;
  
  const Critere({
    required this.id,
    required this.nom,
    required this.poids,
    required this.challengeId,
    this.createdAt,
    this.challenge,
    this.description,
    this.unit,
    this.minValue,
    this.maxValue,
    this.type,
  });
  
  /// Create Critere from JSON
  factory Critere.fromJson(Map<String, dynamic> json) => _$CritereFromJson(json);
  
  /// Convert Critere to JSON
  Map<String, dynamic> toJson() => _$CritereToJson(this);
  
  /// Create a copy with updated fields
  Critere copyWith({
    String? id,
    String? nom,
    double? poids,
    String? challengeId,
    DateTime? createdAt,
    Challenge? challenge,
    String? description,
    String? unit,
    double? minValue,
    double? maxValue,
    CritereType? type,
  }) {
    return Critere(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      poids: poids ?? this.poids,
      challengeId: challengeId ?? this.challengeId,
      createdAt: createdAt ?? this.createdAt,
      challenge: challenge ?? this.challenge,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      type: type ?? this.type,
    );
  }
  
  /// Get criteria display name
  String get displayName => nom;
  
  /// Get criteria description or default
  String get displayDescription => description ?? 'Critère d\'évaluation: $nom';
  
  /// Get weight as percentage
  double get weightPercentage => poids * 100;
  
  /// Get formatted weight
  String get formattedWeight {
    if (poids == poids.toInt()) {
      return poids.toInt().toString();
    }
    return poids.toStringAsFixed(2);
  }
  
  /// Get weight display
  String get weightDisplay => '${formattedWeight}%';
  
  /// Get unit display
  String get unitDisplay => unit ?? '';
  
  /// Get value range display
  String get rangeDisplay {
    if (minValue != null && maxValue != null) {
      return '${minValue!.toStringAsFixed(1)} - ${maxValue!.toStringAsFixed(1)} $unitDisplay';
    } else if (minValue != null) {
      return 'Min: ${minValue!.toStringAsFixed(1)} $unitDisplay';
    } else if (maxValue != null) {
      return 'Max: ${maxValue!.toStringAsFixed(1)} $unitDisplay';
    }
    return '';
  }
  
  /// Get criteria type display
  String get typeDisplay {
    switch (type) {
      case CritereType.numeric:
        return 'Numérique';
      case CritereType.percentage:
        return 'Pourcentage';
      case CritereType.time:
        return 'Temps';
      case CritereType.score:
        return 'Score';
      case CritereType.rating:
        return 'Note';
      case CritereType.boolean:
        return 'Oui/Non';
      case null:
        return 'Standard';
    }
  }
  
  /// Get challenge name
  String get challengeName => challenge?.nom ?? 'Challenge $challengeId';
  
  /// Check if criteria has valid range
  bool get hasValidRange {
    if (minValue == null || maxValue == null) return true;
    return minValue! <= maxValue!;
  }
  
  /// Validate a value against this criteria
  bool validateValue(double value) {
    if (minValue != null && value < minValue!) return false;
    if (maxValue != null && value > maxValue!) return false;
    return true;
  }
  
  /// Calculate score for a value (0.0 to 1.0)
  double calculateScore(double value) {
    if (!validateValue(value)) return 0.0;
    
    if (minValue != null && maxValue != null) {
      if (maxValue! == minValue!) return 1.0;
      return (value - minValue!) / (maxValue! - minValue!);
    } else if (maxValue != null) {
      return (value / maxValue!).clamp(0.0, 1.0);
    }
    
    return 1.0; // Default score if no range specified
  }
  
  /// Get weighted score for a value
  double getWeightedScore(double value) {
    return calculateScore(value) * poids;
  }
  
  /// Get importance level based on weight
  CritereImportance get importance {
    if (poids >= 0.5) return CritereImportance.critical;
    if (poids >= 0.3) return CritereImportance.high;
    if (poids >= 0.15) return CritereImportance.medium;
    if (poids >= 0.05) return CritereImportance.low;
    return CritereImportance.minimal;
  }
  
  /// Get importance display
  String get importanceDisplay {
    switch (importance) {
      case CritereImportance.critical:
        return 'Critique';
      case CritereImportance.high:
        return 'Élevée';
      case CritereImportance.medium:
        return 'Moyenne';
      case CritereImportance.low:
        return 'Faible';
      case CritereImportance.minimal:
        return 'Minimale';
    }
  }
  
  /// Get default icon based on type
  String get defaultIcon {
    switch (type) {
      case CritereType.numeric:
        return '🔢';
      case CritereType.percentage:
        return '📊';
      case CritereType.time:
        return '⏱️';
      case CritereType.score:
        return '🎯';
      case CritereType.rating:
        return '⭐';
      case CritereType.boolean:
        return '✅';
      case null:
        return '📋';
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Critere &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Critere{id: $id, nom: $nom, poids: $poids, challengeId: $challengeId}';
  }
}

/// Criteria type enum
enum CritereType {
  numeric,
  percentage,
  time,
  score,
  rating,
  boolean,
}

/// Criteria importance enum
enum CritereImportance {
  critical,
  high,
  medium,
  low,
  minimal,
}

/// Create criteria request model
@JsonSerializable()
class CreateCritereRequest {
  final String id;
  final String nom;
  final double poids;
  @JsonKey(name: 'challengeId')
  final String challengeId;
  
  const CreateCritereRequest({
    required this.id,
    required this.nom,
    required this.poids,
    required this.challengeId,
  });
  
  factory CreateCritereRequest.fromJson(Map<String, dynamic> json) => _$CreateCritereRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCritereRequestToJson(this);
}

/// Criteria evaluation model
@JsonSerializable()
class CritereEvaluation {
  final String critereId;
  final String participantId;
  final double value;
  final double score;
  final double weightedScore;
  final String? notes;
  final DateTime evaluatedAt;
  
  const CritereEvaluation({
    required this.critereId,
    required this.participantId,
    required this.value,
    required this.score,
    required this.weightedScore,
    this.notes,
    required this.evaluatedAt,
  });
  
  factory CritereEvaluation.fromJson(Map<String, dynamic> json) => _$CritereEvaluationFromJson(json);
  Map<String, dynamic> toJson() => _$CritereEvaluationToJson(this);
  
  /// Get formatted value
  String get formattedValue => value.toStringAsFixed(2);
  
  /// Get formatted score
  String get formattedScore => '${(score * 100).toInt()}%';
  
  /// Get formatted weighted score
  String get formattedWeightedScore => weightedScore.toStringAsFixed(2);
}
