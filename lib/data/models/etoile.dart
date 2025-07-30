import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/user.dart';

part 'etoile.g.dart';

/// Etoile (Star) model representing stars awarded to users
@JsonSerializable()
class Etoile {
  final String id;
  final int total;
  @JsonKey(name: 'dateAttribution')
  final DateTime dateAttribution;
  final String? raison;
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final User? utilisateur;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final EtoileType? type;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? challengeId;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isNew;
  
  const Etoile({
    required this.id,
    required this.total,
    required this.dateAttribution,
    this.raison,
    required this.utilisateurId,
    this.createdAt,
    this.utilisateur,
    this.type,
    this.challengeId,
    this.isNew = false,
  });
  
  /// Create Etoile from JSON
  factory Etoile.fromJson(Map<String, dynamic> json) => _$EtoileFromJson(json);
  
  /// Convert Etoile to JSON
  Map<String, dynamic> toJson() => _$EtoileToJson(this);
  
  /// Create a copy with updated fields
  Etoile copyWith({
    String? id,
    int? total,
    DateTime? dateAttribution,
    String? raison,
    String? utilisateurId,
    DateTime? createdAt,
    User? utilisateur,
    EtoileType? type,
    String? challengeId,
    bool? isNew,
  }) {
    return Etoile(
      id: id ?? this.id,
      total: total ?? this.total,
      dateAttribution: dateAttribution ?? this.dateAttribution,
      raison: raison ?? this.raison,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      createdAt: createdAt ?? this.createdAt,
      utilisateur: utilisateur ?? this.utilisateur,
      type: type ?? this.type,
      challengeId: challengeId ?? this.challengeId,
      isNew: isNew ?? this.isNew,
    );
  }
  
  /// Get star display text
  String get starDisplay {
    if (total == 1) return '1 étoile';
    return '$total étoiles';
  }
  
  /// Get star emoji representation
  String get starEmoji {
    if (total <= 0) return '';
    if (total == 1) return '⭐';
    if (total <= 3) return '⭐' * total;
    return '⭐ x$total';
  }
  
  /// Get reason display
  String get reasonDisplay => raison ?? 'Étoile attribuée';
  
  /// Get user display name
  String get userDisplayName => utilisateur?.displayName ?? 'Utilisateur $utilisateurId';
  
  /// Get star type display
  String get typeDisplay {
    switch (type) {
      case EtoileType.challenge:
        return 'Challenge';
      case EtoileType.performance:
        return 'Performance';
      case EtoileType.participation:
        return 'Participation';
      case EtoileType.achievement:
        return 'Accomplissement';
      case EtoileType.bonus:
        return 'Bonus';
      case null:
        return 'Général';
    }
  }
  
  /// Check if star is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(dateAttribution);
    return difference.inHours < 24;
  }
  
  /// Get time since attribution
  String get timeSince {
    final now = DateTime.now();
    final difference = now.difference(dateAttribution);
    
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
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }
  
  /// Get star value (for calculations)
  int get value => total;
  
  /// Check if this is a significant star award (5+ stars)
  bool get isSignificant => total >= 5;
  
  /// Get star rarity level
  EtoileRarity get rarity {
    if (total >= 20) return EtoileRarity.legendary;
    if (total >= 10) return EtoileRarity.epic;
    if (total >= 5) return EtoileRarity.rare;
    if (total >= 3) return EtoileRarity.uncommon;
    return EtoileRarity.common;
  }
  
  /// Get rarity display
  String get rarityDisplay {
    switch (rarity) {
      case EtoileRarity.legendary:
        return 'Légendaire';
      case EtoileRarity.epic:
        return 'Épique';
      case EtoileRarity.rare:
        return 'Rare';
      case EtoileRarity.uncommon:
        return 'Peu commun';
      case EtoileRarity.common:
        return 'Commun';
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Etoile &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Etoile{id: $id, total: $total, utilisateurId: $utilisateurId, raison: $raison}';
  }
}

/// Star type enum
enum EtoileType {
  challenge,
  performance,
  participation,
  achievement,
  bonus,
}

/// Star rarity enum
enum EtoileRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Create star request model
@JsonSerializable()
class CreateEtoileRequest {
  final String id;
  final int total;
  @JsonKey(name: 'dateAttribution')
  final DateTime dateAttribution;
  final String raison;
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  
  const CreateEtoileRequest({
    required this.id,
    required this.total,
    required this.dateAttribution,
    required this.raison,
    required this.utilisateurId,
  });
  
  factory CreateEtoileRequest.fromJson(Map<String, dynamic> json) => _$CreateEtoileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateEtoileRequestToJson(this);
}

/// User star summary model
@JsonSerializable()
class UserStarSummary {
  @JsonKey(name: 'utilisateurId')
  final String utilisateurId;
  final int totalStars;
  final int starCount;
  final DateTime? lastStarDate;
  final List<Etoile> recentStars;
  
  const UserStarSummary({
    required this.utilisateurId,
    required this.totalStars,
    required this.starCount,
    this.lastStarDate,
    this.recentStars = const [],
  });
  
  factory UserStarSummary.fromJson(Map<String, dynamic> json) => _$UserStarSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$UserStarSummaryToJson(this);
  
  /// Get average stars per award
  double get averageStarsPerAward {
    if (starCount == 0) return 0.0;
    return totalStars / starCount;
  }
  
  /// Get formatted average
  String get formattedAverage => averageStarsPerAward.toStringAsFixed(1);
  
  /// Check if user has recent activity
  bool get hasRecentActivity {
    if (lastStarDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastStarDate!);
    return difference.inDays < 7;
  }
}
