import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'difficulty_selection_screen.dart';

class AirHockeyBoard extends StatefulWidget {
  final Difficulty difficulty;
  final String playerName;

  AirHockeyBoard({Key? key, required this.difficulty, required this.playerName})
      : super(key: key);

  @override
  _AirHockeyBoardState createState() => _AirHockeyBoardState();
}

class _AirHockeyBoardState extends State<AirHockeyBoard> {
  Offset _playerPosition = Offset(180.0, 430.0);
  Offset _cpuPosition = Offset(180.0, 30.0);
  Offset _puckPosition = Offset(190.0, 230.0);
  int _playerScore = 0;
  int _cpuScore = 0;
  Offset _puckVelocity = Offset(3.0, 3.0);
  late Timer _gameTimer;
  late double _boardWidth;
  late double _boardHeight;

  @override
  void initState() {
    super.initState();
    _startGameLoop();
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _updatePuckPosition();
        _checkCollisions();
        _checkGoal();
      });
    });
  }

  void _updatePuckPosition() {
    _puckPosition += _puckVelocity;
  }

  void _checkCollisions() {
    if (_puckPosition.dx <= 0 || _puckPosition.dx >= _boardWidth) {
      _puckVelocity = Offset(-_puckVelocity.dx, _puckVelocity.dy);
    }
    if (_puckPosition.dy <= 0 || _puckPosition.dy >= _boardHeight) {
      _puckVelocity = Offset(_puckVelocity.dx, -_puckVelocity.dy);
    }
  }

  void _checkGoal() {
    if (_puckPosition.dy <= 0) {
      _playerScore++;
      _resetPositions();
    } else if (_puckPosition.dy >= _boardHeight) {
      _cpuScore++;
      _resetPositions();
    }

    if (_playerScore == 7 || _cpuScore == 7) {
      _endGame();
    }
  }

  void _resetPositions() {
    _puckPosition = Offset(_boardWidth / 2, _boardHeight / 2);
    _puckVelocity = Offset(3.0 * (Random().nextBool() ? 1 : -1),
        3.0 * (Random().nextBool() ? 1 : -1));
  }

  void _endGame() {
    _gameTimer.cancel();
    _saveScore();
    _showGameOverDialog();
  }

  void _saveScore() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('leaderboard').add({
      'name': widget.playerName,
      'difficulty': widget.difficulty.toString().split('.').last,
      'score': _playerScore,
      'timestamp': Timestamp.now(),
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(
          _playerScore > _cpuScore ? 'You Win!' : 'You Lose!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _boardWidth = constraints.maxWidth;
        _boardHeight = constraints.maxHeight;

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _playerPosition = Offset(
                details.localPosition.dx,
                _playerPosition.dy,
              );
            });
          },
          child: Stack(
            children: [
              Positioned(
                top: _playerPosition.dy,
                left: _playerPosition.dx,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: _cpuPosition.dy,
                left: _cpuPosition.dx,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: _puckPosition.dy,
                left: _puckPosition.dx,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Text(
                  'Score: $_playerScore',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'CPU: $_cpuScore',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }
}
