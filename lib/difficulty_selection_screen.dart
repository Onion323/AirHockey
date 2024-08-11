import 'package:flutter/material.dart';
import 'air_hockey_board.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final String playerName;
  const DifficultySelectionScreen({Key? key, required this.playerName})
      : super(key: key);

  void _startGame(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AirHockeyBoard(difficulty: difficulty, playerName: playerName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.easy),
              child: const Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.medium),
              child: const Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.hard),
              child: const Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}

enum Difficulty { easy, medium, hard }
