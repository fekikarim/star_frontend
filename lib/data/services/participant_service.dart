import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/participant.dart';
import 'package:star_frontend/data/services/api_service.dart';

/// Service for managing participants
class ParticipantService {
  static final ParticipantService _instance = ParticipantService._internal();
  factory ParticipantService() => _instance;
  ParticipantService._internal();

  final ApiService _apiService = ApiService();

  /// Get all participants
  Future<List<Participant>> getAllParticipants() async {
    try {
      AppLogger.info('Fetching all participants');

      final response = await _apiService.get<List<dynamic>>(
        AppConstants.participantsEndpoint,
      );

      final participants = response
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${participants.length} participants');
      return participants;
    } catch (e) {
      AppLogger.error('Failed to fetch participants', e);
      rethrow;
    }
  }

  /// Get participant by ID
  Future<Participant> getParticipantById(String id) async {
    try {
      AppLogger.info('Fetching participant: $id');

      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.participantsEndpoint}/$id',
      );

      final participant = Participant.fromJson(response);

      AppLogger.info('Fetched participant: $id');
      return participant;
    } catch (e) {
      AppLogger.error('Failed to fetch participant: $id', e);
      rethrow;
    }
  }

  /// Create new participant
  Future<Participant> createParticipant(
    CreateParticipantRequest request,
  ) async {
    try {
      AppLogger.info(
        'Creating participant for challenge: ${request.challengeId}',
      );

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.participantsEndpoint,
        data: request.toJson(),
      );

      final participant = Participant.fromJson(response);

      AppLogger.info('Created participant: ${participant.id}');
      return participant;
    } catch (e) {
      AppLogger.error('Failed to create participant', e);
      rethrow;
    }
  }

  /// Update participant
  Future<Participant> updateParticipant(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      AppLogger.info('Updating participant: $id');

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.participantsEndpoint}/$id',
        data: updates,
      );

      final participant = Participant.fromJson(response);

      AppLogger.info('Updated participant: $id');
      return participant;
    } catch (e) {
      AppLogger.error('Failed to update participant: $id', e);
      rethrow;
    }
  }

  /// Delete participant
  Future<void> deleteParticipant(String id) async {
    try {
      AppLogger.info('Deleting participant: $id');

      await _apiService.delete('${AppConstants.participantsEndpoint}/$id');

      AppLogger.info('Deleted participant: $id');
    } catch (e) {
      AppLogger.error('Failed to delete participant: $id', e);
      rethrow;
    }
  }

  /// Get participants by challenge
  Future<List<Participant>> getParticipantsByChallenge(
    String challengeId,
  ) async {
    try {
      AppLogger.info('Fetching participants for challenge: $challengeId');

      final allParticipants = await getAllParticipants();
      final challengeParticipants = allParticipants
          .where((p) => p.challengeId == challengeId)
          .toList();

      AppLogger.info(
        'Found ${challengeParticipants.length} participants for challenge: $challengeId',
      );
      return challengeParticipants;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch participants for challenge: $challengeId',
        e,
      );
      rethrow;
    }
  }

  /// Get participants by user
  Future<List<Participant>> getParticipantsByUser(String userId) async {
    try {
      AppLogger.info('Fetching participations for user: $userId');

      final response = await _apiService.get<List<dynamic>>(
        '${AppConstants.participantsEndpoint}/user/$userId',
      );

      final userParticipants = response
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        'Found ${userParticipants.length} participations for user: $userId',
      );
      return userParticipants;
    } catch (e) {
      AppLogger.error('Failed to fetch participations for user: $userId', e);
      rethrow;
    }
  }

  /// Join challenge (create participation)
  Future<Participant> joinChallenge(String userId, String challengeId) async {
    try {
      AppLogger.info('User $userId joining challenge: $challengeId');

      final request = CreateParticipantRequest(
        id: '${userId}_$challengeId', // Simple ID generation
        utilisateurId: userId,
        challengeId: challengeId,
        scoreTotal: 0.0,
        isValidated: 'en_attente', // Set to pending by default
      );

      final participant = await createParticipant(request);

      AppLogger.info(
        'User $userId successfully joined challenge: $challengeId (status: pending)',
      );
      return participant;
    } catch (e) {
      AppLogger.error(
        'Failed to join challenge: $challengeId for user: $userId',
        e,
      );
      rethrow;
    }
  }

  /// Leave challenge (delete participation)
  Future<void> leaveChallenge(String userId, String challengeId) async {
    try {
      AppLogger.info('User $userId leaving challenge: $challengeId');

      // Find the participation
      final userParticipants = await getParticipantsByUser(userId);
      final participation = userParticipants
          .where((p) => p.challengeId == challengeId)
          .firstOrNull;

      if (participation == null) {
        throw Exception('Participation not found');
      }

      await deleteParticipant(participation.id);

      AppLogger.info('User $userId successfully left challenge: $challengeId');
    } catch (e) {
      AppLogger.error(
        'Failed to leave challenge: $challengeId for user: $userId',
        e,
      );
      rethrow;
    }
  }

  /// Get user participations with validation status
  Future<List<Participant>> getUserParticipationsWithStatus(
    String userId,
  ) async {
    try {
      AppLogger.info(
        'Fetching user participations with status for user: $userId',
      );

      final participants = await getParticipantsByUser(userId);

      AppLogger.info(
        'Found ${participants.length} participations for user: $userId',
      );
      return participants;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch user participations for user: $userId',
        e,
      );
      rethrow;
    }
  }

  /// Get user participations by validation status
  Future<List<Participant>> getUserParticipationsByStatus(
    String userId,
    String status,
  ) async {
    try {
      AppLogger.info(
        'Fetching user participations with status $status for user: $userId',
      );

      final response = await _apiService.get<List<dynamic>>(
        '${AppConstants.participantsEndpoint}/user/$userId/status/$status',
      );

      final filteredParticipants = response
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        'Found ${filteredParticipants.length} participations with status $status for user: $userId',
      );
      return filteredParticipants;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch user participations by status for user: $userId',
        e,
      );
      rethrow;
    }
  }

  /// Get validated participations for user
  Future<List<Participant>> getValidatedParticipations(String userId) async {
    return getUserParticipationsByStatus(userId, 'validated');
  }

  /// Get pending participations for user
  Future<List<Participant>> getPendingParticipations(String userId) async {
    return getUserParticipationsByStatus(userId, 'en_attente');
  }

  /// Get rejected participations for user
  Future<List<Participant>> getRejectedParticipations(String userId) async {
    return getUserParticipationsByStatus(userId, 'rejected');
  }

  /// Update participant score
  Future<Participant> updateParticipantScore(
    String participantId,
    double newScore,
  ) async {
    try {
      AppLogger.info(
        'Updating score for participant: $participantId to $newScore',
      );

      final participant = await updateParticipant(participantId, {
        'scoreTotal': newScore,
      });

      AppLogger.info('Updated score for participant: $participantId');
      return participant;
    } catch (e) {
      AppLogger.error(
        'Failed to update score for participant: $participantId',
        e,
      );
      rethrow;
    }
  }

  /// Check if user is participating in challenge
  Future<bool> isUserParticipating(String userId, String challengeId) async {
    try {
      final userParticipants = await getParticipantsByUser(userId);
      final isParticipating = userParticipants.any(
        (p) => p.challengeId == challengeId,
      );

      AppLogger.info(
        'User $userId participation in challenge $challengeId: $isParticipating',
      );
      return isParticipating;
    } catch (e) {
      AppLogger.error(
        'Failed to check participation for user: $userId in challenge: $challengeId',
        e,
      );
      return false;
    }
  }

  /// Get user participation in challenge
  Future<Participant?> getUserParticipation(
    String userId,
    String challengeId,
  ) async {
    try {
      final userParticipants = await getParticipantsByUser(userId);
      final participation = userParticipants
          .where((p) => p.challengeId == challengeId)
          .firstOrNull;

      AppLogger.info(
        'Found participation for user $userId in challenge $challengeId: ${participation != null}',
      );
      return participation;
    } catch (e) {
      AppLogger.error(
        'Failed to get participation for user: $userId in challenge: $challengeId',
        e,
      );
      return null;
    }
  }

  /// Get participant ranking in challenge
  Future<ParticipantRanking?> getParticipantRanking(
    String participantId,
  ) async {
    try {
      AppLogger.info('Getting ranking for participant: $participantId');

      final participant = await getParticipantById(participantId);
      final challengeParticipants = await getParticipantsByChallenge(
        participant.challengeId,
      );

      // Sort by score descending
      challengeParticipants.sort(
        (a, b) => b.scoreTotal.compareTo(a.scoreTotal),
      );

      // Find rank
      final rank =
          challengeParticipants.indexWhere((p) => p.id == participantId) + 1;

      if (rank == 0) {
        AppLogger.warning('Participant not found in ranking: $participantId');
        return null;
      }

      final ranking = ParticipantRanking(
        participant: participant,
        rank: rank,
        score: participant.scoreTotal,
      );

      AppLogger.info('Participant $participantId rank: $rank');
      return ranking;
    } catch (e) {
      AppLogger.error(
        'Failed to get ranking for participant: $participantId',
        e,
      );
      return null;
    }
  }

  /// Get top participants across all challenges
  Future<List<Participant>> getTopParticipants({int limit = 10}) async {
    try {
      AppLogger.info('Fetching top $limit participants');

      final allParticipants = await getAllParticipants();

      // Sort by score descending and take top N
      allParticipants.sort((a, b) => b.scoreTotal.compareTo(a.scoreTotal));
      final topParticipants = allParticipants.take(limit).toList();

      AppLogger.info('Found ${topParticipants.length} top participants');
      return topParticipants;
    } catch (e) {
      AppLogger.error('Failed to fetch top participants', e);
      rethrow;
    }
  }

  /// Get participant statistics
  Future<Map<String, dynamic>> getParticipantStatistics(
    String participantId,
  ) async {
    try {
      AppLogger.info('Calculating statistics for participant: $participantId');

      final participant = await getParticipantById(participantId);
      final ranking = await getParticipantRanking(participantId);
      final challengeParticipants = await getParticipantsByChallenge(
        participant.challengeId,
      );

      final stats = {
        'participant': participant.toJson(),
        'currentRank': ranking?.rank ?? 0,
        'totalParticipants': challengeParticipants.length,
        'scorePercentile': ranking != null
            ? ((challengeParticipants.length - ranking.rank + 1) /
                      challengeParticipants.length *
                      100)
                  .round()
            : 0,
        'isTopTen': ranking != null && ranking.rank <= 10,
        'isTopThree': ranking != null && ranking.rank <= 3,
        'isWinner': ranking != null && ranking.rank == 1,
      };

      AppLogger.info('Calculated statistics for participant: $participantId');
      return stats;
    } catch (e) {
      AppLogger.error(
        'Failed to calculate statistics for participant: $participantId',
        e,
      );
      rethrow;
    }
  }
}
