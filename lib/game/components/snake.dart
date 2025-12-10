import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/direction.dart';
import '../utils/game_constant.dart';

class Snake extends Component {
  final double cellSize;
  final int boardWidth;
  final int boardHeight;

  List<Vector2> body = [];
  Direction direction = Direction.right;
  Direction? nextDirection;

  // Power-up states
  bool hasShield = false;
  bool hasSpeedBoost = false;
  bool hasDoublePoints = false;
  bool hasSlowMotion = false;

  // Animation
  double _animationTime = 0;
  final List<double> _segmentAnimationOffsets = [];

  Snake({
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  @override
  Future<void> onLoad() async {
    reset();
  }

  void changeDirection(Direction newDirection) {
    if (!direction.isOpposite(newDirection)) {
      nextDirection = newDirection;
    }
  }

  void move() {
    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }

    final head = body.first.clone();

    switch (direction) {
      case Direction.up:
        head.y -= 1;
        break;
      case Direction.down:
        head.y += 1;
        break;
      case Direction.left:
        head.x -= 1;
        break;
      case Direction.right:
        head.x += 1;
        break;
    }

    body.insert(0, head);
    body.removeLast();

    // Update animation offsets
    _segmentAnimationOffsets.insert(0, _animationTime);
    if (_segmentAnimationOffsets.length > body.length) {
      _segmentAnimationOffsets.removeLast();
    }
  }

  void grow() {
    final tail = body.last.clone();
    body.add(tail);
    _segmentAnimationOffsets.add(_animationTime);
  }

  bool checkCollision() {
    final head = body.first;

    // Wall collision
    if (head.x < 0 ||
        head.x >= boardWidth ||
        head.y < 0 ||
        head.y >= boardHeight) {
      // Shield protects from one collision
      if (hasShield) {
        hasShield = false;
        // Wrap around instead
        if (head.x < 0) head.x = boardWidth - 1;
        if (head.x >= boardWidth) head.x = 0;
        if (head.y < 0) head.y = boardHeight - 1;
        if (head.y >= boardHeight) head.y = 0;
        body[0] = head;
        return false;
      }
      return true;
    }

    // Self collision
    for (int i = 1; i < body.length; i++) {
      if (head.x == body[i].x && head.y == body[i].y) {
        if (hasShield) {
          hasShield = false;
          return false;
        }
        return true;
      }
    }

    return false;
  }

  bool isOnPosition(Vector2 position) {
    return body.any(
      (segment) => segment.x == position.x && segment.y == position.y,
    );
  }

  Vector2 get headPosition => body.first;

  @override
  void update(double dt) {
    _animationTime += dt;
  }

  @override
  void render(Canvas canvas) {
    for (int i = body.length - 1; i >= 0; i--) {
      final segment = body[i];
      final isHead = i == 0;

      // Calculate wave animation offset
      final waveOffset = sin((_animationTime * 3) + (i * 0.3)) * 1.5;

      // Calculate color based on position and power-ups
      Color baseColor;
      if (hasShield) {
        baseColor = Color.lerp(
          GameConstants.snakeShieldColor,
          GameConstants.snakeBodyColor,
          i / body.length,
        )!;
      } else if (hasSpeedBoost) {
        baseColor = Color.lerp(
          const Color(0xFFFF9800),
          const Color(0xFFFFE082),
          sin(_animationTime * 10) * 0.5 + 0.5,
        )!;
      } else {
        baseColor = isHead
            ? GameConstants.snakeHeadColor
            : Color.lerp(
                GameConstants.snakeBodyColor,
                GameConstants.snakeHeadColor,
                i / body.length,
              )!;
      }

      final paint = Paint()..color = baseColor;

      // Add glow effect for power-ups
      if (hasShield || hasSpeedBoost || hasDoublePoints) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

        final glowRect = Rect.fromLTWH(
          segment.x * cellSize + waveOffset,
          segment.y * cellSize + waveOffset,
          cellSize,
          cellSize,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(glowRect, const Radius.circular(6)),
          paint,
        );
        paint.maskFilter = null;
      }

      final rect = Rect.fromLTWH(
        segment.x * cellSize + 2 + waveOffset,
        segment.y * cellSize + 2,
        cellSize - 4,
        cellSize - 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(isHead ? 8 : 4)),
        paint,
      );

      // Draw eyes on head
      if (isHead) {
        _drawEyes(canvas, segment, waveOffset);
      }
    }
  }

  void _drawEyes(Canvas canvas, Vector2 headPos, double waveOffset) {
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    final pupilPaint = Paint()..color = const Color(0xFF000000);

    final eyeSize = cellSize * 0.2;
    final pupilSize = cellSize * 0.1;

    double leftEyeX, leftEyeY, rightEyeX, rightEyeY;

    final centerX = headPos.x * cellSize + cellSize / 2 + waveOffset;
    final centerY = headPos.y * cellSize + cellSize / 2;

    switch (direction) {
      case Direction.up:
        leftEyeX = centerX - cellSize * 0.2;
        rightEyeX = centerX + cellSize * 0.2;
        leftEyeY = rightEyeY = centerY - cellSize * 0.15;
        break;
      case Direction.down:
        leftEyeX = centerX - cellSize * 0.2;
        rightEyeX = centerX + cellSize * 0.2;
        leftEyeY = rightEyeY = centerY + cellSize * 0.15;
        break;
      case Direction.left:
        leftEyeX = rightEyeX = centerX - cellSize * 0.15;
        leftEyeY = centerY - cellSize * 0.2;
        rightEyeY = centerY + cellSize * 0.2;
        break;
      case Direction.right:
        leftEyeX = rightEyeX = centerX + cellSize * 0.15;
        leftEyeY = centerY - cellSize * 0.2;
        rightEyeY = centerY + cellSize * 0.2;
        break;
    }

    // Draw eyes
    canvas.drawCircle(Offset(leftEyeX, leftEyeY), eyeSize, eyePaint);
    canvas.drawCircle(Offset(rightEyeX, rightEyeY), eyeSize, eyePaint);

    // Draw pupils
    canvas.drawCircle(Offset(leftEyeX, leftEyeY), pupilSize, pupilPaint);
    canvas.drawCircle(Offset(rightEyeX, rightEyeY), pupilSize, pupilPaint);
  }

  void reset() {
    direction = Direction.right;
    nextDirection = null;
    hasShield = false;
    hasSpeedBoost = false;
    hasDoublePoints = false;
    hasSlowMotion = false;

    final startX = (boardWidth / 2).floor().toDouble();
    final startY = (boardHeight / 2).floor().toDouble();

    body = [
      Vector2(startX, startY),
      Vector2(startX - 1, startY),
      Vector2(startX - 2, startY),
    ];

    _segmentAnimationOffsets.clear();
    for (int i = 0; i < body.length; i++) {
      _segmentAnimationOffsets.add(0);
    }
  }
}
