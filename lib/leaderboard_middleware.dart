import 'package:airhockey/app_actions.dart';
import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart';

class LeaderboardMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is LoadLeaderboardAction) {
      _loadLeaderboard(store);
    } else if (action is AddLeaderboardEntryAction) {
      _addLeaderboardEntry(store, action);
    }
    next(action);
  }

  void _loadLeaderboard(Store<AppState> store) {
    FirebaseFirestore.instance
        .collection('game_records')
        .orderBy('time', descending: false)
        .snapshots()
        .asyncMap((querySnapshot) {
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
    });
  }

  void _addLeaderboardEntry(
      Store<AppState> store, AddLeaderboardEntryAction action) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('leaderboard').add({
      'name': action.leaderboardEntry.name,
      'difficulty': action.leaderboardEntry.difficulty,
      'time': action.leaderboardEntry.time,
      'timestamp': action.leaderboardEntry.timestamp,
    });
  }
}
