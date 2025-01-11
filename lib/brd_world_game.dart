import 'package:brdgame/components/enemy01.dart';
import 'package:brdgame/components/world_collidable.dart';
import 'package:brdgame/gameoveroverlay.dart';
import 'package:brdgame/helpers/map_loader.dart';
import 'package:brdgame/helpers/keyeventresult.dart' as my;
import 'package:brdgame/main_game_page.dart';
import 'package:brdgame/main_menu.dart';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/src/experimental/geometry/shapes/rectangle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/player.dart';
import 'components/world.dart';
import 'helpers/direction.dart';
import 'package:flame/input.dart'; // keyboard control
import 'package:brdgame/components/coin_distribution.dart';
import 'package:brdgame/components/rubin_distribution.dart';
import 'package:brdgame/components/crystal_distribution.dart';

class BrdWorldGame extends FlameGame with KeyboardEvents {
  late final CameraComponent _camera; // Camera
  final GameWorld _world = GameWorld(); // Game world
  late final Player _player; // Player
  CoinManager? _coinManager; // Coin manager
  RubinManager? _rubinManager; // Rubin manager
  CrystalManager? _crystalManager; // Crystal manager
  late final EnemyManager _enemyManager; // Enemy manager

  late final my.KeyboardHandler _keyboardHandler; // Keyboard handler

  bool isPaused = true; // Pause status

  void togglePause() {
    isPaused = !isPaused;
    paused = isPaused; // Manage game loop state
  }

  int _scoreCoins = 0; // Coin score
  int _scoreRubins = 0; // Rubin score
  int _scoreCrystals = 0; // Crystal score

  int _lives = 5; // Initial number of lives
  bool _isInvincible = false; // Invincibility state flag

  // Callback to notify about life changes
  void Function(int remainingLives)? onLivesChanged;

  void decrementLives() {
    if (_isInvincible) return;

    if (_lives > 0) {
      _lives--;
      _isInvincible = true;
      print('Lives decreased: $_lives');
      onLivesChanged?.call(_lives);

      Future.delayed(const Duration(seconds: 3), () {
        _isInvincible = false;
        print('Invincibility removed.');
      });
    }

    if (_lives == 0) {
      print('Game Over!');
      // Delay adding the overlay to avoid setState during build phase
      Future.microtask(() {
        overlays.add('GameOver');
      });
    }
  }

  // Getter to retrieve the total number of coins
  int get totalCoins => _coinManager?.numberOfCoins ?? 0;
  int get totalRubins => _rubinManager?.numberOfRubins ?? 0;
  int get totalCrystal => _crystalManager?.numberOfCrystals ?? 0;

  // Callback to notify about score changes
  void Function(int collectedCoins, int totalCoins)? onScoreChangedCoins;
  void Function(int collectedRubins, int totalRubins)? onScoreChangedRubins;
  void Function(int collectedCrystal, int totalCrystal)? onScoreChangedCrystals;

  // Increase score
  void incrementScoreCoin() {
    _scoreCoins++;
    print('Score updated for coins in incrementScoreCoin: $_scoreCoins');
    onScoreChangedCoins?.call(_scoreCoins, totalCoins);
  }

  void incrementScoreRubins() {
    _scoreRubins++;
    print('Score updated for rubins in incrementScoreRubins: $_scoreRubins');
    onScoreChangedRubins?.call(_scoreRubins, totalRubins);
  }

  void incrementScoreCrystal() {
    _scoreCrystals++;
    print('Score updated for crystals in incrementScoreCrystal: $_scoreCrystals');
    onScoreChangedCrystals?.call(_scoreCrystals, totalCrystal);
  }

  void addWorldCollision() async {
    final collisionRects = await MapLoader.readBrdWorldCollisionMap();
    for (final rect in collisionRects) {
      final worldCollidable = WorldCollidable(
        position: Vector2(rect.left, rect.top),
        size: Vector2(rect.width, rect.height),
      );
      add(worldCollidable);
    }
  }

  @override
  Future<void> onLoad() async {
    // Add overlays
    overlays.addEntry(
      'GameOver',
      (context, game) => GameOverOverlay(
        onNewGame: () {
          overlays.remove('GameOver');
          game.overlays.clear(); // Ensure overlays are reset
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainGamePage()),
          );
        },
        onMainMenu: () {
          overlays.remove('GameOver');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
        },
      ),
    );

    await super.onLoad();

    // Add the world to the game
    await add(_world);

    // Create the player
    _player = Player(gameWorld: _world);

    // Set the player's initial position
    _player.position = _world.size / 2; // Center of the map
    await _world.add(_player); // Add the player to the world

    addWorldCollision(); // Add world collisions

    // Initialize the keyboard handler after creating the player
    _keyboardHandler = my.KeyboardHandler(_player);

    // Create the camera
    _camera = CameraComponent(
      world: _world,
      viewport: MaxViewport(), // Camera adapts to the screen
    );

    // Set up camera behavior
    _camera.viewfinder.add(
      FollowBehavior(
        target: _player, // Camera follows the player
        owner: _camera.viewfinder,
      ),
    );

    // Restrict camera movement to the map boundaries
    _camera.viewfinder.add(
      BoundedPositionBehavior(
        bounds: Rectangle.fromLTRB(
          220, // Left boundary
          465, // Top boundary
          2620, // Right boundary (considering screen width)
          1935, // Bottom boundary (considering screen height)
        ),
      ),
    );

    // Add the camera to the game
    add(_camera);

    // Initialize managers
    _enemyManager = EnemyManager(gameWorld: _world, numberOfEnemies: 10);
    _coinManager = CoinManager(gameWorld: _world, numberOfCoins: 20);
    _rubinManager = RubinManager(gameWorld: _world, numberOfRubins: 15);
    _crystalManager = CrystalManager(gameWorld: _world, numberOfCrystals: 6);

    // Distribute coins and enemies
    await _enemyManager.distributeEnemies();
    await _coinManager?.distributeCoins();
    await _rubinManager?.distributeRubins();
    await _crystalManager?.distributeCrystals();
  }

  // Method to handle player movement
  void onJoypadDirectionChanged(Direction direction) {
    _player.direction = direction;
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return _keyboardHandler.handleKeyboardInput(event, keysPressed);
  }
}
