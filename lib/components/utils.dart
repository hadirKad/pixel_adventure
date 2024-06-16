bool checkCollision(player, block) {
  final hitbox = player.hitBox;
  //player
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;
  //block
  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  //block x in case of go right we need to fix it
  final fixeX = player.scale.x < 0 ? playerX - (hitbox.offsetX *2) - playerWidth : playerX;
  final fixeY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixeY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixeX < blockX + blockWidth &&
      fixeX + playerWidth > blockX);
}
