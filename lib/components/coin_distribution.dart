import 'package:brdgame/components/player.dart';
import 'package:brdgame/components/world.dart';
import 'package:brdgame/brd_world_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class Coin extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Coin({required Vector2 position, required Vector2 size})
      : super(size: size, position: position, priority: 0) { // Set priority (zIndex)
    add(RectangleHitbox()); // Add hitbox for the coin
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('coins-40x40.png'); // Load coin sprite
    debugMode = false; // Enables hitbox visualization for debugging
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Check collision with the player
    if (other is Player) {
      print('Coin collected! Coin coordinates: $position');
      removeFromParent(); // Remove coin from the map
      (gameRef as BrdWorldGame).incrementScoreCoin(); // Increment the score
    }
  }
}

class CoinManager {
  final GameWorld gameWorld; // Reference to the game world
  final int numberOfCoins; // Number of coins to add
  final Random _random = Random(); // For generating random positions

  CoinManager({required this.gameWorld, this.numberOfCoins = 20});

  Future<void> distributeCoins() async {
    int createdCoins = 0; // Counter for created coins

    for (int i = 0; i < numberOfCoins; i++) {
      Vector2? position;

      // Attempts to find a suitable position
      for (int attempt = 0; attempt < 100; attempt++) {
        // Generate a random position within the world
        final potentialPosition = Vector2(
          _random.nextDouble() * gameWorld.size.x,
          _random.nextDouble() * gameWorld.size.y,
        );

        // Check if it doesn't overlap with collisions
        if (!_isCollidingCoinsWithWorld(potentialPosition)) {
          position = potentialPosition;
          break;
        }
      }

      // If a position is found, create the coin
      if (position != null) {
        final coin = Coin(
          position: position,
          size: Vector2(40, 40), // Coin size
        );

        await gameWorld.add(coin); // Add the coin to the world
        createdCoins++;

        print('Coin created: $createdCoins, Coordinates: x=${position.x}, y=${position.y}');
      } else {
        print('Failed to find a suitable position for the coin');
      }
    }

    // Log the total number of coins
    print('Total number of coins: $createdCoins');
  }

  // Check if the position overlaps with the world's collisions
  bool _isCollidingCoinsWithWorld(Vector2 position) {
    var coinSize = Vector2(40, 40); // Coin size
    final coinRect = Rect.fromLTWH(position.x, position.y, coinSize.x, coinSize.y);

    for (final rect in gameWorld.collisionRects) {
      final collisionRect = Rect.fromLTRB(
        rect['topLeft']!.x,
        rect['topLeft']!.y,
        rect['bottomRight']!.x,
        rect['bottomRight']!.y,
      );

      if (coinRect.overlaps(collisionRect)) {
        return true; // Overlaps with an obstacle
      }
    }

    return false; // No overlap
  }
}
