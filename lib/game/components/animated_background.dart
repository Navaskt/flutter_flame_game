import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/game_constant.dart';

class BackgroundStar {
  Vector2 position;
  double size;
  double twinkleSpeed;
  double twinkleOffset;

  BackgroundStar({
    required this.position,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class AnimatedBackground extends Component {
  final double width;
  final double height;
  final double cellSize;
  final int boardWidth;
  final int boardHeight;

  final List<BackgroundStar> _stars = [];
  final Random _random = Random();
  double _time = 0;

  AnimatedBackground({
    required this.width,
    required this.height,
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  @override
  Future<void> onLoad() async {
    // Create stars
    for (int i = 0; i < 50; i++) {
      _stars.add(
        BackgroundStar(
          position: Vector2(
            _random.nextDouble() * width,
            _random.nextDouble() * height,
          ),
          size: 1 + _random.nextDouble() * 2,
          twinkleSpeed: 1 + _random.nextDouble() * 3,
          twinkleOffset: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // Gradient background
    final bgRect = Rect.fromLTWH(0, 0, width, height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        GameConstants.backgroundColor,
        const Color(0xFF0A2A0D),
        const Color(0xFF051A07),
      ],
    );

    final bgPaint = Paint()..shader = gradient.createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Draw twinkling stars
    for (final star in _stars) {
      final twinkle = sin(_time * star.twinkleSpeed + star.twinkleOffset);
      final opacity = 0.3 + twinkle * 0.3;

      final starPaint = Paint()
        ..color = Color(0xFFFFFFFF).withOpacity(opacity.clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(star.position.x, star.position.y),
        star.size,
        starPaint,
      );
    }

    // Draw grid
    final gridPaint = Paint()
      ..color = GameConstants.gridColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int x = 0; x <= boardWidth; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, boardHeight * cellSize),
        gridPaint,
      );
    }

    for (int y = 0; y <= boardHeight; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(boardWidth * cellSize, y * cellSize),
        gridPaint,
      );
    }

    // Draw border glow
    final borderPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, boardWidth * cellSize, boardHeight * cellSize),
      borderPaint,
    );
  }
}
