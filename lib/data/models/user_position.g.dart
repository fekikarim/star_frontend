// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPosition _$UserPositionFromJson(Map<String, dynamic> json) => UserPosition(
  userId: json['userId'] as String,
  type: json['type'] as String,
  position: (json['position'] as num).toInt(),
  score: (json['score'] as num).toInt(),
);

Map<String, dynamic> _$UserPositionToJson(UserPosition instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'type': instance.type,
      'position': instance.position,
      'score': instance.score,
    };
