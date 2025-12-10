import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../utils/game_constant.dart';

class Food extends Component {
  final double cellSize;
  final int boardWidth;
  final int boardHeight;

  Vector2 position = Vector2.zero();
  final Random _random = Random();
  double _animationTime = 0;
  double _pulseScale = 1.0;

  Food({
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  void spawn(bool Function(Vector2) isOccupied) {
    do {
      position = Vector2(
        _random.nextInt(boardWidth).toDouble(),
        _random.nextInt(boardHeight).toDouble(),
      );
    } while (isOccupied(position));
  }

  @override
  void update(double dt) {
    _animationTime += dt;
    _pulseScale = 1.0 + sin(_animationTime * 4) * 0.15;
  }

  @override
  void render(Canvas canvas) {
    final centerX = position.x * cellSize + cellSize / 2;
    final centerY = position.y * cellSize + cellSize / 2;
    final center = Offset(centerX, centerY);
    final radius = (cellSize / 2 - 3) * _pulseScale;

    // Glow effect
    final glowPaint = Paint()
      ..color = GameConstants.foodColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Main food (apple shape)
    final applePaint = Paint()..color = GameConstants.foodColor;
    canvas.drawCircle(center, radius, applePaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = const Color(0xFFFF8A80)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.3),
      radius * 0.3,
      highlightPaint,
    );

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX, centerY - radius),
      Offset(centerX + 2, centerY - radius - 4),
      stemPaint,
    );

    // Leaf
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    final leafPath = Path()
      ..moveTo(centerX + 2, centerY - radius - 3)
      ..quadraticBezierTo(
        centerX + 8,
        centerY - radius - 8,
        centerX + 6,
        centerY - radius - 2,
      )
      ..close();
    canvas.drawPath(leafPath, leafPaint);
  }
}
