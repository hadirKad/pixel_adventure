import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

import 'background_tile.dart';
import 'player.dart';

//each level is a world so you need to extends
class Level extends World with HasGameRef<PixelAdventure> {
  // we send the name of level
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  // the level is a tiledComponent
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    //we load the level with filename and destTileSize
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    //we just create the level and now we need to add it to the game
    add(level);
    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue("BackgroundColor");
      final backgroundTile = BackgroundTile(
          color: backgroundColor ?? 'Gray', position: Vector2(0, 0));

      add(backgroundTile);
    }
  }

  void _spawningObjects() {
    /* get the spawn points layer with type object group and name Spawnpoints
    if spawnPointLayer in null the game will stop so we need to check i */

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      //loop in the layer oject and when we found player w add it there
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            //we put the character in the same spawn point x and y
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x  = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height),
                isVertical: isVertical,
                offNeg: offNeg,
                offPos: offPos);
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }
    //afer we add all collision we add them to player so he know him
    player.collisionBlocks = collisionBlocks;
  }
}
