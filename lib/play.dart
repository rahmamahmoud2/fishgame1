import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Game',
      home: FishGame(),
    );
  }
}

class FishGame extends StatefulWidget {
  @override
  _FishGameState createState() => _FishGameState();
}

class _FishGameState extends State<FishGame> {
  Offset fishPosition = Offset(330, 50);
  List<Offset> ballPositions = [];
  List<Offset> newBallPositions = [];
  double fishSize = 50;
  double ballSize = 50;
  int score = 0;

  final double minDistanceBetweenPearls = 100;
  final double minDistanceBetweenPearlsAndBombs = 100;

  void _generateBallPositions(double screenWidth, double screenHeight) {
    ballPositions =
        _generatePositions(screenWidth, screenHeight, 15, screenHeight / 4, []);

    newBallPositions = _generatePositions(
        screenWidth, screenHeight, 5, screenHeight / 4, ballPositions);
  }

  List<Offset> _generatePositions(double screenWidth, double screenHeight,
      int count, double topOffset, List<Offset> existingPositions) {
    List<Offset> positions = [];

    while (positions.length < count) {
      double dx = Random().nextDouble() * (screenWidth - ballSize);
      double dy = Random().nextDouble() * (screenHeight * 3 / 4) + topOffset;

      Offset newPosition = Offset(dx, dy);

      bool isTooCloseToExisting = positions.any((position) =>
          (position - newPosition).distance < minDistanceBetweenPearls);
      bool isTooCloseToExistingPearls = existingPositions.any((position) =>
          (position - newPosition).distance < minDistanceBetweenPearlsAndBombs);

      if (!isTooCloseToExisting && !isTooCloseToExistingPearls) {
        positions.add(newPosition);
      }
    }

    return positions;
  }

  void _restartGame(double screenWidth, double screenHeight) {
    setState(() {
      _generateBallPositions(screenWidth, screenHeight);
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (ballPositions.isEmpty) {
      _generateBallPositions(width, height);
    }

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/images/download (17).jpg',
                ),
                fit: BoxFit.cover)),
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              fishPosition = Offset(fishPosition.dx + details.delta.dx,
                  fishPosition.dy + details.delta.dy);

              ballPositions.removeWhere((ball) {
                bool isEaten =
                    (fishPosition - ball).distance < (fishSize + ballSize) / 2;
                if (isEaten) {
                  score++;
                }
                return isEaten;
              });

              newBallPositions.removeWhere((ball) {
                bool isEaten =
                    (fishPosition - ball).distance < (fishSize + ballSize) / 2;
                if (isEaten) {
                  score--;
                }
                return isEaten;
              });

              if (ballPositions.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Congratulations!'),
                    content: Text(
                        'You have eaten all the balls. Your score is $score.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _restartGame(width, height);
                        },
                        child: Text('Restart'),
                      ),
                    ],
                  ),
                );
              }
            });
          },
          child: Stack(
            children: [
              ...ballPositions.map((ball) => Positioned(
                    left: ball.dx,
                    top: ball.dy,
                    child: Container(
                      width: ballSize,
                      height: ballSize,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/pearl.png'),
                              fit: BoxFit.cover)),
                    ),
                  )),
              ...newBallPositions.map((ball) => Positioned(
                    left: ball.dx,
                    top: ball.dy,
                    child: Container(
                      width: ballSize,
                      height: ballSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/pingbong.png'),
                        ),
                      ),
                    ),
                  )),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  width: width * 0.24,
                  height: height * 0.09,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Score: $score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: fishPosition.dx,
                  top: fishPosition.dy,
                  child: Image.asset(
                    'assets/images/fish.png',
                    width: 200,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
