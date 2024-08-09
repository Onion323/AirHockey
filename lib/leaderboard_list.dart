import 'package:flutter/material.dart';
import '/app_state.dart';

class LeaderboardList extends StatelessWidget {
  final String difficulty;
  final List<LeaderboardEntry> leaderboard;

  const LeaderboardList(
      {Key? key, required this.difficulty, required this.leaderboard})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (leaderboard.isEmpty) {
      return Center(child: Text('No records found'));
    }

    return ListView.builder(
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              entry.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Time: ${entry.time} seconds\nTimestamp: ${entry.timestamp}',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            trailing: Icon(
              Icons.star,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
