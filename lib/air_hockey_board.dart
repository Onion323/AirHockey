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
  late Timer _timer;
  Timer? _cpuPuckTimer;
  double _puckSpeedX = 6.0;
  double _puckSpeedY = 6.0;
  double _cpuSpeed = 2.0;
  bool _cpuHitPuck = false;
  bool _movingBackward = false;
  late DateTime _startTime;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setDifficulty();
    _startGameLoop();
    _startTime = DateTime.now();
  }

  void _setDifficulty() {
    switch (widget.difficulty) {
      case Difficulty.easy:
        _cpuSpeed = 2.0;
        break;
      case Difficulty.medium:
        _cpuSpeed = 4.0;
        break;
      case Difficulty.hard:
        _cpuSpeed = 6.0;
        break;
    }
  }

  void _startGameLoop() {
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {
        _updatePuckPosition();
        _updateCpuPosition();
        _checkGoal();
        _elapsedTime = DateTime.now().difference(_startTime);
      });
    });
  }

  void _updatePuckPosition() {
    double newX = _puckPosition.dx + _puckSpeedX;
    double newY = _puckPosition.dy + _puckSpeedY;

    newX = newX.clamp(0, 380);
    newY = newY.clamp(0, 460);

    if (newY <= 0 || newY >= 460) {
      _puckSpeedY = -_puckSpeedY;
    }

    if (newX <= 0 || newX >= 380) {
      _puckSpeedX = -_puckSpeedX;
    }

    if (_checkCollision(_playerPosition, _puckPosition)) {
      _bouncePuck(_playerPosition);
      _cpuPuckTimer?.cancel();
      _cpuHitPuck = false;
      _movingBackward = false; // Reset backward movement when player hits puck
    } else if (_checkCollision(_cpuPosition, _puckPosition)) {
      _bouncePuck(_cpuPosition);
      _cpuHitPuck = true;
      _moveCpuBackward(); // Move CPU backward
    }

    _puckPosition = Offset(newX, newY);
  }

  bool _checkCollision(Offset paddle, Offset puck) {
    double dx = paddle.dx - puck.dx;
    double dy = paddle.dy - puck.dy;
    double distance = sqrt(dx * dx + dy * dy);
    return distance < 35;
  }

  void _bouncePuck(Offset paddlePosition) {
    double angle = atan2(_puckPosition.dy - paddlePosition.dy,
        _puckPosition.dx - paddlePosition.dx);
    _puckSpeedX = 6.0 * cos(angle);
    _puckSpeedY = 6.0 * sin(angle);
  }

  void _moveCpuBackward() {
    if (!_movingBackward) {
      _movingBackward = true;
      _cpuPuckTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
        setState(() {
          if (_cpuPosition.dy > 5) {
            _cpuPosition = Offset(_cpuPosition.dx, _cpuPosition.dy - 2);
          } else {
            _movingBackward = false;
            _cpuHitPuck = false; // Reset flag
            timer.cancel();
          }
        });
      });
    }
  }

  void _updateCpuPosition() {
    if (_movingBackward) {
      return; // Skip if CPU is moving backward
    }

    double cpuMoveX = 0;
    double cpuMoveY = 0;

    if (_cpuPosition.dx < _puckPosition.dx) {
      cpuMoveX = _cpuSpeed;
    } else if (_cpuPosition.dx > _puckPosition.dx) {
      cpuMoveX = -_cpuSpeed;
    }

    if (_cpuPosition.dy < _puckPosition.dy) {
      cpuMoveY = _cpuSpeed;
    } else if (_cpuPosition.dy > _puckPosition.dy) {
      cpuMoveY = -_cpuSpeed;
    }

    _cpuPosition = Offset(
      (_cpuPosition.dx + cpuMoveX).clamp(0, 360),
      (_cpuPosition.dy + cpuMoveY).clamp(0, 185),
    );
  }

  void _checkGoal() {
    if (_puckPosition.dy <= 20 &&
        _puckPosition.dx >= 140 &&
        _puckPosition.dx <= 240) {
      _playerScore++; // Change this line to increment player score
      _resetPuck();
    } else if (_puckPosition.dy >= 440 &&
        _puckPosition.dx >= 140 &&
        _puckPosition.dx <= 240) {
      _cpuScore++; // Change this line to increment CPU score
      _resetPuck();
    }

    if (_playerScore == 7 || _cpuScore == 7) {
      _showGameOverDialog();
    }
  }

  void _resetPuck() {
    _puckPosition = Offset(190.0, 230.0);
    _puckSpeedX = (Random().nextBool() ? 6.0 : -6.0);
    _puckSpeedY = (Random().nextBool() ? 6.0 : -6.0);
    _cpuHitPuck = false;
    _movingBackward = false; // Reset _movingBackward flag when resetting puck
  }

  void _showGameOverDialog() {
    String winner = _playerScore == 7 ? 'Player' : 'CPU';
    if (_playerScore == 7) {
      _recordPlayerTime();
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('$winner wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    _timer.cancel();
  }

  void _recordPlayerTime() async {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime).inSeconds;

    await FirebaseFirestore.instance.collection('game_records').add({
      'name': widget.playerName,
      'time': duration,
      'difficulty': widget.difficulty
          .toString()
          .split('.')
          .last, // Store difficulty level
      'timestamp': endTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.purple, width: 4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 140,
                top: 0,
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 250,
                child: Container(
                  width: 400,
                  height: 2,
                  color: Colors.purple,
                ),
              ),
              Positioned(
                left: 150,
                top: 180,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                ),
              ),
              Positioned(
                left: 100,
                bottom: 0,
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 100,
                top: 0,
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      top: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 250,
                child: Container(
                  width: 400,
                  height: 2,
                  color: Colors.purple,
                ),
              ),
              Positioned(
                left: _playerPosition.dx,
                top: _playerPosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double newX = _playerPosition.dx + details.delta.dx;
                      double newY = _playerPosition.dy + details.delta.dy;
                      _playerPosition = Offset(
                        newX.clamp(0, 360),
                        newY.clamp(250, 460),
                      );
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _cpuPosition.dx,
                top: _cpuPosition.dy,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
              Positioned(
                left: _puckPosition.dx,
                top: _puckPosition.dy,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 220,
                child: Text(
                  '$_playerScore',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              Positioned(
                right: 10,
                top: 220,
                child: Text(
                  '$_cpuScore',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
