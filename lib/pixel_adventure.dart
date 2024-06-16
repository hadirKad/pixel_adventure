import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';

import 'package:pixel_adventure/components/level.dart';

//pixel adventure extends flameGame to become game widget
class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        HasCollisionDetection {
  //change the background color
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  Player player = Player(character: "Mask Dude");
  late JoystickComponent joystick;
  bool showControls = true;
  List<String> levelNames = ["level_01", "level_01"];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    //load the game images in cache so we just call them when we need them
    /*if the game have a lot of image you can not use load all Images because is take
    to much time you just do load all ([]) and choose the most used images*/
    await images.loadAll([
      "Main Characters/Ninja Frog/Idle (32x32).png",
      "Main Characters/Ninja Frog/Run (32x32).png",
      "Main Characters/Ninja Frog/Jump (32x32).png",
      "Main Characters/Ninja Frog/Fall (32x32).png",
      "Main Characters/Ninja Frog/Hit (32x32).png",
      "Main Characters/Pink Man/Idle (32x32).png",
      "Main Characters/Pink Man/Run (32x32).png",
      "Main Characters/Pink Man/Jump (32x32).png",
      "Main Characters/Pink Man/Fall (32x32).png",
      "Main Characters/Pink Man/Hit (32x32).png",
      "Main Characters/Mask Dude/Idle (32x32).png",
      "Main Characters/Mask Dude/Run (32x32).png",
      "Main Characters/Mask Dude/Jump (32x32).png",
      "Main Characters/Mask Dude/Fall (32x32).png",
      "Main Characters/Mask Dude/Hit (32x32).png",
      "Main Characters/Appearing (96x96).png",
      "Main Characters/Desappearing (96x96).png",
      "Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png",
      "Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png",
      "Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png",
      "Background/Gray.png",
      "Items/Fruits/Apple.png",
      "Items/Fruits/Bananas.png",
      "Items/Fruits/Cherries.png",
      "Items/Fruits/Kiwi.png",
      "Items/Fruits/Orange.png",
      "Items/Fruits/Collected.png",
      "Traps/Saw/On (38x38).png",
      'HUD/Knob.png',
      'HUD/Joystick.png',
      'HUD/JumpButton.png'
    ]);

    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority:10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      //knobRadius: 62,
      background: SpriteComponent(
          sprite: Sprite(
        images.fromCache('HUD/Joystick.png'),
      )),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex = currentLevelIndex + 1;
      _loadLevel();
    } else {
      //no more levels
    }
  }

  void _loadLevel() {
    //we give it time to destroy everything and change level
    Future.delayed(const Duration(seconds: 1), () {
  
    
      //create level with player
      World world =
          Level(levelName: levelNames[currentLevelIndex], player: player);
      //create camera
      cam = CameraComponent.withFixedResolution(
          world: world, width: 640, height: 360);
      //we change cam position
      cam.viewfinder.anchor = Anchor.topLeft;
      //we add the level we actually can not see it cause the camera in not on it
      addAll([cam, world]);
      
    });
  }
}
