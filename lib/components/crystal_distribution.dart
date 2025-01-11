import 'package:brdgame/components/player.dart';
import 'package:brdgame/components/world.dart';
import 'package:brdgame/brd_world_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class Crystal extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Crystal({required Vector2 position, required Vector2 size})
      : super(size: size, position: position, priority: 0) { // Set priority (zIndex)
    add(RectangleHitbox()); // Add hitbox for the crystal
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('crystal-50x71.png'); // Load crystal sprite
    debugMode = false; // Enables hitbox visualization for debugging
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Check collision with the player
    if (other is Player) {
      print('Crystal collected! Crystal coordinates: $position');
      removeFromParent(); // Remove crystal from the map
      (gameRef as BrdWorldGame).incrementScoreCrystal(); // Increment the score
    }
  }
}

class CrystalManager {
  final GameWorld gameWorld; // Reference to the game world
  final int numberOfCrystals; // Number of crystals to add
  final Random _random = Random(); // For generating random positions

  CrystalManager({required this.gameWorld, this.numberOfCrystals = 20});

  Future<void> distributeCrystals() async {
    int createdCrystals = 0; // Counter for created crystals

    for (int i = 0; i < numberOfCrystals; i++) {
      Vector2? position;

      // Attempts to find a suitable position
      for (int attempt = 0; attempt < 100; attempt++) {
        // Generate a random position within the world
        final potentialPosition = Vector2(
          _random.nextDouble() * gameWorld.size.x,
          _random.nextDouble() * gameWorld.size.y,
        );

        // Check if it doesn't overlap with collisions
        if (!_isCollidingCrystalsWithWorld(potentialPosition)) {
          position = potentialPosition;
          break;
        }
      }

      // If a position is found, create the crystal
      if (position != null) {
        final crystal = Crystal(
          position: position,
          size: Vector2(35, 50), // Crystal size
        );

        await gameWorld.add(crystal); // Add the crystal to the world
        createdCrystals++;

        print('Crystal created: $createdCrystals, Coordinates: x=${position.x}, y=${position.y}');
      } else {
        print('Failed to find a suitable position for the crystal');
      }
    }

    // Log the total number of crystals
    print('Total number of crystals: $createdCrystals');
  }

  // Check if the position overlaps with the world's collisions
  bool _isCollidingCrystalsWithWorld(Vector2 position) {
    var crystalSize = Vector2(50, 71); // Crystal size
    final crystalRect = Rect.fromLTWH(position.x, position.y, crystalSize.x, crystalSize.y);

    for (final rect in gameWorld.collisionRects) {
      final collisionRect = Rect.fromLTRB(
        rect['topLeft']!.x,
        rect['topLeft']!.y,
        rect['bottomRight']!.x,
        rect['bottomRight']!.y,
      );

      if (crystalRect.overlaps(collisionRect)) {
        return true; // Overlaps with an obstacle
      }
    }

    return false; // No overlap
  }
}
