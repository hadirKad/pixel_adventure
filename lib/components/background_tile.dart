import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

//sprite component let us add an image
class BackgroundTile extends ParallaxComponent {

  final String color ;
  BackgroundTile({this.color = "Gray" , position}): super(position: position);
  final double scrollSpeed = 0.4 ;

   @override
     FutureOr<void> onLoad() async{
      //make background in the back always
      priority = -10 ;
      size = Vector2.all(64);
      parallax = await game.loadParallax(
        [ ParallaxImageData("Background/$color.png"),],
        baseVelocity: Vector2(0, -scrollSpeed),
        repeat: ImageRepeat.repeat,
        fill: LayerFill.none);
      return super.onLoad();
   }
}