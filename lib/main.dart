import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Air Hockey',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
          backgroundColor: Colors.black,
          accentColor: Colors.green,
          cardColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DifficultySelectionScreen(),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({Key? key}) : super(key: key);

  void _startGame(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirHockeyBoard(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Difficulty'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.easy),
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.medium),
              child: Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.hard),
              child: Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}

enum Difficulty { easy, medium, hard }

class AirHockeyBoard extends StatefulWidget {
  final Difficulty difficulty;
  AirHockeyBoard({Key? key, required this.difficulty}) : super(key: key);

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
  double _puckSpeedX = 6.0;
  double _puckSpeedY = 6.0;
  double _cpuSpeed = 2.0;
  bool _initialBounce = true;
  bool _cpuHitPuck = false;
  bool _movingBackward = false;

  Offset _puckPositionBeforeHit = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    _setDifficulty();
    _startGameLoop();
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
      newY = _puckPosition.dy + _puckSpeedY;
      _cpuHitPuck = false;
    } else if (_checkCollision(_cpuPosition, _puckPosition)) {
      _puckPositionBeforeHit = _puckPosition;
      _bouncePuck(_cpuPosition);
      _cpuHitPuck = true;
      _moveCpuBackward();
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
    if (_initialBounce) {
      angle = (Random().nextDouble() * (60 - 30) + 30) * pi / 180;
      _initialBounce = false;
    }
    _puckSpeedX = 6.0 * cos(angle);
    _puckSpeedY = 6.0 * sin(angle);
  }

  void _moveCpuBackward() {
    if (!_movingBackward) {
      _movingBackward = true;
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        setState(() {
          _cpuPosition = Offset(_cpuPosition.dx, _cpuPosition.dy - 2);
          if (_cpuPosition.dy <= 0) {
            _movingBackward = false;
            timer.cancel();
            _moveCpuForward();
          }
        });
      });
    }
  }

  void _moveCpuForward() {
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        _cpuPosition = Offset(_cpuPosition.dx, _cpuPosition.dy + 4);
        if (_cpuPosition.dy >= 30) {
          timer.cancel();
        }
      });
    });
  }

  void _updateCpuPosition() {
    if (_movingBackward || _cpuHitPuck) return;

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
      _cpuScore++;
      _resetPuck();
    } else if (_puckPosition.dy >= 440 &&
        _puckPosition.dx >= 140 &&
        _puckPosition.dx <= 240) {
      _playerScore++;
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
    _initialBounce = true;
    _cpuHitPuck = false;
  }

  void _showGameOverDialog() {
    String winner = _playerScore == 7 ? 'Player' : 'CPU';
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
              // Goals
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
              // Center line
              Positioned(
                left: 0,
                top: 250,
                child: Container(
                  width: 400,
                  height: 2,
                  color: Colors.purple,
                ),
              ),
              // Center circle
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
              // Scores
              Positioned(
                left: 20,
                top: 210,
                child: Text(
                  '$_cpuScore',
                  style: TextStyle(color: Colors.purple, fontSize: 30),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 210,
                child: Text(
                  '$_playerScore',
                  style: TextStyle(color: Colors.purple, fontSize: 30),
                ),
              ),
              Positioned(
                left: _puckPosition.dx,
                top: _puckPosition.dy,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: _playerPosition.dx,
                top: _playerPosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _playerPosition += details.delta;
                      _playerPosition = Offset(
                        _playerPosition.dx.clamp(0, 360),
                        _playerPosition.dy.clamp(250, 460),
                      );
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
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
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
