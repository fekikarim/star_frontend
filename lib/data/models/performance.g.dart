// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Performance _$PerformanceFromJson(Map<String, dynamic> json) => Performance(
  id: json['id'] as String,
  participantId: json['participantId'] as String,
  valeur: (json['valeur'] as num).toDouble(),
  rang: (json['rang'] as num).toInt(),
  details: json['details'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PerformanceToJson(Performance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participantId': instance.participantId,
      'valeur': instance.valeur,
      'rang': instance.rang,
      'details': instance.details,
      'created_at': instance.createdAt?.toIso8601String(),
    };

CreatePerformanceRequest _$CreatePerformanceRequestFromJson(
  Map<String, dynamic> json,
) => CreatePerformanceRequest(
  id: json['id'] as String,
  participantId: json['participantId'] as String,
  valeur: (json['valeur'] as num).toDouble(),
  rang: (json['rang'] as num).toInt(),
  details: json['details'] as String,
);

Map<String, dynamic> _$CreatePerformanceRequestToJson(
  CreatePerformanceRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'participantId': instance.participantId,
  'valeur': instance.valeur,
  'rang': instance.rang,
  'details': instance.details,
};

PerformanceStats _$PerformanceStatsFromJson(Map<String, dynamic> json) =>
    PerformanceStats(
      averageScore: (json['averageScore'] as num).toDouble(),
      bestScore: (json['bestScore'] as num).toDouble(),
      worstScore: (json['worstScore'] as num).toDouble(),
      totalPerformances: (json['totalPerformances'] as num).toInt(),
      improvementCount: (json['improvementCount'] as num).toInt(),
      improvementRate: (json['improvementRate'] as num).toDouble(),
    );

Map<String, dynamic> _$PerformanceStatsToJson(PerformanceStats instance) =>
    <String, dynamic>{
      'averageScore': instance.averageScore,
      'bestScore': instance.bestScore,
      'worstScore': instance.worstScore,
      'totalPerformances': instance.totalPerformances,
      'improvementCount': instance.improvementCount,
      'improvementRate': instance.improvementRate,
    };
