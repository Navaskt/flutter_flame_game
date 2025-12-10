import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/game_constant.dart';

class PowerUp extends Component {
  final double cellSize;
  final int boardWidth;
  final int boardHeight;

  Vector2 position = Vector2.zero();
  PowerUpType type = PowerUpType.speedBoost;
  bool isActive = false;
  double lifetime = 10.0; // Disappears after 10 seconds

  final Random _random = Random();
  double _animationTime = 0;

  PowerUp({
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  void spawn(bool Function(Vector2) isOccupied) {
    // Random position
    do {
      position = Vector2(
        _random.nextInt(boardWidth).toDouble(),
        _random.nextInt(boardHeight).toDouble(),
      );
    } while (isOccupied(position));

    // Random type
    type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];

    lifetime = 10.0;
    isActive = true;
    _animationTime = 0;
  }

  void deactivate() {
    isActive = false;
  }

  @override
  void update(double dt) {
    if (!isActive) return;

    _animationTime += dt;
    lifetime -= dt;

    if (lifetime <= 0) {
      isActive = false;
    }
  }

  Color get color {
    switch (type) {
      case PowerUpType.speedBoost:
        return const Color(0xFFFF9800); // Orange
      case PowerUpType.shield:
        return const Color(0xFF2196F3); // Blue
      case PowerUpType.doublePoints:
        return const Color(0xFFFFEB3B); // Yellow
      case PowerUpType.slowMotion:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  String get icon {
    switch (type) {
      case PowerUpType.speedBoost:
        return '⚡';
      case PowerUpType.shield:
        return '🛡️';
      case PowerUpType.doublePoints:
        return '×2';
      case PowerUpType.slowMotion:
        return '🐌';
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    final centerX = position.x * cellSize + cellSize / 2;
    final centerY = position.y * cellSize + cellSize / 2;
    final center = Offset(centerX, centerY);

    // Floating animation
    final floatOffset = sin(_animationTime * 3) * 3;
    final animatedCenter = Offset(centerX, centerY + floatOffset);

    // Rotation animation
    final rotation = _animationTime * 2;

    // Pulse when about to disappear
    double scale = 1.0;
    if (lifetime < 3) {
      scale = 0.8 + sin(_animationTime * 10) * 0.2;
    }

    final radius = (cellSize / 2 - 2) * scale;

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(animatedCenter, radius + 5, glowPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(animatedCenter, radius, ringPaint);

    // Inner circle
    final innerPaint = Paint()..color = color.withOpacity(0.3);
    canvas.drawCircle(animatedCenter, radius - 2, innerPaint);

    // Draw rotating particles around the power-up
    for (int i = 0; i < 4; i++) {
      final angle = rotation + (i * pi / 2);
      final particleX = centerX + cos(angle) * (radius + 8);
      final particleY = centerY + floatOffset + sin(angle) * (radius + 8);

      final particlePaint = Paint()..color = color.withOpacity(0.7);
      canvas.drawCircle(Offset(particleX, particleY), 2, particlePaint);
    }

    // Draw icon/text
    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: TextStyle(fontSize: cellSize * 0.5, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        animatedCenter.dx - textPainter.width / 2,
        animatedCenter.dy - textPainter.height / 2,
      ),
    );
  }
}
