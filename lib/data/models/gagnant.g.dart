part of 'gagnant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gagnant _$GagnantFromJson(Map<String, dynamic> json) => Gagnant(
  id: json['id'] as String,
  utilisateurId: json['utilisateurId'] as String,
  challengeId: json['challengeId'] as String,
  classement: (json['classement'] as num).toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GagnantToJson(Gagnant instance) => <String, dynamic>{
  'id': instance.id,
  'utilisateurId': instance.utilisateurId,
  'challengeId': instance.challengeId,
  'classement': instance.classement,
  'created_at': instance.createdAt?.toIso8601String(),
};

CreateGagnantRequest _$CreateGagnantRequestFromJson(
  Map<String, dynamic> json,
) => CreateGagnantRequest(
  id: json['id'] as String,
  utilisateurId: json['utilisateurId'] as String,
  challengeId: json['challengeId'] as String,
  classement: (json['classement'] as num).toInt(),
);

Map<String, dynamic> _$CreateGagnantRequestToJson(
  CreateGagnantRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'utilisateurId': instance.utilisateurId,
  'challengeId': instance.challengeId,
  'classement': instance.classement,
};

ChallengeWinnersSummary _$ChallengeWinnersSummaryFromJson(
  Map<String, dynamic> json,
) => ChallengeWinnersSummary(
  challengeId: json['challengeId'] as String,
  winners: (json['winners'] as List<dynamic>)
      .map((e) => Gagnant.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalParticipants: (json['totalParticipants'] as num).toInt(),
  determinedAt: json['determinedAt'] == null
      ? null
      : DateTime.parse(json['determinedAt'] as String),
);

Map<String, dynamic> _$ChallengeWinnersSummaryToJson(
  ChallengeWinnersSummary instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'winners': instance.winners,
  'totalParticipants': instance.totalParticipants,
  'determinedAt': instance.determinedAt?.toIso8601String(),
};
