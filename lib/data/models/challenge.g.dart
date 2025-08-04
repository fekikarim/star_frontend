// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
  id: json['id'] as String,
  nom: json['nom'] as String,
  dateDebut: DateTime.parse(json['dateDebut'] as String),
  dateFin: DateTime.parse(json['dateFin'] as String),
  statut: json['statut'] as String,
  createurId: json['createurId'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'dateDebut': instance.dateDebut.toIso8601String(),
  'dateFin': instance.dateFin.toIso8601String(),
  'statut': instance.statut,
  'createurId': instance.createurId,
  'createdAt': instance.createdAt?.toIso8601String(),
};

CreateChallengeRequest _$CreateChallengeRequestFromJson(
  Map<String, dynamic> json,
) => CreateChallengeRequest(
  id: json['id'] as String,
  nom: json['nom'] as String,
  dateDebut: DateTime.parse(json['dateDebut'] as String),
  dateFin: DateTime.parse(json['dateFin'] as String),
  statut: json['statut'] as String,
  createurId: json['createurId'] as String,
);

Map<String, dynamic> _$CreateChallengeRequestToJson(
  CreateChallengeRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'dateDebut': instance.dateDebut.toIso8601String(),
  'dateFin': instance.dateFin.toIso8601String(),
  'statut': instance.statut,
  'createurId': instance.createurId,
};
