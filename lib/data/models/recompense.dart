import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/palier.dart';

part 'recompense.g.dart';

/// Recompense (Reward) model representing rewards for achievements
@JsonSerializable()
class Recompense {
  final String id;
  final String type;
  final String? description;
  @JsonKey(name: 'dateAttribution')
  final DateTime? dateAttribution;
  @JsonKey(name: 'palierId')
  final String? palierId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Palier? palier;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? imageUrl;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? value;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isCollected;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isAvailable;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? expiryDate;
  
  const Recompense({
    required this.id,
    required this.type,
    this.description,
    this.dateAttribution,
    this.palierId,
    this.createdAt,
    this.palier,
    this.imageUrl,
    this.value,
    this.isCollected = false,
    this.isAvailable = true,
    this.expiryDate,
  });
  
  /// Create Recompense from JSON
  factory Recompense.fromJson(Map<String, dynamic> json) => _$RecompenseFromJson(json);
  
  /// Convert Recompense to JSON
  Map<String, dynamic> toJson() => _$RecompenseToJson(this);
  
  /// Create a copy with updated fields
  Recompense copyWith({
    String? id,
    String? type,
    String? description,
    DateTime? dateAttribution,
    String? palierId,
    DateTime? createdAt,
    Palier? palier,
    String? imageUrl,
    String? value,
    bool? isCollected,
    bool? isAvailable,
    DateTime? expiryDate,
  }) {
    return Recompense(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      dateAttribution: dateAttribution ?? this.dateAttribution,
      palierId: palierId ?? this.palierId,
      createdAt: createdAt ?? this.createdAt,
      palier: palier ?? this.palier,
      imageUrl: imageUrl ?? this.imageUrl,
      value: value ?? this.value,
      isCollected: isCollected ?? this.isCollected,
      isAvailable: isAvailable ?? this.isAvailable,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
  
  /// Get reward type display
  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'badge':
        return 'Badge';
      case 'certificate':
        return 'Certificat';
      case 'voucher':
        return 'Bon d\'achat';
      case 'discount':
        return 'Réduction';
      case 'gift':
        return 'Cadeau';
      case 'trophy':
        return 'Trophée';
      case 'medal':
        return 'Médaille';
      case 'points':
        return 'Points';
      default:
        return type;
    }
  }
  
  /// Get reward description or default
  String get displayDescription => description ?? 'Récompense ${typeDisplay.toLowerCase()}';
  
  /// Get reward value display
  String get valueDisplay => value ?? '';
  
  /// Get level name if associated with a level
  String get levelName => palier?.nom ?? '';
  
  /// Check if reward is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  /// Check if reward is new (awarded within last 24 hours)
  bool get isNew {
    if (dateAttribution == null) return false;
    final now = DateTime.now();
    final difference = now.difference(dateAttribution!);
    return difference.inHours < 24;
  }
  
  /// Get time since attribution
  String get timeSince {
    if (dateAttribution == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateAttribution!);
    
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
  
  /// Get time until expiry
  String get timeUntilExpiry {
    if (expiryDate == null) return '';
    if (isExpired) return 'Expiré';
    
    final now = DateTime.now();
    final difference = expiryDate!.difference(now);
    
    if (difference.inDays > 0) {
      return 'Expire dans ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Expire dans ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Expire bientôt';
    }
  }
  
  /// Get reward rarity based on type and level
  RecompenseRarity get rarity {
    if (palier != null) {
      switch (palier!.tier) {
        case PalierTier.legendary:
          return RecompenseRarity.legendary;
        case PalierTier.epic:
          return RecompenseRarity.epic;
        case PalierTier.rare:
          return RecompenseRarity.rare;
        case PalierTier.uncommon:
          return RecompenseRarity.uncommon;
        case PalierTier.common:
          return RecompenseRarity.common;
      }
    }
    
    // Default rarity based on type
    switch (type.toLowerCase()) {
      case 'trophy':
      case 'certificate':
        return RecompenseRarity.rare;
      case 'badge':
      case 'medal':
        return RecompenseRarity.uncommon;
      default:
        return RecompenseRarity.common;
    }
  }
  
  /// Get rarity display
  String get rarityDisplay {
    switch (rarity) {
      case RecompenseRarity.legendary:
        return 'Légendaire';
      case RecompenseRarity.epic:
        return 'Épique';
      case RecompenseRarity.rare:
        return 'Rare';
      case RecompenseRarity.uncommon:
        return 'Peu commun';
      case RecompenseRarity.common:
        return 'Commun';
    }
  }
  
  /// Get default icon based on type
  String get defaultIcon {
    switch (type.toLowerCase()) {
      case 'badge':
        return '🏅';
      case 'certificate':
        return '📜';
      case 'voucher':
        return '🎫';
      case 'discount':
        return '💰';
      case 'gift':
        return '🎁';
      case 'trophy':
        return '🏆';
      case 'medal':
        return '🥇';
      case 'points':
        return '⭐';
      default:
        return '🎖️';
    }
  }
  
  /// Get display icon
  String get displayIcon => imageUrl ?? defaultIcon;
  
  /// Check if reward can be collected
  bool get canBeCollected => isAvailable && !isCollected && !isExpired;
  
  /// Get status display
  String get statusDisplay {
    if (isExpired) return 'Expiré';
    if (isCollected) return 'Collecté';
    if (!isAvailable) return 'Indisponible';
    return 'Disponible';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recompense &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Recompense{id: $id, type: $type, description: $description}';
  }
}

/// Reward rarity enum
enum RecompenseRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Create reward request model
@JsonSerializable()
class CreateRecompenseRequest {
  final String id;
  final String type;
  final String description;
  @JsonKey(name: 'dateAttribution')
  final DateTime dateAttribution;
  @JsonKey(name: 'palierId')
  final String palierId;
  
  const CreateRecompenseRequest({
    required this.id,
    required this.type,
    required this.description,
    required this.dateAttribution,
    required this.palierId,
  });
  
  factory CreateRecompenseRequest.fromJson(Map<String, dynamic> json) => _$CreateRecompenseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRecompenseRequestToJson(this);
}

/// User rewards summary model
@JsonSerializable()
class UserRewardsSummary {
  final String userId;
  final int totalRewards;
  final int collectedRewards;
  final int availableRewards;
  final int expiredRewards;
  final List<Recompense> recentRewards;
  
  const UserRewardsSummary({
    required this.userId,
    required this.totalRewards,
    required this.collectedRewards,
    required this.availableRewards,
    required this.expiredRewards,
    this.recentRewards = const [],
  });
  
  factory UserRewardsSummary.fromJson(Map<String, dynamic> json) => _$UserRewardsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$UserRewardsSummaryToJson(this);
  
  /// Get collection rate (0.0 to 1.0)
  double get collectionRate {
    if (totalRewards == 0) return 0.0;
    return collectedRewards / totalRewards;
  }
  
  /// Get collection percentage
  String get collectionPercentage => '${(collectionRate * 100).toInt()}%';
  
  /// Check if user has pending rewards
  bool get hasPendingRewards => availableRewards > 0;
}
