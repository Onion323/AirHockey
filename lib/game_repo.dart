import 'dart:async';
import 'app_state.dart';

abstract class GameRepository {
  Future<void> saveGameRecord({
    required String playerName,
    required int time,
    required String difficulty,
    required DateTime timestamp,
  });

  Future<List<LeaderboardEntry>> fetchLeaderboard(String difficulty);
}
