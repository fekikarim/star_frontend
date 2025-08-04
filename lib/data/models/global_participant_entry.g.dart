// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_participant_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalParticipantEntry _$GlobalParticipantEntryFromJson(
  Map<String, dynamic> json,
) => GlobalParticipantEntry(
  rang: (json['rang'] as num).toInt(),
  participant: Participant.fromJson(
    json['participant'] as Map<String, dynamic>,
  ),
  utilisateur: User.fromJson(json['utilisateur'] as Map<String, dynamic>),
  challenge: Challenge.fromJson(json['challenge'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GlobalParticipantEntryToJson(
  GlobalParticipantEntry instance,
) => <String, dynamic>{
  'rang': instance.rang,
  'participant': instance.participant,
  'utilisateur': instance.utilisateur,
  'challenge': instance.challenge,
};

GlobalParticipantsLeaderboard _$GlobalParticipantsLeaderboardFromJson(
  Map<String, dynamic> json,
) => GlobalParticipantsLeaderboard(
  type: json['type'] as String,
  period: json['period'] as String,
  entries: (json['leaderboard'] as List<dynamic>)
      .map((e) => GlobalParticipantEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  challengeFilter: json['challengeFilter'] as String?,
);

Map<String, dynamic> _$GlobalParticipantsLeaderboardToJson(
  GlobalParticipantsLeaderboard instance,
) => <String, dynamic>{
  'type': instance.type,
  'period': instance.period,
  'leaderboard': instance.entries,
  'total': instance.total,
  'challengeFilter': instance.challengeFilter,
};
