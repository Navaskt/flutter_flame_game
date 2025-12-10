import 'package:flutter/material.dart';
import '../utils/game_constant.dart';

class HudWidget extends StatelessWidget {
  final int score;
  final int highScore;
  final Difficulty difficulty;
  final Map<PowerUpType, double> activePowerUps;
  final bool isPaused;
  final VoidCallback onPausePressed;
  final VoidCallback onBackPressed;

  const HudWidget({
    super.key,
    required this.score,
    required this.highScore,
    required this.difficulty,
    required this.activePowerUps,
    required this.isPaused,
    required this.onPausePressed,
    required this.onBackPressed,
  });

  String _formatTime(double seconds) {
    final s = seconds.ceil();
    return '$s' + 's';
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Colors.green.shade600;
      case Difficulty.medium:
        return Colors.orange.shade600;
      case Difficulty.hard:
        return Colors.red.shade600;
      case Difficulty.extreme:
        return Colors.purple.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.black26,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed,
              tooltip: 'Back to menu',
            ),
          ),

          const SizedBox(width: 8),

          // Score & difficulty (center area)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top row: Score and High Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.score,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // High score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$highScore',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Difficulty tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _difficultyColor(difficulty).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _difficultyColor(difficulty).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    GameConstants.difficultyNames[difficulty] ?? 'Unknown',
                    style: TextStyle(
                      color: _difficultyColor(difficulty),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Active power-ups (compact)
          SizedBox(
            width: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: activePowerUps.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _PowerUpChip(type: e.key, timeLeft: e.value),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Pause button
          Material(
            color: Colors.black26,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              onPressed: onPausePressed,
              tooltip: isPaused ? 'Resume' : 'Pause',
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerUpChip extends StatelessWidget {
  final PowerUpType type;
  final double timeLeft;

  const _PowerUpChip({required this.type, required this.timeLeft});

  String _iconForType(PowerUpType t) {
    switch (t) {
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

  Color _colorForType(PowerUpType t) {
    switch (t) {
      case PowerUpType.speedBoost:
        return Colors.orange;
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.doublePoints:
        return Colors.yellow.shade700;
      case PowerUpType.slowMotion:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _colorForType(type).withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _colorForType(type).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Text(_iconForType(type), style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '${timeLeft.ceil()}s',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
