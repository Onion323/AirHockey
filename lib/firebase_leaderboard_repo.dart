import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_repo.dart';
import 'dart:async';
import 'app_state.dart';

class FirestoreGameRepository implements GameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveGameRecord({
    required String playerName,
    required int time,
    required String difficulty,
    required DateTime timestamp,
  }) async {
    await _firestore.collection('leaderboard').add({
      'name': playerName,
      'time': time,
      'difficulty': difficulty,
      'timestamp': timestamp,
    });
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard(String difficulty) async {
    final querySnapshot = await _firestore
        .collection('game_records')
        .where('difficulty', isEqualTo: difficulty)
        .orderBy('time')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return LeaderboardEntry(
        name: data['name'],
        time: data['time'],
        difficulty: data['difficulty'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }
}
