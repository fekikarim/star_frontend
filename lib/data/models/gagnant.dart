import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/user.dart';
import 'package:star_frontend/data/models/challenge.dart';

part 'gagnant.g.dart';

/// Gagnant (Winner) model representing challenge winners
@JsonSerializable()
class Gagnant {
  final String id;
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  @JsonKey(name: 'challengeId')
  final String challengeId;
  final int classement;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final User? utilisateur;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Challenge? challenge;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? finalScore;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? prize;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isPrizeClaimed;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? prizeClaimedAt;
  
  const Gagnant({
    required this.id,
    required this.utilisateurId,
    required this.challengeId,
    required this.classement,
    this.createdAt,
    this.utilisateur,
    this.challenge,
    this.finalScore,
    this.prize,
    this.isPrizeClaimed = false,
    this.prizeClaimedAt,
  });
  
  /// Create Gagnant from JSON
  factory Gagnant.fromJson(Map<String, dynamic> json) => _$GagnantFromJson(json);
  
  /// Convert Gagnant to JSON
  Map<String, dynamic> toJson() => _$GagnantToJson(this);
  
  /// Create a copy with updated fields
  Gagnant copyWith({
    String? id,
    String? utilisateurId,
    String? challengeId,
    int? classement,
    DateTime? createdAt,
    User? utilisateur,
    Challenge? challenge,
    double? finalScore,
    String? prize,
    bool? isPrizeClaimed,
    DateTime? prizeClaimedAt,
  }) {
    return Gagnant(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      challengeId: challengeId ?? this.challengeId,
      classement: classement ?? this.classement,
      createdAt: createdAt ?? this.createdAt,
      utilisateur: utilisateur ?? this.utilisateur,
      challenge: challenge ?? this.challenge,
      finalScore: finalScore ?? this.finalScore,
      prize: prize ?? this.prize,
      isPrizeClaimed: isPrizeClaimed ?? this.isPrizeClaimed,
      prizeClaimedAt: prizeClaimedAt ?? this.prizeClaimedAt,
    );
  }
  
  /// Get rank display
  String get rankDisplay => '#$classement';
  
  /// Get rank suffix (1st, 2nd, 3rd, etc.)
  String get rankSuffix {
    switch (classement % 10) {
      case 1:
        return classement % 100 == 11 ? 'ème' : 'er';
      case 2:
        return classement % 100 == 12 ? 'ème' : 'ème';
      case 3:
        return classement % 100 == 13 ? 'ème' : 'ème';
      default:
        return 'ème';
    }
  }
  
  /// Get full rank display with suffix
  String get fullRankDisplay => '$classement$rankSuffix';
  
  /// Check if this is first place
  bool get isFirstPlace => classement == 1;
  
  /// Check if this is in top 3
  bool get isTopThree => classement <= 3;
  
  /// Check if this is in top 10
  bool get isTopTen => classement <= 10;
  
  /// Get winner tier based on ranking
  WinnerTier get tier {
    if (classement == 1) return WinnerTier.gold;
    if (classement == 2) return WinnerTier.silver;
    if (classement == 3) return WinnerTier.bronze;
    if (classement <= 10) return WinnerTier.top10;
    return WinnerTier.participant;
  }
  
  /// Get tier display
  String get tierDisplay {
    switch (tier) {
      case WinnerTier.gold:
        return 'Or';
      case WinnerTier.silver:
        return 'Argent';
      case WinnerTier.bronze:
        return 'Bronze';
      case WinnerTier.top10:
        return 'Top 10';
      case WinnerTier.participant:
        return 'Participant';
    }
  }
  
  /// Get tier emoji
  String get tierEmoji {
    switch (tier) {
      case WinnerTier.gold:
        return '🥇';
      case WinnerTier.silver:
        return '🥈';
      case WinnerTier.bronze:
        return '🥉';
      case WinnerTier.top10:
        return '🏆';
      case WinnerTier.participant:
        return '🎖️';
    }
  }
  
  /// Get winner display name
  String get winnerName => utilisateur?.displayName ?? 'Gagnant $id';
  
  /// Get winner initials
  String get winnerInitials => utilisateur?.initials ?? 'G';
  
  /// Get challenge name
  String get challengeName => challenge?.nom ?? 'Challenge $challengeId';
  
  /// Get formatted final score
  String get formattedFinalScore {
    if (finalScore == null) return '-';
    if (finalScore! == finalScore!.toInt()) {
      return finalScore!.toInt().toString();
    }
    return finalScore!.toStringAsFixed(1);
  }
  
  /// Get score with unit
  String get scoreWithUnit {
    if (finalScore == null) return '-';
    return '$formattedFinalScore pts';
  }
  
  /// Get prize display
  String get prizeDisplay => prize ?? 'Récompense ${tierDisplay.toLowerCase()}';
  
  /// Get prize status
  String get prizeStatus {
    if (!isPrizeClaimed) return 'En attente';
    return 'Réclamé';
  }
  
  /// Check if prize is available to claim
  bool get canClaimPrize => !isPrizeClaimed && prize != null;
  
  /// Get time since win
  String get timeSinceWin {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'il y a $years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Récemment';
    }
  }
  
  /// Check if this is a recent win (within last 7 days)
  bool get isRecentWin {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inDays < 7;
  }
  
  /// Get achievement level based on ranking
  AchievementLevel get achievementLevel {
    if (classement == 1) return AchievementLevel.champion;
    if (classement <= 3) return AchievementLevel.podium;
    if (classement <= 10) return AchievementLevel.excellent;
    if (classement <= 25) return AchievementLevel.great;
    return AchievementLevel.good;
  }
  
  /// Get achievement display
  String get achievementDisplay {
    switch (achievementLevel) {
      case AchievementLevel.champion:
        return 'Champion';
      case AchievementLevel.podium:
        return 'Podium';
      case AchievementLevel.excellent:
        return 'Excellent';
      case AchievementLevel.great:
        return 'Très bien';
      case AchievementLevel.good:
        return 'Bien';
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gagnant &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Gagnant{id: $id, utilisateurId: $utilisateurId, challengeId: $challengeId, classement: $classement}';
  }
}

/// Winner tier enum
enum WinnerTier {
  gold,
  silver,
  bronze,
  top10,
  participant,
}

/// Achievement level enum
enum AchievementLevel {
  champion,
  podium,
  excellent,
  great,
  good,
}

/// Create winner request model
@JsonSerializable()
class CreateGagnantRequest {
  final String id;
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  @JsonKey(name: 'challengeId')
  final String challengeId;
  final int classement;
  
  const CreateGagnantRequest({
    required this.id,
    required this.utilisateurId,
    required this.challengeId,
    required this.classement,
  });
  
  factory CreateGagnantRequest.fromJson(Map<String, dynamic> json) => _$CreateGagnantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateGagnantRequestToJson(this);
}

/// Challenge winners summary model
@JsonSerializable()
class ChallengeWinnersSummary {
  final String challengeId;
  final List<Gagnant> winners;
  final int totalParticipants;
  final DateTime? determinedAt;
  
  const ChallengeWinnersSummary({
    required this.challengeId,
    required this.winners,
    required this.totalParticipants,
    this.determinedAt,
  });
  
  factory ChallengeWinnersSummary.fromJson(Map<String, dynamic> json) => _$ChallengeWinnersSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeWinnersSummaryToJson(this);
  
  /// Get top 3 winners
  List<Gagnant> get topThree => winners.where((w) => w.isTopThree).toList();
  
  /// Get champion (1st place)
  Gagnant? get champion => winners.where((w) => w.isFirstPlace).firstOrNull;
  
  /// Get podium winners (top 3)
  List<Gagnant> get podium => topThree;
  
  /// Check if winners have been determined
  bool get hasWinners => winners.isNotEmpty;
}
