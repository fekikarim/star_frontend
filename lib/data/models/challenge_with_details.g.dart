// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_with_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeWithDetails _$ChallengeWithDetailsFromJson(
  Map<String, dynamic> json,
) => ChallengeWithDetails(
  id: json['id'] as String,
  nom: json['nom'] as String,
  dateDebut: DateTime.parse(json['dateDebut'] as String),
  dateFin: DateTime.parse(json['dateFin'] as String),
  statut: json['statut'] as String,
  createurId: json['createurId'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  participantsCount: (json['participantsCount'] as num).toInt(),
  winnersCount: (json['winnersCount'] as num).toInt(),
  isParticipating: json['isParticipating'] as bool,
  daysRemaining: (json['daysRemaining'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChallengeWithDetailsToJson(
  ChallengeWithDetails instance,
) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'dateDebut': instance.dateDebut.toIso8601String(),
  'dateFin': instance.dateFin.toIso8601String(),
  'statut': instance.statut,
  'createurId': instance.createurId,
  'created_at': instance.createdAt?.toIso8601String(),
  'participantsCount': instance.participantsCount,
  'winnersCount': instance.winnersCount,
  'isParticipating': instance.isParticipating,
  'daysRemaining': instance.daysRemaining,
};
