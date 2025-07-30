import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/user.dart';

part 'leaderboard.g.dart';

/// Leaderboard model
@JsonSerializable()
class Leaderboard {
  final LeaderboardType type;
  final String period;
  @JsonKey(name: 'leaderboard')
  final List<LeaderboardEntry> entries;
  
  const Leaderboard({
    required this.type,
    required this.period,
    required this.entries,
  });
  
  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      type: LeaderboardType.fromString(json['type'] as String),
      period: json['period'] as String,
      entries: (json['leaderboard'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() => _$LeaderboardToJson(this);
}

/// Leaderboard entry model
@JsonSerializable()
class LeaderboardEntry {
  final int rang;
  @JsonKey(name: 'utilisateur')
  final User user;
  final LeaderboardStats stats;
  
  const LeaderboardEntry({
    required this.rang,
    required this.user,
    required this.stats,
  });
  
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
  
  /// Get rank display with medal for top 3
  String get rankDisplay {
    switch (rang) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rang';
    }
  }
  
  /// Get rank color
  String get rankColor {
    switch (rang) {
      case 1:
        return '#FFD700';
      case 2:
        return '#C0C0C0';
      case 3:
        return '#CD7F32';
      default:
        return '#757575';
    }
  }
}

/// Leaderboard statistics model
@JsonSerializable()
class LeaderboardStats {
  // Global stats
  @JsonKey(name: 'totalEtoiles')
  final int? totalStars;
  @JsonKey(name: 'challengesParticipes')
  final int? challengesParticipated;
  @JsonKey(name: 'challengesGagnes')
  final int? challengesWon;
  @JsonKey(name: 'tauxReussite')
  final double? successRate;
  
  // Weekly stats
  @JsonKey(name: 'etoilesSemaine')
  final int? weeklyStars;
  @JsonKey(name: 'challengesSemaine')
  final int? weeklyChallenges;
  @JsonKey(name: 'victoiresSemaine')
  final int? weeklyWins;
  
  // Monthly stats
  @JsonKey(name: 'etoilesMois')
  final int? monthlyStars;
  @JsonKey(name: 'challengesMois')
  final int? monthlyChallenges;
  @JsonKey(name: 'victoiresMois')
  final int? monthlyWins;
  
  const LeaderboardStats({
    this.totalStars,
    this.challengesParticipated,
    this.challengesWon,
    this.successRate,
    this.weeklyStars,
    this.weeklyChallenges,
    this.weeklyWins,
    this.monthlyStars,
    this.monthlyChallenges,
    this.monthlyWins,
  });
  
  factory LeaderboardStats.fromJson(Map<String, dynamic> json) => _$LeaderboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardStatsToJson(this);
  
  /// Get primary score based on available data
  int get primaryScore {
    return totalStars ?? weeklyStars ?? monthlyStars ?? 0;
  }
  
  /// Get secondary metric for display
  String get secondaryMetric {
    if (challengesWon != null) {
      return '${challengesWon} victoires';
    } else if (weeklyWins != null) {
      return '${weeklyWins} victoires cette semaine';
    } else if (monthlyWins != null) {
      return '${monthlyWins} victoires ce mois';
    }
    return '';
  }
}

/// Leaderboard type enumeration
enum LeaderboardType {
  global,
  weekly,
  monthly;
  
  static LeaderboardType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'global':
        return LeaderboardType.global;
      case 'weekly':
        return LeaderboardType.weekly;
      case 'monthly':
        return LeaderboardType.monthly;
      default:
        return LeaderboardType.global;
    }
  }
  
  String get displayName {
    switch (this) {
      case LeaderboardType.global:
        return 'Global';
      case LeaderboardType.weekly:
        return 'Cette semaine';
      case LeaderboardType.monthly:
        return 'Ce mois';
    }
  }
  
  String get apiValue {
    switch (this) {
      case LeaderboardType.global:
        return 'global';
      case LeaderboardType.weekly:
        return 'weekly';
      case LeaderboardType.monthly:
        return 'monthly';
    }
  }
}
