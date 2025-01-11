import 'package:flutter/material.dart';
import 'helpers/joypad.dart';
import 'brd_world_game.dart';
import 'package:flame/game.dart';
import 'dart:async';
import 'main_menu.dart'; // Import MainMenu

class MainGamePage extends StatefulWidget {
  const MainGamePage({super.key});

  @override
  MainGameState createState() => MainGameState();
}

class MainGameState extends State<MainGamePage> {
  BrdWorldGame game = BrdWorldGame(); // Game initialization
  int _collectedCoins = 0; // Number of collected coins
  int _collectedRubins = 0; // Number of collected rubins
  int _collectedCrystals = 0; // Number of collected crystals
  int _playerLives = 5; // Number of player lives
  int _elapsedTime = 0; // Elapsed time
  bool _isTimerRunning = false; // Timer status
  Timer? _timer; // Timer

  @override
  void initState() {
    super.initState();

    _elapsedTime = 90; // Start the countdown from 90 seconds

    // Pass callback to update coin score
    game.onScoreChangedCoins = (collectedCoins, totalCoins) {
      setState(() {
        _collectedCoins = collectedCoins;
      });
    };

    // Pass callback to update rubin score
    game.onScoreChangedRubins = (collectedRubins, totalRubins) {
      setState(() {
        _collectedRubins = collectedRubins;
      });
    };

    // Pass callback to update crystal score
    game.onScoreChangedCrystals = (collectedCrystals, totalCrystals) {
      setState(() {
        _collectedCrystals = collectedCrystals;
      });
    };

    // Pass callback to update lives
    game.onLivesChanged = (remainingLives) {
      setState(() {
        _playerLives = remainingLives;
      });
    };

    // Start the timer immediately after loading
    _toggleTimer();
  }

void _toggleTimer() {
  setState(() {
    if (_isTimerRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_elapsedTime > 0) {
          setState(() {
            _elapsedTime--;
          });
        } else {
          _timer?.cancel();
          // Show Game Over overlay when the timer reaches zero
          Future.microtask(() {
            game.overlays.add('GameOver');
          });
        }
      });
    }
    _isTimerRunning = !_isTimerRunning;
    game.togglePause(); // Manage game pause state
  });
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(180, 24, 220, 70),
      body: Stack(
        children: [
          GameWidget(game: game), // Display game screen

Align(
  alignment: Alignment.topRight,
  child: Padding(
    padding: const EdgeInsets.only(top: 70.0, right: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLivesIndicator(),
      ],
    ),
  ),
),

Align(
  alignment: Alignment.topRight,
  child: Padding(
    padding: const EdgeInsets.only(top: 100.0, right: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crystal
        Column(
          children: [
            Transform.scale(
              scale: 0.6, // Scale the crystal image
              child: Image.asset(
                'assets/images/crystal-50x71.png',
                width: 50.0,
                height: 71.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              '$_collectedCrystals/${game.totalCrystal}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0), // Spacing between items
        // Coins
        Column(
          children: [
            Image.asset(
              'assets/images/coins-40x40.png',
              width: 40.0,
              height: 40.0,
            ),
            const SizedBox(height: 2.0),
            Text(
              '$_collectedCoins/${game.totalCoins}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0), // Spacing between items
        // Rubins
        Column(
          children: [
            Image.asset(
              'assets/images/rubins-40x40.png',
              width: 40.0,
              height: 40.0,
            ),
            const SizedBox(height: 2.0),
            Text(
              '$_collectedRubins/${game.totalRubins}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0), // Spacing between items
        // Time (Hourglass)
        Column(
          children: [
            const SizedBox(
              width: 40.0, // Match the width of the other images
              height: 40.0, // Match the height of the other images
              child: Icon(
                Icons.hourglass_bottom,
                color: Colors.white,
                size: 24.0, // Icon size
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              '$_elapsedTime s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),

Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Joypad(onDirectionChanged: game.onJoypadDirectionChanged), // Joypad
            ),
          ),
Align(
  alignment: Alignment.topLeft,
  child: Padding(
    padding: const EdgeInsets.only(top: 60.0, left: 20.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Styled "Pause/Start" button
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green, // Border color
              width: 4.0, // Border thickness
            ),
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          width: 90.0,
          height: 40.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Transparent background
              shadowColor: Colors.transparent, // Remove shadow
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0), // Reduced padding
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _toggleTimer,
            child: Text(
              _isTimerRunning ? 'Pause' : 'Start',
              style: const TextStyle(color: Colors.white), // Text color
            ),
          ),
        ),
        const SizedBox(height: 10.0), // Space between buttons
        // Styled "Close" button
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green, // Border color
              width: 4.0, // Border thickness
            ),
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          width: 90.0,
          height: 40.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Transparent background
              shadowColor: Colors.transparent, // Remove shadow
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0), // Reduced padding
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              // Navigate to MainMenu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainMenu(),
                ),
              );
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white), // Text color
            ),
          ),
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }

  // Widget to display player lives
  Widget _buildLivesIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _playerLives,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 28.0,
          ),
        ),
      ),
    );
  }
}
