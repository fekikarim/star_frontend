// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
  description: json['description'] as String,
  dateAwarded: DateTime.parse(json['dateAttribution'] as String),
  icon: json['icon'] as String?,
  levelName: json['palierNom'] as String?,
  minStars: (json['etoilesMin'] as num?)?.toInt(),
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'description': instance.description,
      'dateAttribution': instance.dateAwarded.toIso8601String(),
      'icon': instance.icon,
      'palierNom': instance.levelName,
      'etoilesMin': instance.minStars,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.badge: 'badge',
  AchievementType.bonAchat: 'bonAchat',
  AchievementType.certificat: 'certificat',
  AchievementType.trophee: 'trophee',
};
