// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String,
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  value: (json['value'] as num).toDouble(),
  description: json['description'] as String,
  challengeName: json['challengeNom'] as String?,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ActivityTypeEnumMap[instance.type]!,
  'value': instance.value,
  'description': instance.description,
  'challengeNom': instance.challengeName,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ActivityTypeEnumMap = {
  ActivityType.etoile: 'etoile',
  ActivityType.participation: 'participation',
  ActivityType.victoire: 'victoire',
};
