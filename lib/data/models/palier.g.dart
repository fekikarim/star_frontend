// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Palier _$PalierFromJson(Map<String, dynamic> json) => Palier(
  id: json['id'] as String,
  nom: json['nom'] as String,
  etoilesMin: (json['etoilesMin'] as num).toInt(),
  description: json['description'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PalierToJson(Palier instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'etoilesMin': instance.etoilesMin,
  'description': instance.description,
  'created_at': instance.createdAt?.toIso8601String(),
};

CreatePalierRequest _$CreatePalierRequestFromJson(Map<String, dynamic> json) =>
    CreatePalierRequest(
      id: json['id'] as String,
      nom: json['nom'] as String,
      etoilesMin: (json['etoilesMin'] as num).toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreatePalierRequestToJson(
  CreatePalierRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'etoilesMin': instance.etoilesMin,
  'description': instance.description,
};

UserLevelProgress _$UserLevelProgressFromJson(Map<String, dynamic> json) =>
    UserLevelProgress(
      userId: json['userId'] as String,
      totalStars: (json['totalStars'] as num).toInt(),
      currentLevel: Palier.fromJson(
        json['currentLevel'] as Map<String, dynamic>,
      ),
      nextLevel: json['nextLevel'] == null
          ? null
          : Palier.fromJson(json['nextLevel'] as Map<String, dynamic>),
      progressToNext: (json['progressToNext'] as num).toDouble(),
      starsToNext: (json['starsToNext'] as num).toInt(),
      unlockedLevels:
          (json['unlockedLevels'] as List<dynamic>?)
              ?.map((e) => Palier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserLevelProgressToJson(UserLevelProgress instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalStars': instance.totalStars,
      'currentLevel': instance.currentLevel,
      'nextLevel': instance.nextLevel,
      'progressToNext': instance.progressToNext,
      'starsToNext': instance.starsToNext,
      'unlockedLevels': instance.unlockedLevels,
    };
