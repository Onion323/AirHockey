import 'app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is UpdateLeaderboardAction) {
    return state.copyWith(leaderboard: action.leaderboard);
  }
  return state;
}

class UpdateLeaderboardAction {
  final List<LeaderboardEntry> leaderboard;

  UpdateLeaderboardAction(this.leaderboard);
}

class LoadLeaderboardAction {}
