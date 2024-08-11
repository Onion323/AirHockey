import 'package:airhockey/app_actions.dart';

import 'app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is UpdateLeaderboardAction) {
    return state.copyWith(leaderboard: action.leaderboard);
  }
  return state;
}
