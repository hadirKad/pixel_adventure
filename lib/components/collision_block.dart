import 'package:flame/components.dart';


//position component is a component that we can give him x , y and width and hight 
class CollisionBlock extends PositionComponent{

  //to check is the collision is a platform or not 
  bool isPlatform;
  //super is set the position and size to the component 
  CollisionBlock({position , size , this.isPlatform = false})
  :super( position: position , size: size){
    //if we set debug mode true we can see collision size and x y 
    debugMode = false;
  }

}