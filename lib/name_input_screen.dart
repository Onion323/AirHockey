import 'package:flutter/material.dart';
import 'difficulty_selection_screen.dart';
import 'leaderboard_screen.dart';

class NameInputScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  void _proceedToDifficultySelection(BuildContext context) {
    final playerName = _nameController.text.trim();
    if (playerName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DifficultySelectionScreen(playerName: playerName),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name to continue')),
      );
    }
  }

  void _navigateToLeaderboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaderboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Your Name')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "Player Name"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _proceedToDifficultySelection(context),
                child: Text('Proceed'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToLeaderboard(context),
                child: Text('Leaderboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
