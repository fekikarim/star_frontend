import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/data/models/participant.dart';
import 'package:star_frontend/data/models/user.dart';
import 'package:star_frontend/data/models/challenge.dart';

part 'global_participant_entry.g.dart';

/// Global participant entry model for global leaderboard
@JsonSerializable()
class GlobalParticipantEntry {
  final int rang;
  final Participant participant;
  final User utilisateur;
  final Challenge challenge;
  
  const GlobalParticipantEntry({
    required this.rang,
    required this.participant,
    required this.utilisateur,
    required this.challenge,
  });
  
  factory GlobalParticipantEntry.fromJson(Map<String, dynamic> json) => _$GlobalParticipantEntryFromJson(json);
  Map<String, dynamic> toJson() => _$GlobalParticipantEntryToJson(this);
  
  /// Get rank display with medal for top 3
  String get rankDisplay {
    switch (rang) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rang';
    }
  }
  
  /// Get rank color
  String get rankColor {
    switch (rang) {
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
  
  /// Get score display
  String get scoreDisplay {
    return participant.scoreTotal.toStringAsFixed(1);
  }
  
  /// Get challenge status display
  String get challengeStatusDisplay {
    switch (challenge.statut.toLowerCase()) {
      case 'en_cours':
        return 'En cours';
      case 'termine':
      case 'terminé':
        return 'Terminé';
      case 'en_attente':
        return 'En attente';
      default:
        return challenge.statut;
    }
  }
  
  /// Check if challenge is active
  bool get isChallengeActive => challenge.isActive;
  
  /// Check if challenge is completed
  bool get isChallengeCompleted => challenge.isCompleted;
}

/// Global participants leaderboard model
@JsonSerializable()
class GlobalParticipantsLeaderboard {
  final String type;
  final String period;
  @JsonKey(name: 'leaderboard')
  final List<GlobalParticipantEntry> entries;
  final int total;
  @JsonKey(name: 'challengeFilter')
  final String? challengeFilter;
  
  const GlobalParticipantsLeaderboard({
    required this.type,
    required this.period,
    required this.entries,
    required this.total,
    this.challengeFilter,
  });
  
  factory GlobalParticipantsLeaderboard.fromJson(Map<String, dynamic> json) => _$GlobalParticipantsLeaderboardFromJson(json);
  Map<String, dynamic> toJson() => _$GlobalParticipantsLeaderboardToJson(this);
  
  /// Check if this is a filtered leaderboard
  bool get isFiltered => challengeFilter != null;
  
  /// Get unique challenges from entries
  List<Challenge> get uniqueChallenges {
    final challengeMap = <String, Challenge>{};
    for (final entry in entries) {
      challengeMap[entry.challenge.id] = entry.challenge;
    }
    return challengeMap.values.toList();
  }
  
  /// Get entries for a specific challenge
  List<GlobalParticipantEntry> getEntriesForChallenge(String challengeId) {
    return entries.where((entry) => entry.challenge.id == challengeId).toList();
  }
  
  /// Get top performers (top 3)
  List<GlobalParticipantEntry> get topPerformers {
    return entries.take(3).toList();
  }
}
