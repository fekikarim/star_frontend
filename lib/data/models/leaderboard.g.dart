// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Leaderboard _$LeaderboardFromJson(Map<String, dynamic> json) => Leaderboard(
  type: $enumDecode(_$LeaderboardTypeEnumMap, json['type']),
  period: json['period'] as String,
  entries: (json['leaderboard'] as List<dynamic>)
      .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LeaderboardToJson(Leaderboard instance) =>
    <String, dynamic>{
      'type': _$LeaderboardTypeEnumMap[instance.type]!,
      'period': instance.period,
      'leaderboard': instance.entries,
    };

const _$LeaderboardTypeEnumMap = {
  LeaderboardType.global: 'global',
  LeaderboardType.weekly: 'weekly',
  LeaderboardType.monthly: 'monthly',
};

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      rang: (json['rang'] as num).toInt(),
      user: User.fromJson(json['utilisateur'] as Map<String, dynamic>),
      stats: LeaderboardStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'rang': instance.rang,
      'utilisateur': instance.user,
      'stats': instance.stats,
    };

LeaderboardStats _$LeaderboardStatsFromJson(Map<String, dynamic> json) =>
    LeaderboardStats(
      totalStars: (json['totalEtoiles'] as num?)?.toInt(),
      challengesParticipated: (json['challengesParticipes'] as num?)?.toInt(),
      challengesWon: (json['challengesGagnes'] as num?)?.toInt(),
      successRate: (json['tauxReussite'] as num?)?.toDouble(),
      weeklyStars: (json['etoilesSemaine'] as num?)?.toInt(),
      weeklyChallenges: (json['challengesSemaine'] as num?)?.toInt(),
      weeklyWins: (json['victoiresSemaine'] as num?)?.toInt(),
      monthlyStars: (json['etoilesMois'] as num?)?.toInt(),
      monthlyChallenges: (json['challengesMois'] as num?)?.toInt(),
      monthlyWins: (json['victoiresMois'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LeaderboardStatsToJson(LeaderboardStats instance) =>
    <String, dynamic>{
      'totalEtoiles': instance.totalStars,
      'challengesParticipes': instance.challengesParticipated,
      'challengesGagnes': instance.challengesWon,
      'tauxReussite': instance.successRate,
      'etoilesSemaine': instance.weeklyStars,
      'challengesSemaine': instance.weeklyChallenges,
      'victoiresSemaine': instance.weeklyWins,
      'etoilesMois': instance.monthlyStars,
      'challengesMois': instance.monthlyChallenges,
      'victoiresMois': instance.monthlyWins,
    };
