enum Direction { up, down, left, right }

extension DirectionExtension on Direction {
  bool isOpposite(Direction other) {
    switch (this) {
      case Direction.up:
        return other == Direction.up;
      case Direction.down:
        return other == Direction.down;
      case Direction.left:
        return other == Direction.left;
      case Direction.right:
        return other == Direction.right;
    }
  }

  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.up;
      case Direction.down:
        return Direction.down;
      case Direction.left:
        return Direction.left;
      case Direction.right:
        return Direction.right;
    }
  }
}
