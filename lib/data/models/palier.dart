import 'package:json_annotation/json_annotation.dart';

part 'palier.g.dart';

/// Palier (Level/Tier) model representing achievement levels
@JsonSerializable()
class Palier {
  final String id;
  final String nom;
  @JsonKey(name: 'etoilesMin')
  final int etoilesMin;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? iconUrl;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? color;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? order;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isUnlocked;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isActive;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? userStars;
  
  const Palier({
    required this.id,
    required this.nom,
    required this.etoilesMin,
    this.description,
    this.createdAt,
    this.iconUrl,
    this.color,
    this.order,
    this.isUnlocked = false,
    this.isActive = false,
    this.userStars,
  });
  
  /// Create Palier from JSON
  factory Palier.fromJson(Map<String, dynamic> json) => _$PalierFromJson(json);
  
  /// Convert Palier to JSON
  Map<String, dynamic> toJson() => _$PalierToJson(this);
  
  /// Create a copy with updated fields
  Palier copyWith({
    String? id,
    String? nom,
    int? etoilesMin,
    String? description,
    DateTime? createdAt,
    String? iconUrl,
    String? color,
    int? order,
    bool? isUnlocked,
    bool? isActive,
    int? userStars,
  }) {
    return Palier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      etoilesMin: etoilesMin ?? this.etoilesMin,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      order: order ?? this.order,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isActive: isActive ?? this.isActive,
      userStars: userStars ?? this.userStars,
    );
  }
  
  /// Get level display name
  String get displayName => nom;
  
  /// Get description or default
  String get displayDescription => description ?? 'Atteignez $etoilesMin étoiles pour débloquer ce niveau';
  
  /// Get required stars display
  String get requiredStarsDisplay {
    if (etoilesMin == 1) return '1 étoile requise';
    return '$etoilesMin étoiles requises';
  }
  
  /// Get progress towards this level (0.0 to 1.0)
  double getProgress(int currentStars) {
    if (currentStars >= etoilesMin) return 1.0;
    if (etoilesMin == 0) return 1.0;
    return currentStars / etoilesMin;
  }
  
  /// Get progress percentage
  String getProgressPercentage(int currentStars) {
    final progress = getProgress(currentStars);
    return '${(progress * 100).toInt()}%';
  }
  
  /// Get remaining stars needed
  int getRemainingStars(int currentStars) {
    if (currentStars >= etoilesMin) return 0;
    return etoilesMin - currentStars;
  }
  
  /// Get remaining stars display
  String getRemainingStarsDisplay(int currentStars) {
    final remaining = getRemainingStars(currentStars);
    if (remaining == 0) return 'Niveau débloqué !';
    if (remaining == 1) return '1 étoile restante';
    return '$remaining étoiles restantes';
  }
  
  /// Check if level is unlocked for user
  bool isUnlockedForUser(int currentStars) {
    return currentStars >= etoilesMin;
  }
  
  /// Check if this is the current active level for user
  bool isCurrentLevel(int currentStars, List<Palier> allLevels) {
    if (!isUnlockedForUser(currentStars)) return false;
    
    // Find the highest unlocked level
    final unlockedLevels = allLevels
        .where((level) => level.isUnlockedForUser(currentStars))
        .toList();
    
    if (unlockedLevels.isEmpty) return false;
    
    unlockedLevels.sort((a, b) => b.etoilesMin.compareTo(a.etoilesMin));
    return unlockedLevels.first.id == id;
  }
  
  /// Get next level
  Palier? getNextLevel(List<Palier> allLevels) {
    final higherLevels = allLevels
        .where((level) => level.etoilesMin > etoilesMin)
        .toList();
    
    if (higherLevels.isEmpty) return null;
    
    higherLevels.sort((a, b) => a.etoilesMin.compareTo(b.etoilesMin));
    return higherLevels.first;
  }
  
  /// Get level tier based on required stars
  PalierTier get tier {
    if (etoilesMin >= 1000) return PalierTier.legendary;
    if (etoilesMin >= 500) return PalierTier.epic;
    if (etoilesMin >= 100) return PalierTier.rare;
    if (etoilesMin >= 50) return PalierTier.uncommon;
    return PalierTier.common;
  }
  
  /// Get tier display
  String get tierDisplay {
    switch (tier) {
      case PalierTier.legendary:
        return 'Légendaire';
      case PalierTier.epic:
        return 'Épique';
      case PalierTier.rare:
        return 'Rare';
      case PalierTier.uncommon:
        return 'Peu commun';
      case PalierTier.common:
        return 'Commun';
    }
  }
  
  /// Get default icon based on tier
  String get defaultIcon {
    switch (tier) {
      case PalierTier.legendary:
        return '👑';
      case PalierTier.epic:
        return '💎';
      case PalierTier.rare:
        return '🏆';
      case PalierTier.uncommon:
        return '🥈';
      case PalierTier.common:
        return '🥉';
    }
  }
  
  /// Get display icon
  String get displayIcon => iconUrl ?? defaultIcon;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Palier &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Palier{id: $id, nom: $nom, etoilesMin: $etoilesMin}';
  }
}

/// Level tier enum
enum PalierTier {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Create level request model
@JsonSerializable()
class CreatePalierRequest {
  final String id;
  final String nom;
  @JsonKey(name: 'etoilesMin')
  final int etoilesMin;
  final String? description;
  
  const CreatePalierRequest({
    required this.id,
    required this.nom,
    required this.etoilesMin,
    this.description,
  });
  
  factory CreatePalierRequest.fromJson(Map<String, dynamic> json) => _$CreatePalierRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePalierRequestToJson(this);
}

/// User level progress model
@JsonSerializable()
class UserLevelProgress {
  final String userId;
  final int totalStars;
  final Palier currentLevel;
  final Palier? nextLevel;
  final double progressToNext;
  final int starsToNext;
  final List<Palier> unlockedLevels;
  
  const UserLevelProgress({
    required this.userId,
    required this.totalStars,
    required this.currentLevel,
    this.nextLevel,
    required this.progressToNext,
    required this.starsToNext,
    this.unlockedLevels = const [],
  });
  
  factory UserLevelProgress.fromJson(Map<String, dynamic> json) => _$UserLevelProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserLevelProgressToJson(this);
  
  /// Get progress percentage to next level
  String get progressPercentage => '${(progressToNext * 100).toInt()}%';
  
  /// Check if user is at max level
  bool get isMaxLevel => nextLevel == null;
  
  /// Get next level display
  String get nextLevelDisplay {
    if (isMaxLevel) return 'Niveau maximum atteint !';
    return 'Prochain niveau: ${nextLevel!.nom}';
  }
  
  /// Get stars to next level display
  String get starsToNextDisplay {
    if (isMaxLevel) return '';
    if (starsToNext == 1) return '1 étoile restante';
    return '$starsToNext étoiles restantes';
  }
}
