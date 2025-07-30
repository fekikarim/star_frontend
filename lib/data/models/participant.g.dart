// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
  id: json['id'] as String,
  utilisateurId: json['utilisateurId'] as String,
  challengeId: json['challengeId'] as String,
  scoreTotal: (json['scoreTotal'] as num).toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'utilisateurId': instance.utilisateurId,
      'challengeId': instance.challengeId,
      'scoreTotal': instance.scoreTotal,
      'created_at': instance.createdAt?.toIso8601String(),
    };

CreateParticipantRequest _$CreateParticipantRequestFromJson(
  Map<String, dynamic> json,
) => CreateParticipantRequest(
  id: json['id'] as String,
  utilisateurId: json['utilisateurId'] as String,
  challengeId: json['challengeId'] as String,
  scoreTotal: (json['scoreTotal'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CreateParticipantRequestToJson(
  CreateParticipantRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'utilisateurId': instance.utilisateurId,
  'challengeId': instance.challengeId,
  'scoreTotal': instance.scoreTotal,
};

ParticipantRanking _$ParticipantRankingFromJson(Map<String, dynamic> json) =>
    ParticipantRanking(
      participant: Participant.fromJson(
        json['participant'] as Map<String, dynamic>,
      ),
      rank: (json['rank'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      previousScore: (json['previousScore'] as num?)?.toDouble(),
      previousRank: (json['previousRank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ParticipantRankingToJson(ParticipantRanking instance) =>
    <String, dynamic>{
      'participant': instance.participant,
      'rank': instance.rank,
      'score': instance.score,
      'previousScore': instance.previousScore,
      'previousRank': instance.previousRank,
    };
