import 'package:brdgame/components/player.dart';
import 'package:brdgame/components/world.dart';
import 'package:brdgame/brd_world_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class Rubin extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Rubin({required Vector2 position, required Vector2 size})
      : super(size: size, position: position, priority: 0) { // Set priority (zIndex)
    add(RectangleHitbox()); // Add a hitbox for the ruby
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('rubins-40x40.png'); // Load the ruby sprite
    debugMode = false; // Enables hitbox visualization for debugging
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Check collision with the player
    if (other is Player) {
      print('Ruby collected! Ruby coordinates: $position');
      removeFromParent(); // Remove the ruby from the map
      (gameRef as BrdWorldGame).incrementScoreRubins(); // Increment the score
    }
  }
}

class RubinManager {
  final GameWorld gameWorld; // Reference to the world
  final int numberOfRubins; // Number of rubies to add
  final Random _random = Random(); // For random positions

  RubinManager({required this.gameWorld, this.numberOfRubins = 20});

  Future<void> distributeRubins() async {
    int createdRubins = 0; // Counter for created rubies

    for (int i = 0; i < numberOfRubins; i++) {
      Vector2? position;

      // Attempts to find a suitable position
      for (int attempt = 0; attempt < 100; attempt++) {
        // Generate a random position within the world
        final potentialPosition = Vector2(
          _random.nextDouble() * gameWorld.size.x,
          _random.nextDouble() * gameWorld.size.y,
        );

        // Check if it doesn't overlap with collisions
        if (!_isCollidingRubinWithWorld(potentialPosition)) {
          position = potentialPosition;
          break;
        }
      }

      // If a position is found, create the ruby
      if (position != null) {
        final rubin = Rubin(
          position: position,
          size: Vector2(40, 40), // Size of the ruby
        );

        await gameWorld.add(rubin); // Add the ruby to the world
        createdRubins++;

        print('Ruby created: $createdRubins, Coordinates: x=${position.x}, y=${position.y}');
      } else {
        print('Failed to find a suitable position for the ruby');
      }
    }

    // Log the total number of rubies
    print('Total rubies created: $createdRubins');
  }

  // Check if the position overlaps with world collisions
  bool _isCollidingRubinWithWorld(Vector2 position) {
    var rubinSize = Vector2(40, 40); // Size of the ruby
    final rubinRect = Rect.fromLTWH(position.x, position.y, rubinSize.x, rubinSize.y);

    for (final rect in gameWorld.collisionRects) {
      final collisionRect = Rect.fromLTRB(
        rect['topLeft']!.x,
        rect['topLeft']!.y,
        rect['bottomRight']!.x,
        rect['bottomRight']!.y,
      );

      if (rubinRect.overlaps(collisionRect)) {
        return true; // Overlaps with an obstacle
      }
    }

    return false; // No overlaps
  }
}
