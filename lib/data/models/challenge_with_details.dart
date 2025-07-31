import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/challenge.dart';

part 'challenge_with_details.g.dart';

/// Challenge model with additional details for mobile app
@JsonSerializable()
class ChallengeWithDetails extends Challenge {
  @JsonKey(name: 'participantsCount')
  final int participantsCount;

  @JsonKey(name: 'winnersCount')
  final int winnersCount;

  @JsonKey(name: 'isParticipating')
  final bool isParticipating;

  @JsonKey(name: 'daysRemaining')
  final int? daysRemaining;

  const ChallengeWithDetails({
    required super.id,
    required super.nom,
    required super.dateDebut,
    required super.dateFin,
    required super.statut,
    required super.createurId,
    super.createdAt,
    required this.participantsCount,
    required this.winnersCount,
    required this.isParticipating,
    this.daysRemaining,
  });

  factory ChallengeWithDetails.fromJson(Map<String, dynamic> json) {
    return ChallengeWithDetails(
      id: json['id'] as String,
      nom: json['nom'] as String,
      dateDebut: _parseDate(json['dateDebut']),
      dateFin: _parseDate(json['dateFin']),
      statut: json['statut'] as String,
      createurId: json['createurId'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      participantsCount: json['participantsCount'] as int,
      winnersCount: json['winnersCount'] as int,
      isParticipating: json['isParticipating'] as bool,
      daysRemaining: json['daysRemaining'] as int?,
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

  @override
  Map<String, dynamic> toJson() => _$ChallengeWithDetailsToJson(this);

  /// Get challenge status color as hex string
  String get statusColorHex {
    switch (statut.toLowerCase()) {
      case 'en attente':
      case 'en_attente':
        return '#FF9800'; // Orange
      case 'en cours':
      case 'en_cours':
        return '#4CAF50'; // Green
      case 'terminé':
      case 'termine':
        return '#757575'; // Grey
      default:
        return '#2196F3'; // Blue
    }
  }

  /// Get challenge status icon
  String get statusIcon {
    switch (statut.toLowerCase()) {
      case 'en attente':
      case 'en_attente':
        return '⏳';
      case 'en cours':
      case 'en_cours':
        return '🏃';
      case 'terminé':
      case 'termine':
        return '🏁';
      default:
        return '📋';
    }
  }

  /// Get challenge status display name
  String get statusDisplayName {
    switch (statut.toLowerCase()) {
      case 'en attente':
      case 'en_attente':
        return 'En attente';
      case 'en cours':
      case 'en_cours':
        return 'En cours';
      case 'terminé':
      case 'termine':
        return 'Terminé';
      default:
        return statut;
    }
  }

  /// Check if challenge is active (en_cours)
  @override
  bool get isActive => statut.toLowerCase() == 'en_cours';

  /// Check if challenge is pending (en_attente)
  @override
  bool get isPending => statut.toLowerCase() == 'en_attente';

  /// Check if challenge is finished (termine)
  bool get isFinished =>
      statut.toLowerCase() == 'termine' || statut.toLowerCase() == 'terminé';

  /// Get participation status text
  String get participationStatus {
    if (isParticipating) {
      return 'Vous participez';
    } else if (isFinished) {
      return 'Challenge terminé';
    } else if (isPending) {
      return 'Pas encore commencé';
    } else {
      return 'Rejoindre';
    }
  }

  /// Get days remaining text
  String? get daysRemainingText {
    if (daysRemaining == null) return null;

    if (daysRemaining! <= 0) {
      return 'Terminé';
    } else if (daysRemaining == 1) {
      return '1 jour restant';
    } else {
      return '$daysRemaining jours restants';
    }
  }

  /// Check if challenge is ending soon (less than 3 days)
  bool get isEndingSoon =>
      daysRemaining != null && daysRemaining! > 0 && daysRemaining! <= 3;
}
