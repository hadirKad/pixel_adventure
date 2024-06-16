import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final bool isVertical;
  final double offNeg;
  final double offPos;
  Saw(
      {this.isVertical = false,
      this.offNeg = 0,
      this.offPos = 0,
      position,
      size})
      : super(position: position, size: size);

  static const double sawSpeed = 0.03;
  static const moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangNeg = 0;
  double rangPos = 0;

  @override
  FutureOr<void> onLoad() async {
    priority = -1;
    //we get lucky because our circle hit box fit our saw 
    add(CircleHitbox());
    debugMode = false;
    if (isVertical) {
      rangNeg = position.y + offNeg * tileSize;
      rangPos = position.y - offPos * tileSize;
    } else {
      rangNeg = position.x - offNeg * tileSize;
      rangPos = position.x + offPos * tileSize;
    }
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache("Traps/Saw/On (38x38).png"),
        SpriteAnimationData.sequenced(
            amount: 8, stepTime: sawSpeed, textureSize: Vector2.all(38)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }

    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangNeg) {
      moveDirection = -1;
    } else if (position.y <= rangPos) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
     if (position.x >= rangPos) {
      moveDirection = -1;
    } else if (position.x <= rangNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}
