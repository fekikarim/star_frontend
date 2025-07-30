import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/user.dart';

part 'user_stats.g.dart';

/// User statistics model
@JsonSerializable()
class UserStats {
  final User user;
  final UserStatsData stats;
  final UserLevel level;

  const UserStats({
    required this.user,
    required this.stats,
    required this.level,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

/// User statistics data
@JsonSerializable()
class UserStatsData {
  @JsonKey(name: 'totalEtoiles')
  final int totalStars;

  @JsonKey(name: 'challengesParticipes')
  final int challengesParticipated;

  @JsonKey(name: 'challengesGagnes')
  final int challengesWon;

  @JsonKey(name: 'challengesActifs')
  final int activeChallenges;

  @JsonKey(name: 'etoilesSemaine')
  final int weeklyStars;

  @JsonKey(name: 'tauxReussite')
  final int successRate;

  const UserStatsData({
    required this.totalStars,
    required this.challengesParticipated,
    required this.challengesWon,
    required this.activeChallenges,
    required this.weeklyStars,
    required this.successRate,
  });

  factory UserStatsData.fromJson(Map<String, dynamic> json) =>
      _$UserStatsDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsDataToJson(this);
}

/// User level information
@JsonSerializable()
class UserLevel {
  final Level current;
  final Level? next;
  final int progress;
  @JsonKey(name: 'starsToNext')
  final int starsToNext;

  const UserLevel({
    required this.current,
    this.next,
    required this.progress,
    required this.starsToNext,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) =>
      _$UserLevelFromJson(json);
  Map<String, dynamic> toJson() => _$UserLevelToJson(this);
}

/// Level model
@JsonSerializable()
class Level {
  final String? id;
  final String nom;
  @JsonKey(name: 'etoilesMin')
  final int minStars;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const Level({
    this.id,
    required this.nom,
    required this.minStars,
    this.description,
    this.createdAt,
  });

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelToJson(this);

  /// Get level icon based on minimum stars required
  String get icon {
    if (minStars >= 1000) return '👑';
    if (minStars >= 500) return '💎';
    if (minStars >= 200) return '🏆';
    if (minStars >= 100) return '🥇';
    if (minStars >= 50) return '🥈';
    if (minStars >= 20) return '🥉';
    if (minStars >= 10) return '⭐';
    return '🌟';
  }

  /// Get level color based on minimum stars required
  String get color {
    if (minStars >= 1000) return '#FFD700'; // Gold
    if (minStars >= 500) return '#E6E6FA'; // Lavender
    if (minStars >= 200) return '#FF6347'; // Tomato
    if (minStars >= 100) return '#32CD32'; // LimeGreen
    if (minStars >= 50) return '#1E90FF'; // DodgerBlue
    if (minStars >= 20) return '#FF69B4'; // HotPink
    if (minStars >= 10) return '#FFA500'; // Orange
    return '#87CEEB'; // SkyBlue
  }

  /// Check if this is the starting level
  bool get isStartingLevel => minStars == 0;

  /// Check if this is a premium level
  bool get isPremiumLevel => minStars >= 500;
}
