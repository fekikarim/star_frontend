import 'package:json_annotation/json_annotation.dart';
import 'package:star_frontend/core/utils/date_utils.dart';

part 'challenge.g.dart';

/// Challenge model representing a competition or task
@JsonSerializable()
class Challenge {
  final String id;
  final String nom;
  @JsonKey(name: 'dateDebut')
  final DateTime dateDebut;
  @JsonKey(name: 'dateFin')
  final DateTime dateFin;
  final String statut;
  @JsonKey(name: 'createurId')
  final String createurId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? description;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? imageUrl;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int participantCount;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isParticipating;
  
  const Challenge({
    required this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.createurId,
    this.createdAt,
    this.description,
    this.imageUrl,
    this.participantCount = 0,
    this.isParticipating = false,
  });
  
  /// Create Challenge from JSON
  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
  
  /// Convert Challenge to JSON
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
  
  /// Create a copy with updated fields
  Challenge copyWith({
    String? id,
    String? nom,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statut,
    String? createurId,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
    int? participantCount,
    bool? isParticipating,
  }) {
    return Challenge(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      createurId: createurId ?? this.createurId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participantCount: participantCount ?? this.participantCount,
      isParticipating: isParticipating ?? this.isParticipating,
    );
  }
  
  /// Check if challenge is active
  bool get isActive => statut.toLowerCase() == 'en cours' || statut.toLowerCase() == 'actif';
  
  /// Check if challenge is completed
  bool get isCompleted => statut.toLowerCase() == 'terminé' || statut.toLowerCase() == 'completed';
  
  /// Check if challenge is pending
  bool get isPending => statut.toLowerCase() == 'en attente' || statut.toLowerCase() == 'pending';
  
  /// Check if challenge is cancelled
  bool get isCancelled => statut.toLowerCase() == 'annulé' || statut.toLowerCase() == 'cancelled';
  
  /// Check if challenge has started
  bool get hasStarted => DateTime.now().isAfter(dateDebut);
  
  /// Check if challenge has ended
  bool get hasEnded => DateTime.now().isAfter(dateFin);
  
  /// Check if challenge is currently running
  bool get isRunning => hasStarted && !hasEnded && isActive;
  
  /// Check if challenge is upcoming
  bool get isUpcoming => !hasStarted && isActive;
  
  /// Get challenge duration
  Duration get duration => dateFin.difference(dateDebut);
  
  /// Get remaining time
  Duration? get remainingTime {
    if (hasEnded) return null;
    return dateFin.difference(DateTime.now());
  }
  
  /// Get time until start
  Duration? get timeUntilStart {
    if (hasStarted) return null;
    return dateDebut.difference(DateTime.now());
  }
  
  /// Get formatted duration
  String get formattedDuration => AppDateUtils.formatDuration(duration);
  
  /// Get formatted remaining time
  String? get formattedRemainingTime {
    final remaining = remainingTime;
    if (remaining == null) return null;
    return AppDateUtils.formatDuration(remaining);
  }
  
  /// Get challenge status color
  ChallengeStatusColor get statusColor {
    if (isActive && isRunning) return ChallengeStatusColor.active;
    if (isCompleted) return ChallengeStatusColor.completed;
    if (isPending || isUpcoming) return ChallengeStatusColor.pending;
    if (isCancelled) return ChallengeStatusColor.cancelled;
    return ChallengeStatusColor.inactive;
  }
  
  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    if (!hasStarted) return 0.0;
    if (hasEnded) return 1.0;
    
    final totalDuration = duration.inMilliseconds;
    final elapsed = DateTime.now().difference(dateDebut).inMilliseconds;
    
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Challenge &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Challenge{id: $id, nom: $nom, statut: $statut, dateDebut: $dateDebut, dateFin: $dateFin}';
  }
}

/// Challenge status colors enum
enum ChallengeStatusColor {
  active,
  pending,
  completed,
  cancelled,
  inactive,
}

/// Create challenge request model
@JsonSerializable()
class CreateChallengeRequest {
  final String id;
  final String nom;
  @JsonKey(name: 'dateDebut')
  final DateTime dateDebut;
  @JsonKey(name: 'dateFin')
  final DateTime dateFin;
  final String statut;
  @JsonKey(name: 'createurId')
  final String createurId;
  
  const CreateChallengeRequest({
    required this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.createurId,
  });
  
  factory CreateChallengeRequest.fromJson(Map<String, dynamic> json) => _$CreateChallengeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChallengeRequestToJson(this);
}
