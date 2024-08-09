import 'package:flutter/foundation.dart';

class LeaderboardEntry {
  final String name;
  final int time;
  final String difficulty;
  final DateTime timestamp;

  LeaderboardEntry({
    required this.name,
    required this.time,
    required this.difficulty,
    required this.timestamp,
  });
}

class AppState {
  final List<LeaderboardEntry> leaderboard;

  AppState({required this.leaderboard});

  factory AppState.initial() {
    return AppState(leaderboard: []);
  }

  AppState copyWith({List<LeaderboardEntry>? leaderboard}) {
    return AppState(
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }
}
