import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'main_game_page.dart';
import 'button_style_main.dart';

class GameOverOverlay extends StatelessWidget {
  final VoidCallback onNewGame;
  final VoidCallback onMainMenu;

  const GameOverOverlay({
    super.key,
    required this.onNewGame,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54, // Semi-transparent background
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20.0),
            // "New Game" button
            SizedBox(
              width: 150.0,
              child: StyledButton(
                text: "New Game",
                onPressed: onNewGame,
              ),
            ),
            const SizedBox(height: 10.0),
            // "Main Menu" button
            SizedBox(
              width: 150.0,
              child: StyledButton(
                text: "Main Menu",
                onPressed: onMainMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
