import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'world_collidable.dart';

class GameWorld extends World with HasGameRef {
  late final SpriteComponent _background;

  // List of collision objects
  final List<Map<String, Vector2>> _collisionRects = [];

  @override
  Future<void> onLoad() async {
    print('Initializing GameWorld...');

    // Create background
    _background = SpriteComponent()
      ..sprite = await gameRef.loadSprite('world_background.png')
      ..size = Vector2(2400, 2400)
      ..position = Vector2.zero();

    print('World background created');
    add(_background);

    // Load collision map
    print('Loading collision map...');
    final collisionRects = await _loadCollisionMap('assets/world_collision_map.json');
    if (collisionRects.isEmpty) {
      print('Collision map not loaded or empty');
    } else {
      print('Collision map successfully loaded');
      _createCollisionObjects(collisionRects);
    }

    // Add coins
    

    print('GameWorld successfully initialized');
    super.onLoad();
  }

  Future<List<Map<String, Vector2>>> _loadCollisionMap(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final jsonData = json.decode(jsonString);

      return List<Map<String, Vector2>>.from(jsonData['objects'].map((obj) => {
            'topLeft': Vector2(obj['x'], obj['y']),
            'bottomRight': Vector2(obj['x'] + obj['width'], obj['y'] + obj['height']),
          }));
    } catch (e) {
      print('Error loading collision map: $e');
      return [];
    }
  }

  void _createCollisionObjects(List<Map<String, Vector2>> collisionRects) {
    for (final rect in collisionRects) {
      final topLeft = rect['topLeft']!;
      final bottomRight = rect['bottomRight']!;
      final size = bottomRight - topLeft;

      print('Creating WorldCollidable: position=$topLeft, size=$size');
      final obstacle = WorldCollidable(
        position: topLeft,
        size: size,
      )
        ..priority = 0;
      add(obstacle);
    }

    _collisionRects.addAll(collisionRects);
  }

  List<Map<String, Vector2>> get collisionRects => _collisionRects;

  Vector2 get size => _background.size;
}
