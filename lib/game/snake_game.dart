import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/snake.dart';
import 'components/food.dart';
import 'components/power_up.dart';
import 'components/particle_effect.dart';
import 'components/animated_background.dart';
import 'utils/direction.dart';
import 'utils/game_constant.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';

class SnakeGame extends FlameGame
    with KeyboardEvents, PanDetector, HasCollisionDetection {
  final Difficulty difficulty;
  final Function(int score)? onScoreChanged;
  final Function(Map<PowerUpType, double> activePowerUps)? onPowerUpsChanged;
  final VoidCallback? onGameOver;

  late double cellSize;
  late Snake snake;
  late Food food;
  late PowerUp powerUp;
  late ParticleEffect particles;
  late AnimatedBackground background;

  int score = 0;
  double moveTimer = 0;
  late double baseSpeed;
  double currentSpeed = 0;
  bool isGameOver = false;
  bool isPaused = false;

  // Power-up timers
  Map<PowerUpType, double> activePowerUps = {};
  double powerUpSpawnTimer = 0;
  final Random _random = Random();

  SnakeGame({
    this.difficulty = Difficulty.medium,
    this.onScoreChanged,
    this.onPowerUpsChanged,
    this.onGameOver,
  });

  @override
  Future<void> onLoad() async {
    baseSpeed = GameConstants.difficultySpeed[difficulty]!;
    currentSpeed = baseSpeed;
    cellSize = size.x / GameConstants.boardWidth;

    // Add background first
    background = AnimatedBackground(
      width: size.x,
      height: size.y,
      cellSize: cellSize,
      boardWidth: GameConstants.boardWidth,
      boardHeight: GameConstants.boardHeight,
    );
    await add(background);

    // Add particles
    particles = ParticleEffect();
    await add(particles);

    // Add snake
    snake = Snake(
      cellSize: cellSize,
      boardWidth: GameConstants.boardWidth,
      boardHeight: GameConstants.boardHeight,
    );
    await add(snake);

    // Add food
    food = Food(
      cellSize: cellSize,
      boardWidth: GameConstants.boardWidth,
      boardHeight: GameConstants.boardHeight,
    );
    await add(food);
    food.spawn((pos) => snake.isOnPosition(pos));

    // Add power-up
    powerUp = PowerUp(
      cellSize: cellSize,
      boardWidth: GameConstants.boardWidth,
      boardHeight: GameConstants.boardHeight,
    );
    await add(powerUp);

    // Start background music
    await AudioService.startBackgroundMusic();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver || isPaused) return;

    // Update power-up timers
    _updatePowerUps(dt);

    // Power-up spawn logic
    powerUpSpawnTimer += dt;
    if (powerUpSpawnTimer >= 8 && !powerUp.isActive) {
      if (_random.nextDouble() < GameConstants.powerUpSpawnChance) {
        powerUp.spawn(
          (pos) =>
              snake.isOnPosition(pos) ||
              (pos.x == food.position.x && pos.y == food.position.y),
        );
      }
      powerUpSpawnTimer = 0;
    }

    moveTimer += dt;

    if (moveTimer >= currentSpeed) {
      moveTimer = 0;
      snake.move();

      // Check food collision
      if (snake.headPosition.x == food.position.x &&
          snake.headPosition.y == food.position.y) {
        _onFoodEaten();
      }

      // Check power-up collision
      if (powerUp.isActive &&
          snake.headPosition.x == powerUp.position.x &&
          snake.headPosition.y == powerUp.position.y) {
        _onPowerUpCollected();
      }

      // Check game over
      if (snake.checkCollision()) {
        _triggerGameOver();
      }
    }
  }

  void _onFoodEaten() {
    snake.grow();

    int points = GameConstants.foodPoints;
    if (snake.hasDoublePoints) {
      points *= 2;
    }
    score += points;
    onScoreChanged?.call(score);

    // Emit particles
    particles.emit(
      position: Vector2(
        food.position.x * cellSize + cellSize / 2,
        food.position.y * cellSize + cellSize / 2,
      ),
      color: GameConstants.foodColor,
      count: 15,
    );

    food.spawn(
      (pos) =>
          snake.isOnPosition(pos) ||
          (powerUp.isActive &&
              pos.x == powerUp.position.x &&
              pos.y == powerUp.position.y),
    );

    // Slightly speed up
    if (currentSpeed > 0.04) {
      baseSpeed -= 0.001;
      _updateSpeed();
    }

    AudioService.playEat();
  }

  void _onPowerUpCollected() {
    final type = powerUp.type;
    powerUp.deactivate();

    // Apply power-up effect
    switch (type) {
      case PowerUpType.speedBoost:
        snake.hasSpeedBoost = true;
        activePowerUps[type] = GameConstants.speedBoostDuration;
        break;
      case PowerUpType.shield:
        snake.hasShield = true;
        activePowerUps[type] = GameConstants.shieldDuration;
        break;
      case PowerUpType.doublePoints:
        snake.hasDoublePoints = true;
        activePowerUps[type] = GameConstants.doublePointsDuration;
        break;
      case PowerUpType.slowMotion:
        snake.hasSlowMotion = true;
        activePowerUps[type] = GameConstants.slowMotionDuration;
        break;
    }

    _updateSpeed();
    onPowerUpsChanged?.call(activePowerUps);

    int points = GameConstants.powerUpPoints;
    if (snake.hasDoublePoints) {
      points *= 2;
    }
    score += points;
    onScoreChanged?.call(score);

    // Emit particles
    particles.emit(
      position: Vector2(
        powerUp.position.x * cellSize + cellSize / 2,
        powerUp.position.y * cellSize + cellSize / 2,
      ),
      color: powerUp.color,
      count: 20,
      speed: 150,
    );

    AudioService.playPowerUp();
  }

  void _updatePowerUps(double dt) {
    final expiredPowerUps = <PowerUpType>[];

    activePowerUps.forEach((type, timeLeft) {
      activePowerUps[type] = timeLeft - dt;
      if (activePowerUps[type]! <= 0) {
        expiredPowerUps.add(type);
      }
    });

    for (final type in expiredPowerUps) {
      activePowerUps.remove(type);
      switch (type) {
        case PowerUpType.speedBoost:
          snake.hasSpeedBoost = false;
          break;
        case PowerUpType.shield:
          snake.hasShield = false;
          break;
        case PowerUpType.doublePoints:
          snake.hasDoublePoints = false;
          break;
        case PowerUpType.slowMotion:
          snake.hasSlowMotion = false;
          break;
      }
      _updateSpeed();
    }

    if (expiredPowerUps.isNotEmpty) {
      onPowerUpsChanged?.call(activePowerUps);
    }
  }

  void _updateSpeed() {
    currentSpeed = baseSpeed;

    if (snake.hasSpeedBoost) {
      currentSpeed *= 0.6; // Faster
    }
    if (snake.hasSlowMotion) {
      currentSpeed *= 1.5; // Slower
    }
  }

  void _triggerGameOver() async {
    isGameOver = true;

    // Save score
    await StorageService.saveHighScore(difficulty, score);
    await StorageService.incrementTotalGames();
    await StorageService.addToTotalScore(score);

    await AudioService.stopBackgroundMusic();
    await AudioService.playGameOver();

    // Big explosion effect
    particles.emit(
      position: Vector2(
        snake.headPosition.x * cellSize + cellSize / 2,
        snake.headPosition.y * cellSize + cellSize / 2,
      ),
      color: Colors.red,
      count: 30,
      speed: 200,
      lifetime: 1.0,
    );

    onGameOver?.call();
  }

  // Keyboard controls
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        snake.changeDirection(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        snake.changeDirection(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        snake.changeDirection(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        snake.changeDirection(Direction.right);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        togglePause();
      }
    }
    return KeyEventResult.handled;
  }

  // Swipe controls for mobile
  Vector2? _panStart;

  @override
  void onPanStart(DragStartInfo info) {
    _panStart = info.eventPosition.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_panStart == null) return;

    final velocity = info.velocity;
    final dx = velocity.x;
    final dy = velocity.y;

    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        snake.changeDirection(Direction.right);
      } else {
        snake.changeDirection(Direction.left);
      }
    } else {
      if (dy > 0) {
        snake.changeDirection(Direction.down);
      } else {
        snake.changeDirection(Direction.up);
      }
    }

    _panStart = null;
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  void reset() {
    snake.reset();
    food.spawn((pos) => snake.isOnPosition(pos));
    powerUp.deactivate();
    activePowerUps.clear();
    score = 0;
    baseSpeed = GameConstants.difficultySpeed[difficulty]!;
    currentSpeed = baseSpeed;
    moveTimer = 0;
    powerUpSpawnTimer = 0;
    isGameOver = false;
    isPaused = false;

    onScoreChanged?.call(score);
    onPowerUpsChanged?.call(activePowerUps);

    AudioService.startBackgroundMusic();
  }

  @override
  void onRemove() {
    AudioService.stopBackgroundMusic();
    super.onRemove();
  }
}
