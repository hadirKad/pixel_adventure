import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

//put all the player state in enum so is will be easy to call them
enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  desappearing
}

/*group animation means that the player have to many animation and you need 
to switch between them*/
/*has game ref is to refrence the player with the game so we can use the component 
inside it */
class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  //get position and set the original position which is (0,0)
  final String character;
  Player({position, this.character = "Ninja Frog"}) : super(position: position);

  //animation var
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation desappearingAnimation;
  final double stepTime = 0.05;
  //gravity ver
  final double _gravity = 9.8;
  final double _jumbForce = 36;
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  bool reachedCheckpoint = false;
  //movement var
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CustomHitBox hitBox =
      CustomHitBox(offsetX: 10, offsetY: 4, width: 14, height: 20);
  Vector2 startingPosition = Vector2(0, 0);
  bool getHit = false;

  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimation();
    //to see player x ,y
    debugMode = false;
    //we get the start position to save it and make the player return to in it if he lose
    startingPosition = Vector2(position.x, position.y);
    //we use thr hitbox to change the size of player to the real size
    add(RectangleHitbox(
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!getHit && !reachedCheckpoint) {
      _updatePlayerState();
      //dt = delta time allow us to update the game
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }

    super.update(dt);
  }

  //we use key board controll in pc
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    //if is left -1 if right 1 none is 0
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Checkpoint && !reachedCheckpoint) _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  //function to create all animation
  void _loadAllAnimation() {
    //create animation based on image
    //the image are saved in cache in the game Pixel adventure that we add it in HasGameRef<PixelAdventure>
    //amount = number of item in animation image
    //stepTime = how fast the images changes
    idleAnimation = _spriteAnimation(11, "Idle");
    runAnimation = _spriteAnimation(12, "Run");
    jumpingAnimation = _spriteAnimation(1, "Jump");
    fallingAnimation = _spriteAnimation(1, "Fall");
    hitAnimation = _spriteAnimation(7, "Hit")..loop = false;
    appearingAnimation = _specialSpriteAnimation(7, "Appearing");
    desappearingAnimation = _specialSpriteAnimation(7, "Desappearing");

    //list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.desappearing: desappearingAnimation,
    };
    //set the current animation
    current = PlayerState.idle;
  }

  //function to create sprite animation
  SpriteAnimation _spriteAnimation(int amount, String state) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$character/$state (32x32).png"),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  //function to create some specific animation
  SpriteAnimation _specialSpriteAnimation(int amount, String state) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$state (96x96).png"),
        SpriteAnimationData.sequenced(
            amount: amount, 
            stepTime: stepTime, 
            textureSize: Vector2.all(96),
            loop: false));
  }

  //function that update player animation
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    //check if it face the right direction
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else {
      if (velocity.x > 0 && scale.x < 0) {
        flipHorizontallyAroundCenter();
      }
    }
    //check if moving  so we set runnning
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    //check if falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;
    //check if jumping set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  //function thet update player movement
  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);
    //if(velocity.y > _gravity) isOnGround = false;//optional
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumbForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  //function to check if we have collisions so the player stop
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      //handle collision in not platform case
      if (!block.isPlatform) {
        //we check if we have collision
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitBox.offsetX - hitBox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitBox.width + hitBox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    //add max and min value for velocity
    velocity.y = velocity.y.clamp(-_jumbForce, _terminalVelocity);
    position.y += velocity.y + dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      //handle collision in not platform case
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.height - hitBox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        //we check if we have collision
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.height - hitBox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y - block.height - hitBox.offsetY;
            break;
          }
        }
      }
    }
  }

  void _respawn() async {
    const canMoveDuration = Duration(microseconds: 4000);
    getHit = true;
    current = PlayerState.hit;
    //wait for our animation to complete
    await animationTicker?.completed;
    //reset everything
    animationTicker?.reset();
    //because the diffrent between player and animation size
    position = startingPosition - Vector2.all(96 - 64);
    //always fixing the right
    scale.x = 1;
    current = PlayerState.appearing;
    //wait for our animation to complete
    await animationTicker?.completed;
    //reset everything
    animationTicker?.reset();
    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    //we keep this when we need a specific time
    Future.delayed(canMoveDuration, () => getHit = false);
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.desappearing;
    const reachedCheckpointDuration = Duration(milliseconds: 30 * 7);
    Future.delayed(reachedCheckpointDuration, () {
      reachedCheckpoint = false;
      position = Vector2.all(-640);
      const waitToChangeDuration = Duration(seconds: 3);
      Future.delayed(waitToChangeDuration, () {
        game.loadNextLevel();
      });
    });
  }
}
