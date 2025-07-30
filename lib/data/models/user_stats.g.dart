// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  stats: UserStatsData.fromJson(json['stats'] as Map<String, dynamic>),
  level: UserLevel.fromJson(json['level'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'user': instance.user,
  'stats': instance.stats,
  'level': instance.level,
};

UserStatsData _$UserStatsDataFromJson(Map<String, dynamic> json) =>
    UserStatsData(
      totalStars: (json['totalEtoiles'] as num).toInt(),
      challengesParticipated: (json['challengesParticipes'] as num).toInt(),
      challengesWon: (json['challengesGagnes'] as num).toInt(),
      activeChallenges: (json['challengesActifs'] as num).toInt(),
      weeklyStars: (json['etoilesSemaine'] as num).toInt(),
      successRate: (json['tauxReussite'] as num).toInt(),
    );

Map<String, dynamic> _$UserStatsDataToJson(UserStatsData instance) =>
    <String, dynamic>{
      'totalEtoiles': instance.totalStars,
      'challengesParticipes': instance.challengesParticipated,
      'challengesGagnes': instance.challengesWon,
      'challengesActifs': instance.activeChallenges,
      'etoilesSemaine': instance.weeklyStars,
      'tauxReussite': instance.successRate,
    };

UserLevel _$UserLevelFromJson(Map<String, dynamic> json) => UserLevel(
  current: Level.fromJson(json['current'] as Map<String, dynamic>),
  next: json['next'] == null
      ? null
      : Level.fromJson(json['next'] as Map<String, dynamic>),
  progress: (json['progress'] as num).toInt(),
  starsToNext: (json['starsToNext'] as num).toInt(),
);

Map<String, dynamic> _$UserLevelToJson(UserLevel instance) => <String, dynamic>{
  'current': instance.current,
  'next': instance.next,
  'progress': instance.progress,
  'starsToNext': instance.starsToNext,
};

Level _$LevelFromJson(Map<String, dynamic> json) => Level(
  id: json['id'] as String?,
  nom: json['nom'] as String,
  minStars: (json['etoilesMin'] as num).toInt(),
  description: json['description'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$LevelToJson(Level instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'etoilesMin': instance.minStars,
  'description': instance.description,
  'created_at': instance.createdAt?.toIso8601String(),
};
