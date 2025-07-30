// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recompense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recompense _$RecompenseFromJson(Map<String, dynamic> json) => Recompense(
  id: json['id'] as String,
  type: json['type'] as String,
  description: json['description'] as String?,
  dateAttribution: json['dateAttribution'] == null
      ? null
      : DateTime.parse(json['dateAttribution'] as String),
  palierId: json['palierId'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$RecompenseToJson(Recompense instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
      'dateAttribution': instance.dateAttribution?.toIso8601String(),
      'palierId': instance.palierId,
      'created_at': instance.createdAt?.toIso8601String(),
    };

CreateRecompenseRequest _$CreateRecompenseRequestFromJson(
  Map<String, dynamic> json,
) => CreateRecompenseRequest(
  id: json['id'] as String,
  type: json['type'] as String,
  description: json['description'] as String,
  dateAttribution: DateTime.parse(json['dateAttribution'] as String),
  palierId: json['palierId'] as String,
);

Map<String, dynamic> _$CreateRecompenseRequestToJson(
  CreateRecompenseRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'description': instance.description,
  'dateAttribution': instance.dateAttribution.toIso8601String(),
  'palierId': instance.palierId,
};

UserRewardsSummary _$UserRewardsSummaryFromJson(Map<String, dynamic> json) =>
    UserRewardsSummary(
      userId: json['userId'] as String,
      totalRewards: (json['totalRewards'] as num).toInt(),
      collectedRewards: (json['collectedRewards'] as num).toInt(),
      availableRewards: (json['availableRewards'] as num).toInt(),
      expiredRewards: (json['expiredRewards'] as num).toInt(),
      recentRewards:
          (json['recentRewards'] as List<dynamic>?)
              ?.map((e) => Recompense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserRewardsSummaryToJson(UserRewardsSummary instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalRewards': instance.totalRewards,
      'collectedRewards': instance.collectedRewards,
      'availableRewards': instance.availableRewards,
      'expiredRewards': instance.expiredRewards,
      'recentRewards': instance.recentRewards,
    };
