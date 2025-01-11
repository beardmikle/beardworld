import 'package:brdgame/components/player.dart';
// Для `KeyEventResult`
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для `LogicalKeyboardKey`
import 'package:brdgame/helpers/direction.dart'; // Для `Direction`


class KeyboardHandler {
  final Player player;

  KeyboardHandler(this.player);

  KeyEventResult handleKeyboardInput(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

    if (isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        player.direction = Direction.up;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        player.direction = Direction.down;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        player.direction = Direction.left;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        player.direction = Direction.right;
      }
    } else {
      if (event is KeyUpEvent &&
          (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.keyW ||
              event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.keyS ||
              event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.keyA ||
              event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.keyD)) {
        player.direction = Direction.none;
      }
    }

    return KeyEventResult.handled;
  }
}
