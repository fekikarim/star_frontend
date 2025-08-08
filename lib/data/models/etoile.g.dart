part of 'etoile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Etoile _$EtoileFromJson(Map<String, dynamic> json) => Etoile(
  id: json['id'] as String,
  total: (json['total'] as num).toInt(),
  dateAttribution: DateTime.parse(json['dateAttribution'] as String),
  raison: json['raison'] as String?,
  utilisateurId: json['utilisateurId'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EtoileToJson(Etoile instance) => <String, dynamic>{
  'id': instance.id,
  'total': instance.total,
  'dateAttribution': instance.dateAttribution.toIso8601String(),
  'raison': instance.raison,
  'utilisateurId': instance.utilisateurId,
  'created_at': instance.createdAt?.toIso8601String(),
};

CreateEtoileRequest _$CreateEtoileRequestFromJson(Map<String, dynamic> json) =>
    CreateEtoileRequest(
      id: json['id'] as String,
      total: (json['total'] as num).toInt(),
      dateAttribution: DateTime.parse(json['dateAttribution'] as String),
      raison: json['raison'] as String,
      utilisateurId: json['utilisateurId'] as String,
    );

Map<String, dynamic> _$CreateEtoileRequestToJson(
  CreateEtoileRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'total': instance.total,
  'dateAttribution': instance.dateAttribution.toIso8601String(),
  'raison': instance.raison,
  'utilisateurId': instance.utilisateurId,
};

UserStarSummary _$UserStarSummaryFromJson(Map<String, dynamic> json) =>
    UserStarSummary(
      utilisateurId: json['utilisateurId'] as String,
      totalStars: (json['totalStars'] as num).toInt(),
      starCount: (json['starCount'] as num).toInt(),
      lastStarDate: json['lastStarDate'] == null
          ? null
          : DateTime.parse(json['lastStarDate'] as String),
      recentStars:
          (json['recentStars'] as List<dynamic>?)
              ?.map((e) => Etoile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserStarSummaryToJson(UserStarSummary instance) =>
    <String, dynamic>{
      'utilisateurId': instance.utilisateurId,
      'totalStars': instance.totalStars,
      'starCount': instance.starCount,
      'lastStarDate': instance.lastStarDate?.toIso8601String(),
      'recentStars': instance.recentStars,
    };
