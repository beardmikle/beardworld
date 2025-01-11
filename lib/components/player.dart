import 'dart:ui';

import 'package:brdgame/components/coin_distribution.dart';
import 'package:brdgame/components/crystal_distribution.dart';
import 'package:brdgame/components/rubin_distribution.dart';
import 'package:brdgame/components/enemy01.dart';
import 'package:brdgame/components/world.dart';
import 'package:brdgame/brd_world_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../helpers/direction.dart';

class Player extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final double _animationSpeed = 0.15;
  final GameWorld gameWorld; // Reference to `GameWorld`

  late SpriteAnimation _runDownAnimation;
  late SpriteAnimation _runLeftAnimation;
  late SpriteAnimation _runUpAnimation;
  late SpriteAnimation _runRightAnimation;
  late SpriteAnimation _standingAnimation;

  Direction direction = Direction.none;
  final bool _isInsideCollidableArea = false; // Flag for state of intersection with the map
  final double _playerSpeed = 300.0;

  Vector2 _lastPosition = Vector2.zero();

  Player({required this.gameWorld}) : super(size: Vector2.all(50.0), priority: 0) {
    add(RectangleHitbox());
    debugMode = false; // Enables hitbox rendering
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimations();
    animation = _standingAnimation;
    _lastPosition = position.clone();
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('player_spritesheet.png'),
      srcSize: Vector2(29.0, 32.0),
    );

    _runDownAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 4);

    _runLeftAnimation =
        spriteSheet.createAnimation(row: 1, stepTime: _animationSpeed, to: 4);

    _runUpAnimation =
        spriteSheet.createAnimation(row: 2, stepTime: _animationSpeed, to: 4);

    _runRightAnimation =
        spriteSheet.createAnimation(row: 3, stepTime: _animationSpeed, to: 4);

    _standingAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 1);
  }

  @override
  void update(double delta) {
    super.update(delta);

    // Player movement
    movePlayer(delta);

    // Check for collision with the collision map
    _checkCollisionWithCollidableMap();
    
    // Update the saved position
    _lastPosition = position.clone();
  }

  void _checkCollisionWithCollidableMap() {
    final collisionRects = gameWorld.collisionRects;

    // Check collision with map objects
    for (final rect in collisionRects) {
      final rectTopLeft = rect['topLeft']!;
      final rectBottomRight = rect['bottomRight']!;
      final isColliding = _isCollidingWithRectangle(rectTopLeft, rectBottomRight);

      if (isColliding) {
        print(
            'Player is trying to enter a collision map area: [$rectTopLeft, $rectBottomRight]. Player position: $position');
        // Revert the player to the previous position to block entry
        position = _lastPosition.clone();
        return; // Interrupt the check as the player is already blocked
      }
    }

    // Check collision with coins
    for (final coin in gameWorld.children.whereType<Coin>()) {
      final playerRect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
      final coinRect = Rect.fromLTWH(coin.position.x, coin.position.y, coin.size.x, coin.size.y);

      if (playerRect.overlaps(coinRect)) {
        print('Coin collected! Coordinates: ${coin.position}');
        coin.removeFromParent(); // Remove the coin
        (gameRef as BrdWorldGame).incrementScoreCoin(); // Increment the score
      }
    }

    // Check collision with rubies
    for (final rubin in gameWorld.children.whereType<Rubin>()) { // Changed to Rubin
      final playerRect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
      final rubinRect = Rect.fromLTWH(rubin.position.x, rubin.position.y, rubin.size.x, rubin.size.y);

      if (playerRect.overlaps(rubinRect)) {
        print('Ruby collected!! Coordinates: ${rubin.position}');
        rubin.removeFromParent(); // Remove the ruby
        (gameRef as BrdWorldGame).incrementScoreRubins(); // Increment the score
      }
    }

   // Check collision with crystals
    for (final crystal in gameWorld.children.whereType<Crystal>()) { // Changed to Crystal
      final playerRect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
      final crystalRect = Rect.fromLTWH(crystal.position.x, crystal.position.y, crystal.size.x, crystal.size.y);

      if (playerRect.overlaps(crystalRect)) {
        print('Crystal collected!! Coordinates: ${crystal.position}');
        crystal.removeFromParent(); // Remove the crystal
        (gameRef as BrdWorldGame).incrementScoreCrystal(); // Increment the score
      }
    }

    // Check collision with enemies
    for (final enemy in gameWorld.children.whereType<Enemy01>()) {
      // Get the hitboxes of the player and the enemy
      final playerHitbox = RectangleComponent(
        position: position + size / 4, // Offset for considering a smaller hitbox
        size: size / 2, // Size of the player's hitbox
      ).toRect();

      final enemyHitbox = RectangleComponent(
        position: enemy.position + (enemy.size - Vector2(40, 40)) / 2, // Enemy offset
        size: Vector2(40, 40), // Enemy's hitbox size
      ).toRect();

      if (playerHitbox.overlaps(enemyHitbox)) {
        print('Player collided with an enemy! Enemy coordinates: ${enemy.position}');
        (gameRef as BrdWorldGame).decrementLives(); // Decrease lives
        position = _lastPosition.clone(); // Push the player back
        return;
      }
    }
  }

  bool _isCollidingWithRectangle(Vector2 rectTopLeft, Vector2 rectBottomRight) {
    final playerTopLeft = position; // Top-left corner of the player's hitbox
    final playerBottomRight = position + size; // Bottom-right corner of the player's hitbox

    return !(playerBottomRight.x <= rectTopLeft.x || // Player is left of the rectangle
        playerTopLeft.x >= rectBottomRight.x || // Player is right of the rectangle
        playerBottomRight.y <= rectTopLeft.y || // Player is above the rectangle
        playerTopLeft.y >= rectBottomRight.y); // Player is below the rectangle
  }

  void movePlayer(double delta) {
    switch (direction) {
      case Direction.up:
        animation = _runUpAnimation;
        position.add(Vector2(0, delta * -_playerSpeed));
        break;
      case Direction.down:
        animation = _runDownAnimation;
        position.add(Vector2(0, delta * _playerSpeed));
        break;
      case Direction.left:
        animation = _runLeftAnimation;
        position.add(Vector2(delta * -_playerSpeed, 0));
        break;
      case Direction.right:
        animation = _runRightAnimation;
        position.add(Vector2(delta * _playerSpeed, 0));
        break;
      case Direction.none:
        animation = _standingAnimation;
        break;
    }
  }
}
