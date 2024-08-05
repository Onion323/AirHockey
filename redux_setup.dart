class AppState {
  final String playerName;

  AppState({required this.playerName});

  AppState.initialState() : playerName = "";
}

class SetPlayerNameAction {
  final String playerName;

  SetPlayerNameAction(this.playerName);
}

AppState appReducer(AppState state, dynamic action) {
  if (action is SetPlayerNameAction) {
    return AppState(playerName: action.playerName);
  }
  return state;
}
