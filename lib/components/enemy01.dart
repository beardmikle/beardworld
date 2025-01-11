import 'dart:math';
import 'package:brdgame/components/world.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/sprite.dart';
import 'package:brdgame/helpers/direction.dart';
import 'package:flutter/material.dart';

class Enemy01 extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final double _animationSpeed = 0.15;
  final GameWorld gameWorld;

  late SpriteAnimation _runDownAnimation;
  late SpriteAnimation _runLeftAnimation;
  late SpriteAnimation _runUpAnimation;
  late SpriteAnimation _runRightAnimation;
  late SpriteAnimation _standingAnimation;

  Direction direction = Direction.none;
  final double _enemy01Speed = 100.0;
  final Random _random = Random();

  Vector2 _lastPosition = Vector2.zero();

  late TimerComponent _changeDirectionTimer;

  Enemy01({required this.gameWorld}) : super(size: Vector2.all(80.0), priority: 0) {
    // Set hitbox with smaller size
    final hitboxSize = Vector2(40, 40); // Hitbox size smaller than the sprite
    final hitboxOffset = (size - hitboxSize) / 2; // Center the hitbox relative to the sprite

    add(RectangleHitbox(
      position: hitboxOffset,
      size: hitboxSize,
    ));

    debugMode = false; // For hitbox debugging
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimations();
    animation = _standingAnimation;
    _lastPosition = position.clone();

    // Add timer for direction change
    _addChangeDirectionTimer();
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('enemy01_spritesheet.png'),
      srcSize: Vector2(32.0, 32.0),
    );

    _runDownAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 5);

    _runLeftAnimation =
        spriteSheet.createAnimation(row: 1, stepTime: _animationSpeed, to: 5);

    _runRightAnimation =
        spriteSheet.createAnimation(row: 2, stepTime: _animationSpeed, to: 5);

    _runUpAnimation =
        spriteSheet.createAnimation(row: 3, stepTime: _animationSpeed, to: 5);

    _standingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 1);
  }

  @override
  void update(double delta) {
    super.update(delta);

    // Enemy movement
    moveEnemy01(delta);

    // Check collision with map objects
    _checkCollisionWithCollidableMap();

    // Update saved position
    _lastPosition = position.clone();
  }

 void moveEnemy01(double delta) {
  final previousPosition = position.clone();

  switch (direction) {
    case Direction.up:
      animation = _runUpAnimation;
      position.add(Vector2(0, delta * -_enemy01Speed));
      break;
    case Direction.down:
      animation = _runDownAnimation;
      position.add(Vector2(0, delta * _enemy01Speed));
      break;
    case Direction.left:
      animation = _runLeftAnimation;
      position.add(Vector2(delta * -_enemy01Speed, 0));
      break;
    case Direction.right:
      animation = _runRightAnimation;
      position.add(Vector2(delta * _enemy01Speed, 0));
      break;
    case Direction.none:
      animation = _standingAnimation;
      return;
  }

  if (_isCollidingWithWorld()) {
    // If a collision occurs, revert the enemy to its previous position
    position.setFrom(previousPosition);
    _changeDirection(); // Change direction
  }
}

bool _isCollidingWithWorld() {
  final enemyRect = Rect.fromLTWH(position.x, position.y, size.x, size.y);

  for (final rect in gameWorld.collisionRects) {
    final collisionRect = Rect.fromLTRB(
      rect['topLeft']!.x,
      rect['topLeft']!.y,
      rect['bottomRight']!.x,
      rect['bottomRight']!.y,
    );

    if (enemyRect.overlaps(collisionRect)) {
      return true;
    }
  }

  return false;
}

  void _checkCollisionWithCollidableMap() {
    final collisionRects = gameWorld.collisionRects;

    for (final rect in collisionRects) {
      final rectTopLeft = rect['topLeft']!;
      final rectBottomRight = rect['bottomRight']!;
      final isColliding = _isCollidingWithRectangle(rectTopLeft, rectBottomRight);

      if (isColliding) {
        // If a collision occurs, revert the enemy to its previous position
        position = _lastPosition.clone();
        _changeDirection(); // Change direction upon collision
        return;
      }
    }
  }

  bool _isCollidingWithRectangle(Vector2 rectTopLeft, Vector2 rectBottomRight) {
    final enemy01TopLeft = position;
    final enemy01BottomRight = position + size;

    return !(enemy01BottomRight.x <= rectTopLeft.x || // Enemy is to the left of the rectangle
        enemy01TopLeft.x >= rectBottomRight.x || // Enemy is to the right of the rectangle
        enemy01BottomRight.y <= rectTopLeft.y || // Enemy is above the rectangle
        enemy01TopLeft.y >= rectBottomRight.y); // Enemy is below the rectangle
  }

  void _addChangeDirectionTimer() {
    _changeDirectionTimer = TimerComponent(
      period: 2.0, // Interval in seconds
      repeat: true,
      onTick: () => _changeDirection(),
    );
    add(_changeDirectionTimer); // Add the timer as a child component
  }

  void _changeDirection() {
    // Generate a random direction
    final directions = Direction.values.where((d) => d != Direction.none).toList();
    direction = directions[_random.nextInt(directions.length)];
  }
}


class EnemyManager {
  final GameWorld gameWorld; // Reference to the world
  final int numberOfEnemies; // Number of enemies to add
  final Random _random = Random(); // For generating random positions

  EnemyManager({required this.gameWorld, this.numberOfEnemies = 10});

  Future<void> distributeEnemies() async {
    int createdEnemies = 0; // Counter for created enemies

    for (int i = 0; i < numberOfEnemies; i++) {
      Vector2? position;

      // Attempts to find a suitable position
      for (int attempt = 0; attempt < 100; attempt++) {
        // Generate a random position within the world
        final potentialPosition = Vector2(
          _random.nextDouble() * gameWorld.size.x,
          _random.nextDouble() * gameWorld.size.y,
        );

        // Check if it does not overlap with collisions
        if (!_isCollidingWithWorld(potentialPosition)) {
          position = potentialPosition;
          break;
        }
      }

      // If a position is found, create an enemy
      if (position != null) {
        final enemy = Enemy01(gameWorld: gameWorld)
          ..position = position; // Set the enemy's position

        await gameWorld.add(enemy); // Add the enemy to the world
        createdEnemies++;

        print('Enemy created: $createdEnemies, Coordinates: x=${position.x}, y=${position.y}');
      } else {
        print('Could not find a suitable position for the enemy');
      }
    }

    // Log the total number of enemies
    print('Total number of enemies: $createdEnemies');
  }

  // Check if the position overlaps with world collisions
  bool _isCollidingWithWorld(Vector2 position) {
    var enemySize = Vector2(80, 80); // Enemy size
    final enemyRect = Rect.fromLTWH(position.x, position.y, enemySize.x, enemySize.y);

    for (final rect in gameWorld.collisionRects) {
      final collisionRect = Rect.fromLTRB(
        rect['topLeft']!.x,
        rect['topLeft']!.y,
        rect['bottomRight']!.x,
        rect['bottomRight']!.y,
      );

      if (enemyRect.overlaps(collisionRect)) {
        return true; // Overlaps with an obstacle
      }
    }

    return false; // No overlaps
  }
}
