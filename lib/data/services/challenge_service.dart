import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/utils/logger.dart';
import 'package:star_frontend/data/models/challenge.dart';
import 'package:star_frontend/data/models/challenge_with_details.dart';
import 'package:star_frontend/data/models/participant.dart';
import 'package:star_frontend/data/models/gagnant.dart';
import 'package:star_frontend/data/models/api_response.dart';
import 'package:star_frontend/data/services/api_service.dart';

/// Service for managing challenges
class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  final ApiService _apiService = ApiService();

  /// Get all challenges
  Future<List<Challenge>> getAllChallenges() async {
    try {
      AppLogger.info('Fetching all challenges');

      final response = await _apiService.get<List<dynamic>>(
        AppConstants.challengesEndpoint,
      );

      final challenges = response
          .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${challenges.length} challenges');
      return challenges;
    } catch (e) {
      AppLogger.error('Failed to fetch challenges', e);
      rethrow;
    }
  }

  /// Get challenge by ID
  Future<Challenge> getChallengeById(String id) async {
    try {
      AppLogger.info('Fetching challenge: $id');

      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.challengesEndpoint}/$id',
      );

      final challenge = Challenge.fromJson(response);

      AppLogger.info('Fetched challenge: ${challenge.nom}');
      return challenge;
    } catch (e) {
      AppLogger.error('Failed to fetch challenge: $id', e);
      rethrow;
    }
  }

  /// Create new challenge
  Future<Challenge> createChallenge(CreateChallengeRequest request) async {
    try {
      AppLogger.info('Creating challenge: ${request.nom}');

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.challengesEndpoint,
        data: request.toJson(),
      );

      final challenge = Challenge.fromJson(response);

      AppLogger.info('Created challenge: ${challenge.nom}');
      return challenge;
    } catch (e) {
      AppLogger.error('Failed to create challenge: ${request.nom}', e);
      rethrow;
    }
  }

  /// Update challenge
  Future<Challenge> updateChallenge(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      AppLogger.info('Updating challenge: $id');

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.challengesEndpoint}/$id',
        data: updates,
      );

      final challenge = Challenge.fromJson(response);

      AppLogger.info('Updated challenge: ${challenge.nom}');
      return challenge;
    } catch (e) {
      AppLogger.error('Failed to update challenge: $id', e);
      rethrow;
    }
  }

  /// Delete challenge
  Future<void> deleteChallenge(String id) async {
    try {
      AppLogger.info('Deleting challenge: $id');

      await _apiService.delete('${AppConstants.challengesEndpoint}/$id');

      AppLogger.info('Deleted challenge: $id');
    } catch (e) {
      AppLogger.error('Failed to delete challenge: $id', e);
      rethrow;
    }
  }

  /// Get challenge leaderboard/ranking
  Future<List<Participant>> getChallengeLeaderboard(String challengeId) async {
    try {
      AppLogger.info('Fetching leaderboard for challenge: $challengeId');

      final response = await _apiService.get<List<dynamic>>(
        '${AppConstants.challengesEndpoint}/$challengeId/classement',
      );

      final participants = response
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        'Fetched leaderboard with ${participants.length} participants',
      );
      return participants;
    } catch (e) {
      AppLogger.error(
        'Failed to fetch leaderboard for challenge: $challengeId',
        e,
      );
      rethrow;
    }
  }

  /// Get challenge winners
  Future<List<Gagnant>> getChallengeWinners(String challengeId) async {
    try {
      AppLogger.info('Fetching winners for challenge: $challengeId');

      final response = await _apiService.get<List<dynamic>>(
        '${AppConstants.challengesEndpoint}/$challengeId/gagnants',
      );

      final winners = response
          .map((json) => Gagnant.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        'Fetched ${winners.length} winners for challenge: $challengeId',
      );
      return winners;
    } catch (e) {
      AppLogger.error('Failed to fetch winners for challenge: $challengeId', e);
      rethrow;
    }
  }

  /// Get active challenges
  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final allChallenges = await getAllChallenges();
      final activeChallenges = allChallenges
          .where((challenge) => challenge.isActive)
          .toList();

      AppLogger.info('Found ${activeChallenges.length} active challenges');
      return activeChallenges;
    } catch (e) {
      AppLogger.error('Failed to fetch active challenges', e);
      rethrow;
    }
  }

  /// Get completed challenges
  Future<List<Challenge>> getCompletedChallenges() async {
    try {
      final allChallenges = await getAllChallenges();
      final completedChallenges = allChallenges
          .where((challenge) => challenge.isCompleted)
          .toList();

      AppLogger.info(
        'Found ${completedChallenges.length} completed challenges',
      );
      return completedChallenges;
    } catch (e) {
      AppLogger.error('Failed to fetch completed challenges', e);
      rethrow;
    }
  }

  /// Get upcoming challenges
  Future<List<Challenge>> getUpcomingChallenges() async {
    try {
      final allChallenges = await getAllChallenges();
      final upcomingChallenges = allChallenges
          .where((challenge) => challenge.isUpcoming)
          .toList();

      AppLogger.info('Found ${upcomingChallenges.length} upcoming challenges');
      return upcomingChallenges;
    } catch (e) {
      AppLogger.error('Failed to fetch upcoming challenges', e);
      rethrow;
    }
  }

  /// Get challenges by status
  Future<List<Challenge>> getChallengesByStatus(String status) async {
    try {
      final allChallenges = await getAllChallenges();
      final filteredChallenges = allChallenges
          .where(
            (challenge) =>
                challenge.statut.toLowerCase() == status.toLowerCase(),
          )
          .toList();

      AppLogger.info(
        'Found ${filteredChallenges.length} challenges with status: $status',
      );
      return filteredChallenges;
    } catch (e) {
      AppLogger.error('Failed to fetch challenges by status: $status', e);
      rethrow;
    }
  }

  /// Get challenges with details for mobile app
  Future<List<ChallengeWithDetails>> getChallengesForApp({
    String? status,
    String? userId,
  }) async {
    try {
      AppLogger.info(
        'Fetching challenges for app - Status: $status, UserId: $userId',
      );

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (userId != null) queryParams['userId'] = userId;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint =
          '/challenges/app/list${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await _apiService.get<Map<String, dynamic>>(endpoint);

      final challenges = (response['data'] as List)
          .map(
            (json) =>
                ChallengeWithDetails.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      AppLogger.info('Fetched ${challenges.length} challenges for app');
      return challenges;
    } catch (e) {
      AppLogger.error('Failed to fetch challenges for app', e);
      rethrow;
    }
  }

  /// Get challenges by status using the new endpoint
  Future<List<ChallengeWithDetails>> getChallengesByStatusForApp(
    String status, {
    String? userId,
  }) async {
    return getChallengesForApp(status: status, userId: userId);
  }

  /// Get challenges created by user
  Future<List<Challenge>> getChallengesByCreator(String creatorId) async {
    try {
      final allChallenges = await getAllChallenges();
      final creatorChallenges = allChallenges
          .where((challenge) => challenge.createurId == creatorId)
          .toList();

      AppLogger.info(
        'Found ${creatorChallenges.length} challenges created by: $creatorId',
      );
      return creatorChallenges;
    } catch (e) {
      AppLogger.error('Failed to fetch challenges by creator: $creatorId', e);
      rethrow;
    }
  }

  /// Search challenges by name
  Future<List<Challenge>> searchChallenges(String query) async {
    try {
      final allChallenges = await getAllChallenges();
      final searchResults = allChallenges
          .where(
            (challenge) =>
                challenge.nom.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      AppLogger.info(
        'Found ${searchResults.length} challenges matching: $query',
      );
      return searchResults;
    } catch (e) {
      AppLogger.error('Failed to search challenges: $query', e);
      rethrow;
    }
  }

  /// Get challenge statistics
  Future<Map<String, dynamic>> getChallengeStatistics(
    String challengeId,
  ) async {
    try {
      AppLogger.info('Fetching statistics for challenge: $challengeId');

      // Get challenge details
      final challenge = await getChallengeById(challengeId);

      // Get leaderboard to calculate stats
      final leaderboard = await getChallengeLeaderboard(challengeId);

      final stats = {
        'challenge': challenge.toJson(),
        'totalParticipants': leaderboard.length,
        'averageScore': leaderboard.isNotEmpty
            ? leaderboard.map((p) => p.scoreTotal).reduce((a, b) => a + b) /
                  leaderboard.length
            : 0.0,
        'topScore': leaderboard.isNotEmpty
            ? leaderboard
                  .map((p) => p.scoreTotal)
                  .reduce((a, b) => a > b ? a : b)
            : 0.0,
        'completionRate': challenge.hasEnded ? 1.0 : challenge.progress,
        'isActive': challenge.isActive,
        'isCompleted': challenge.isCompleted,
        'daysRemaining': challenge.remainingTime?.inDays ?? 0,
      };

      AppLogger.info('Calculated statistics for challenge: $challengeId');
      return stats;
    } catch (e) {
      AppLogger.error('Failed to get challenge statistics: $challengeId', e);
      rethrow;
    }
  }
}
