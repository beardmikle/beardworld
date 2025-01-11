import 'package:brdgame/components/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class WorldCollidable extends PositionComponent with CollisionCallbacks {
  WorldCollidable({required Vector2 position, required Vector2 size})
      : super(priority: 0) { // Set priority to 0
    this.position = position;
    this.size = size;
    add(RectangleHitbox());
    debugMode = false; // Enables hitbox rendering
  }

  set zIndex(int zIndex) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print('WorldCollidable zIndex: $priority'); // Log collision zIndex
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // If this is a collision with the player
    if (other is Player) {
      print('Player collided with a WorldCollidable object!');
      // You can return the player back or handle other logic here.
    } else {
      print('WorldCollidable collided with ${other.runtimeType}');
    }
  }
}
