import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async{
  //waiting for fluter to initialized
  WidgetsFlutterBinding.ensureInitialized();
  //make the game full screen 
  await Flame.device.fullScreen();
  //make the phone horizontal
  await Flame.device.setLandscape();
  //game widget is waiting for the game that it will be run
  //the game is  class that extends flameGame in our case PixelAdventure class
  PixelAdventure game = PixelAdventure();
  //when we are in debug mode we want the game to restare every time Which is not good in real env
  runApp( GameWidget(game:  kDebugMode ? PixelAdventure() : game,) );
}
