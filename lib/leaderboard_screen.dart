import 'package:airhockey/app_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'app_state.dart';
import 'leaderboard_list.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Easy'),
              Tab(text: 'Medium'),
              Tab(text: 'Hard'),
            ],
          ),
        ),
        body: StoreConnector<AppState, List<LeaderboardEntry>>(
          onInit: (store) => store.dispatch(LoadLeaderboardAction()),
          converter: (store) => store.state.leaderboard,
          builder: (context, leaderboard) {
            return TabBarView(
              children: [
                LeaderboardList(
                  difficulty: 'easy',
                  leaderboard: leaderboard
                      .where((entry) => entry.difficulty == 'easy')
                      .toList(),
                ),
                LeaderboardList(
                  difficulty: 'medium',
                  leaderboard: leaderboard
                      .where((entry) => entry.difficulty == 'medium')
                      .toList(),
                ),
                LeaderboardList(
                  difficulty: 'hard',
                  leaderboard: leaderboard
                      .where((entry) => entry.difficulty == 'hard')
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
