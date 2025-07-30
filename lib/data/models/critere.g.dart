// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'critere.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Critere _$CritereFromJson(Map<String, dynamic> json) => Critere(
  id: json['id'] as String,
  nom: json['nom'] as String,
  poids: (json['poids'] as num).toDouble(),
  challengeId: json['challengeId'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CritereToJson(Critere instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'poids': instance.poids,
  'challengeId': instance.challengeId,
  'created_at': instance.createdAt?.toIso8601String(),
};

CreateCritereRequest _$CreateCritereRequestFromJson(
  Map<String, dynamic> json,
) => CreateCritereRequest(
  id: json['id'] as String,
  nom: json['nom'] as String,
  poids: (json['poids'] as num).toDouble(),
  challengeId: json['challengeId'] as String,
);

Map<String, dynamic> _$CreateCritereRequestToJson(
  CreateCritereRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'poids': instance.poids,
  'challengeId': instance.challengeId,
};

CritereEvaluation _$CritereEvaluationFromJson(Map<String, dynamic> json) =>
    CritereEvaluation(
      critereId: json['critereId'] as String,
      participantId: json['participantId'] as String,
      value: (json['value'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      weightedScore: (json['weightedScore'] as num).toDouble(),
      notes: json['notes'] as String?,
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
    );

Map<String, dynamic> _$CritereEvaluationToJson(CritereEvaluation instance) =>
    <String, dynamic>{
      'critereId': instance.critereId,
      'participantId': instance.participantId,
      'value': instance.value,
      'score': instance.score,
      'weightedScore': instance.weightedScore,
      'notes': instance.notes,
      'evaluatedAt': instance.evaluatedAt.toIso8601String(),
    };
