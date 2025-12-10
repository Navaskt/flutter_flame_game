import 'package:flutter/material.dart';

class GameConstants {
  // Board settings
  static const int boardWidth = 20;
  static const int boardHeight = 30;

  // Difficulty settings
  static const Map<Difficulty, double> difficultySpeed = {
    Difficulty.easy: 0.20,
    Difficulty.medium: 0.15,
    Difficulty.hard: 0.10,
    Difficulty.extreme: 0.06,
  };

  static const Map<Difficulty, String> difficultyNames = {
    Difficulty.easy: 'Easy',
    Difficulty.medium: 'Medium',
    Difficulty.hard: 'Hard',
    Difficulty.extreme: 'Extreme',
  };

  // Colors
  static const Color snakeHeadColor = Color(0xFF1B5E20);
  static const Color snakeBodyColor = Color(0xFF4CAF50);
  static const Color snakeShieldColor = Color(0xFF64B5F6);
  static const Color foodColor = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFF0D3311);
  static const Color gridColor = Color(0xFF1A4D1E);

  // Power-up durations (in seconds)
  static const double speedBoostDuration = 5.0;
  static const double shieldDuration = 8.0;
  static const double doublePointsDuration = 10.0;
  static const double slowMotionDuration = 6.0;

  // Power-up spawn chance (0. 0 - 1.0)
  static const double powerUpSpawnChance = 0.15;

  // Points
  static const int foodPoints = 10;
  static const int powerUpPoints = 25;
}

enum Difficulty { easy, medium, hard, extreme }

enum PowerUpType { speedBoost, shield, doublePoints, slowMotion }
