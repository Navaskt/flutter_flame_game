import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../services/storage_service.dart';
import '../snake_game.dart';
import '../utils/game_constant.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/hud_widget.dart';
import '../widgets/pause_overlay.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame _game;
  int _score = 0;
  Map<PowerUpType, double> _activePowerUps = {};
  bool _showGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = SnakeGame(
      difficulty: widget.difficulty,
      onScoreChanged: (score) {
        setState(() => _score = score);
      },
      onPowerUpsChanged: (powerUps) {
        setState(() => _activePowerUps = Map.from(powerUps));
      },
      onGameOver: () {
        setState(() => _showGameOver = true);
      },
    );
  }

  void _resetGame() {
    setState(() {
      _showGameOver = false;
      _score = 0;
      _activePowerUps.clear();
    });
    _game.reset();
  }

  void _togglePause() {
    _game.togglePause();
    setState(() {});
  }

  @override
  void dispose() {
    // If you need to dispose resources in SnakeGame or stop music, do it here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep background consistent with theme
      body: Stack(
        children: [
          // The Flame game widget
          GameWidget(game: _game),

          // HUD positioned at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: HudWidget(
                score: _score,
                highScore: StorageService.getHighScore(widget.difficulty),
                difficulty: widget.difficulty,
                activePowerUps: _activePowerUps,
                isPaused: _game.isPaused,
                onPausePressed: _togglePause,
                onBackPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Pause overlay (Flutter widget layered above the GameWidget)
          if (_game.isPaused && !_showGameOver)
            PauseOverlay(
              onResume: _togglePause,
              onRestart: _resetGame,
              onQuit: () => Navigator.pop(context),
            ),

          // Game Over overlay
          if (_showGameOver)
            GameOverOverlay(
              score: _score,
              highScore: StorageService.getHighScore(widget.difficulty),
              onRestart: () {
                _resetGame();
              },
              onQuit: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}