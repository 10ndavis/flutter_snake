import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/helpers/direction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // make the app full screen
    SystemChrome.setEnabledSystemUIOverlays([]);

    // disable rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'Snek',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // game over
  bool gameOver = false;

  // the number of squares on our grid
  final int squareCount = 760;

  static Random randomNumber = Random();

  // location of food on grid
  int food;

  void newFood() {
    food = randomNumber.nextInt(700);
  }

  // the starting position of the snake
  static List<int> snakePosition = [19, 65, 85, 105, 125];

  // position of dots for 8 bit game over text
  static List<int> gameOverText = [
    // G
    40,
    41,
    42,
    43,
    60,
    80,
    100,
    120,
    121,
    122,
    123,
    103,
    83,
    82,
    // A
    45,
    46,
    47,
    48,
    65,
    68,
    85,
    86,
    87,
    88,
    105,
    108,
    125,
    128,
    // M
    50,
    51,
    70,
    90,
    110,
    130,
    50,
    72,
    53,
    54,
    74,
    94,
    114,
    134,
    // E
    56,
    57,
    58,
    59,
    76,
    96,
    97,
    98,
    116,
    136,
    137,
    138,
    139,

    // O
    180,
    181,
    182,
    183,
    200,
    203,
    220,
    223,
    240,
    243,
    260,
    261,
    262,
    263,
    // V
    185,
    189,
    205,
    209,
    225,
    229,
    246,
    248,
    267,
    // E
    191,
    192,
    193,
    194,
    211,
    231,
    232,
    233,
    251,
    271,
    272,
    273,
    274,
    // R
    196,
    197,
    198,
    199,
    216,
    219,
    236,
    238,
    256,
    259,
    276,
    279
  ];

  // the snakes movement direction
  Direction direction = Direction.down;

  // controls speed of game.
  static Duration gameSpeed = const Duration(milliseconds: 300);

  // active timer
  Timer timer;

  // is the game paused
  bool paused = false;

  // game score
  int score = 0;

  // starts the game
  void startGame() {
    // reset game
    score = 0;
    gameOver = false;

    // unpause game
    paused = false;

    // set direction to down
    direction = Direction.down;

    // set new food location
    newFood();

    // cancel the current game tick if one exists.
    if (timer != null && timer.isActive) {
      timer.cancel();
    }

    // resets snakes start position
    snakePosition = [45, 65, 85, 105, 125];

    // the game "tick" that updates the snakes position
    gameSpeed = const Duration(milliseconds: 300);

    // the game "tick" that updates the snakes position.
    timer = Timer.periodic(gameSpeed, (Timer timer) {
      updateGame();
    });
  }

  // resume the game after it has been paused
  void resume() {
    paused = false;
    timer = Timer.periodic(gameSpeed, (Timer timer) {
      updateGame();
    });

    setState(() {});
  }

  // pause the game
  void pause() {
    paused = true;
    if (timer != null && timer.isActive) {
      timer.cancel();
    }

    setState(() {});
  }

  // updates the game state ("tick")
  void updateGame() {
    switch (direction) {
      case Direction.down:
        // add a new head to the snake.
        // this gives the illusion of movement.
        snakePosition.add(snakePosition.last + 20);
        break;
      case Direction.up:
        // add a new head to the snake.
        // this gives the illusion of movement.
        snakePosition.add(snakePosition.last - 20);
        break;
      case Direction.right:
        // add a new head to the snake.
        // this gives the illusion of movement.
        snakePosition.add(snakePosition.last + 1);
        break;
      case Direction.left:
        // add a new head to the snake.
        // this gives the illusion of movement.
        snakePosition.add(snakePosition.last - 1);
        break;
    }

    // remove the tail of the snake.
    // This gives the illusion of movement.
    // Unless we are on food! If we're on food,
    // we don't remove the last piece of the tail.
    if (snakePosition.last == food) {
      // generate new food and increase the score
      newFood();
      score += 100;

      // increase the game speed
      gameSpeed = Duration(milliseconds: gameSpeed.inMilliseconds - 10);

      // cancel the old timer
      timer.cancel();

      // set the new timer
      timer = Timer.periodic(gameSpeed, (Timer timer) {
        updateGame();
      });
    } else if (containsDupes(snakePosition)) {
      // if the snake hits itself, end the game.
      endGame();
    } else if (snakePosition.last > squareCount || snakePosition.last < 0) {
      // if the snake goes off the top or bottom of the screen, end the game.
      endGame();
    } else if (checkHorizontalLimits(snakePosition)) {
      // if the snake goes off the horizontal edges, end the game.
      endGame();
    } else {
      snakePosition.removeAt(0);
    }

    setState(() {
      // "tick"
    });
  }

  // check snake position.
  bool checkHorizontalLimits(List<int> positions) {
    String lastToString = positions.last.toString();
    String secondToLastToString =
        positions.elementAt(positions.indexOf(positions.last) - 1).toString();

    //determine what number combos are invalid
    if (int.parse(secondToLastToString) % 20 == 0 &&
        (int.parse(lastToString) + 1) % 20 == 0) {
      // hit the left edge
      return true;
    } else if (int.parse(lastToString) % 20 == 0 &&
        (int.parse(secondToLastToString) + 1) % 20 == 0) {
      // hit the right edge
      return true;
    }
    return false;
  }

  // game over
  void endGame() {
    gameOver = true;
    pause();
    setState(() {});
  }

  // checks if the snake contains duplicates
  bool containsDupes(List<int> items) {
    return items.length != items.toSet().length;
  }

  // handle vertical drag
  void horizontalDrag(DragUpdateDetails details) {
    // if the game is paused, don't allow direction change
    if (paused) {
      return;
    }

    if (direction != Direction.left && details.delta.dx > 0) {
      direction = Direction.right;
    } else if (direction != Direction.right && details.delta.dx < 0) {
      direction = Direction.left;
    }
  }

  // handle horizontal drag
  void verticalDrag(DragUpdateDetails details) {
    // if the game is paused, don't allow direction change
    if (paused) {
      return;
    }

    if (direction != Direction.up && details.delta.dy > 0) {
      direction = Direction.down;
    } else if (direction != Direction.down && details.delta.dy < 0) {
      direction = Direction.up;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool timerRunning = timer != null && timer.isActive ? true : false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: verticalDrag,
                    onHorizontalDragUpdate: horizontalDrag,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: squareCount,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 20,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          if (snakePosition.contains(index)) {
                            return Container(
                              padding: EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                          if (index == food) {
                            return Container(
                              padding: EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  color: Colors.amber,
                                ),
                              ),
                            );
                          }
                          return Container(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                color: Color.fromRGBO(30, 30, 30, 1),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: GestureDetector(
                        onTap: startGame,
                        child: Text(
                          timerRunning || paused ? 'Restart' : 'Start',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (timerRunning || paused)
                      Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: GestureDetector(
                          onTap: paused ? resume : pause,
                          child: Text(
                            paused ? 'Resume' : 'Pause',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
            if (gameOver)
              Container(
                color: Colors.black,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 760,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 20,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (gameOverText.contains(index)) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.amber,
                            ),
                          ),
                        );
                      }
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Color.fromRGBO(30, 30, 30, 1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (gameOver)
              Center(
                child: MaterialButton(
                  onPressed: startGame,
                  color: Colors.amber,
                  child: Text(
                    'New Game',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
