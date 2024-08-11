import 'app_state.dart';

class LoadLeaderboardAction {}

class AddLeaderboardEntryAction {
  final LeaderboardEntry leaderboardEntry;

  AddLeaderboardEntryAction(this.leaderboardEntry);
}

class UpdateLeaderboardAction {
  final List<LeaderboardEntry> leaderboard;

  UpdateLeaderboardAction(this.leaderboard);
}
