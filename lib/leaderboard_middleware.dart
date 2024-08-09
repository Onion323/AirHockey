import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';
import 'app_reducer.dart';

class LeaderboardMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is LoadLeaderboardAction) {
      _loadLeaderboard(store);
    }
    next(action);
  }

  void _loadLeaderboard(Store<AppState> store) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('game_records')
        .orderBy('time', descending: false)
        .get();

    final leaderboard = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return LeaderboardEntry(
        name: data['name'],
        time: data['time'],
        difficulty: data['difficulty'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();

    store.dispatch(UpdateLeaderboardAction(leaderboard));
  }
}
