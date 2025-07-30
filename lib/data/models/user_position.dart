import 'package:json_annotation/json_annotation.dart';

part 'user_position.g.dart';

/// User position in leaderboard model
@JsonSerializable()
class UserPosition {
  @JsonKey(name: 'userId')
  final String userId;
  final String type;
  final int position;
  final int score;
  
  const UserPosition({
    required this.userId,
    required this.type,
    required this.position,
    required this.score,
  });
  
  factory UserPosition.fromJson(Map<String, dynamic> json) => _$UserPositionFromJson(json);
  Map<String, dynamic> toJson() => _$UserPositionToJson(this);
  
  /// Get position display with medal for top 3
  String get positionDisplay {
    switch (position) {
      case 1:
        return '🥇 1er';
      case 2:
        return '🥈 2ème';
      case 3:
        return '🥉 3ème';
      default:
        return '#$position';
    }
  }
  
  /// Get position color
  String get positionColor {
    switch (position) {
      case 1:
        return '#FFD700';
      case 2:
        return '#C0C0C0';
      case 3:
        return '#CD7F32';
      default:
        return '#757575';
    }
  }
  
  /// Check if user is in top 3
  bool get isTopThree => position <= 3;
  
  /// Check if user is in top 10
  bool get isTopTen => position <= 10;
}
