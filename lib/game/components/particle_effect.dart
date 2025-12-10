import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

class Particle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double lifetime;
  double maxLifetime;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
  }) : maxLifetime = lifetime;

  void update(double dt) {
    position += velocity * dt;
    velocity.y += 100 * dt; // Gravity
    lifetime -= dt;
  }

  bool get isDead => lifetime <= 0;

  double get opacity => (lifetime / maxLifetime).clamp(0.0, 1.0);
}

class ParticleEffect extends Component {
  final List<Particle> _particles = [];
  final Random _random = Random();

  void emit({
    required Vector2 position,
    required Color color,
    int count = 10,
    double speed = 100,
    double size = 4,
    double lifetime = 0.5,
  }) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = Vector2(
        cos(angle) * speed * (0.5 + _random.nextDouble()),
        sin(angle) * speed * (0.5 + _random.nextDouble()),
      );

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: velocity,
          color: color,
          size: size * (0.5 + _random.nextDouble()),
          lifetime: lifetime * (0.5 + _random.nextDouble()),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    for (final particle in _particles) {
      particle.update(dt);
    }
    _particles.removeWhere((p) => p.isDead);
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity);

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size * particle.opacity,
        paint,
      );
    }
  }
}
