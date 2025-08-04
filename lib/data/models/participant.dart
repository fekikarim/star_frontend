import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/user.dart';
import 'package:star_frontend/data/models/challenge.dart';

part 'participant.g.dart';

/// Participant model representing a user participating in a challenge
@JsonSerializable()
class Participant {
  final String id;
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  @JsonKey(name: 'challengeId')
  final String challengeId;
  @JsonKey(name: 'scoreTotal')
  final double scoreTotal;
  @JsonKey(name: 'isValidated')
  final String? isValidated;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final User? utilisateur;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Challenge? challenge;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? rank;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? progress;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? lastActivity;

  const Participant({
    required this.id,
    required this.utilisateurId,
    required this.challengeId,
    required this.scoreTotal,
    this.isValidated,
    this.createdAt,
    this.utilisateur,
    this.challenge,
    this.rank,
    this.progress,
    this.lastActivity,
  });

  /// Create Participant from JSON
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id']?.toString() ?? '',
      utilisateurId: json['utilisateurId']?.toString() ?? '',
      challengeId: json['challengeId']?.toString() ?? '',
      scoreTotal: (json['scoreTotal'] as num?)?.toDouble() ?? 0.0,
      isValidated: json['isValidated']?.toString(),
      createdAt: json['created_at'] != null
          ? _parseDate(json['created_at'])
          : null,
    );
  }

  /// Helper method to parse dates from various formats
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        final timestamp = int.tryParse(dateValue);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
    }

    return DateTime.now();
  }

  /// Convert Participant to JSON
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);

  /// Create a copy with updated fields
  Participant copyWith({
    String? id,
    String? utilisateurId,
    String? challengeId,
    double? scoreTotal,
    String? isValidated,
    DateTime? createdAt,
    User? utilisateur,
    Challenge? challenge,
    int? rank,
    double? progress,
    DateTime? lastActivity,
  }) {
    return Participant(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      challengeId: challengeId ?? this.challengeId,
      scoreTotal: scoreTotal ?? this.scoreTotal,
      isValidated: isValidated ?? this.isValidated,
      createdAt: createdAt ?? this.createdAt,
      utilisateur: utilisateur ?? this.utilisateur,
      challenge: challenge ?? this.challenge,
      rank: rank ?? this.rank,
      progress: progress ?? this.progress,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  /// Get formatted score
  String get formattedScore {
    if (scoreTotal == scoreTotal.toInt()) {
      return scoreTotal.toInt().toString();
    }
    return scoreTotal.toStringAsFixed(1);
  }

  /// Get score with unit
  String get scoreWithUnit => '$formattedScore pts';

  /// Get rank display
  String get rankDisplay {
    if (rank == null) return '-';
    return '#$rank';
  }

  /// Get rank suffix (1st, 2nd, 3rd, etc.)
  String get rankSuffix {
    if (rank == null) return '';

    switch (rank! % 10) {
      case 1:
        return rank! % 100 == 11 ? 'ème' : 'er';
      case 2:
        return rank! % 100 == 12 ? 'ème' : 'ème';
      case 3:
        return rank! % 100 == 13 ? 'ème' : 'ème';
      default:
        return 'ème';
    }
  }

  /// Get full rank display with suffix
  String get fullRankDisplay {
    if (rank == null) return '-';
    return '$rank$rankSuffix';
  }

  /// Check if participant is in top 3
  bool get isTopThree => rank != null && rank! <= 3;

  /// Check if participant is winner (1st place)
  bool get isWinner => rank == 1;

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage => progress ?? 0.0;

  /// Get progress as percentage string
  String get progressDisplay => '${(progressPercentage * 100).toInt()}%';

  /// Get participant display name
  String get displayName => utilisateur?.displayName ?? 'Participant $id';

  /// Get participant initials
  String get initials => utilisateur?.initials ?? 'P';

  /// Check if participant is active (has recent activity)
  bool get isActive {
    if (lastActivity == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActivity!);
    return difference.inDays < 7; // Active if activity within last 7 days
  }

  /// Get activity status
  ParticipantActivityStatus get activityStatus {
    if (lastActivity == null) return ParticipantActivityStatus.unknown;

    final now = DateTime.now();
    final difference = now.difference(lastActivity!);

    if (difference.inHours < 1) return ParticipantActivityStatus.online;
    if (difference.inHours < 24) return ParticipantActivityStatus.recent;
    if (difference.inDays < 7) return ParticipantActivityStatus.active;
    return ParticipantActivityStatus.inactive;
  }

  /// Check if participation is validated
  bool get isParticipationValidated =>
      isValidated?.toLowerCase() == 'validated';

  /// Check if participation is pending
  bool get isParticipationPending => isValidated?.toLowerCase() == 'en_attente';

  /// Check if participation is rejected
  bool get isParticipationRejected => isValidated?.toLowerCase() == 'rejected';

  /// Get validation status display text
  String get validationStatusText {
    switch (isValidated?.toLowerCase()) {
      case 'validated':
        return 'Validé';
      case 'en_attente':
        return 'En attente';
      case 'rejected':
        return 'Rejeté';
      default:
        return 'En attente';
    }
  }

  /// Get validation status enum
  ParticipantValidationStatus get validationStatus {
    switch (isValidated?.toLowerCase()) {
      case 'validated':
        return ParticipantValidationStatus.validated;
      case 'en_attente':
        return ParticipantValidationStatus.pending;
      case 'rejected':
        return ParticipantValidationStatus.rejected;
      default:
        return ParticipantValidationStatus.pending;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Participant{id: $id, utilisateurId: $utilisateurId, challengeId: $challengeId, scoreTotal: $scoreTotal}';
  }
}

/// Participant activity status enum
enum ParticipantActivityStatus { online, recent, active, inactive, unknown }

/// Participant validation status enum
enum ParticipantValidationStatus { validated, pending, rejected }

/// Create participant request model
@JsonSerializable()
class CreateParticipantRequest {
  final String id;
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  @JsonKey(name: 'challengeId')
  final String challengeId;
  @JsonKey(name: 'scoreTotal')
  final double scoreTotal;
  @JsonKey(name: 'isValidated')
  final String? isValidated;

  const CreateParticipantRequest({
    required this.id,
    required this.utilisateurId,
    required this.challengeId,
    this.scoreTotal = 0.0,
    this.isValidated = 'en_attente', // Default to pending
  });

  factory CreateParticipantRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateParticipantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateParticipantRequestToJson(this);
}

/// Participant with ranking information
@JsonSerializable()
class ParticipantRanking {
  final Participant participant;
  final int rank;
  final double score;
  final double? previousScore;
  final int? previousRank;

  const ParticipantRanking({
    required this.participant,
    required this.rank,
    required this.score,
    this.previousScore,
    this.previousRank,
  });

  factory ParticipantRanking.fromJson(Map<String, dynamic> json) =>
      _$ParticipantRankingFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantRankingToJson(this);

  /// Get rank change
  int? get rankChange {
    if (previousRank == null) return null;
    return previousRank! - rank;
  }

  /// Get score change
  double? get scoreChange {
    if (previousScore == null) return null;
    return score - previousScore!;
  }

  /// Check if rank improved
  bool get rankImproved => rankChange != null && rankChange! > 0;

  /// Check if rank declined
  bool get rankDeclined => rankChange != null && rankChange! < 0;

  /// Check if score improved
  bool get scoreImproved => scoreChange != null && scoreChange! > 0;
}
