import 'app_state.dart';

class LoadLeaderboardAction {}

class LeaderboardLoadedAction {
  final List<LeaderboardEntry> leaderboard;

  LeaderboardLoadedAction(this.leaderboard);
}
