import 'package:shared_preferences/shared_preferences.dart';
import '../utils/game_constant.dart';

class StorageService {
  static late SharedPreferences _prefs;
  
  static const String _highScorePrefix = 'high_score_';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _difficultyKey = 'difficulty';
  static const String _totalGamesKey = 'total_games';
  static const String _totalScoreKey = 'total_score';
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // High Scores
  static Future<void> saveHighScore(Difficulty difficulty, int score) async {
    final key = '$_highScorePrefix${difficulty.name}';
    final currentHigh = getHighScore(difficulty);
    if (score > currentHigh) {
      await _prefs.setInt(key, score);
    }
  }
  
  static int getHighScore(Difficulty difficulty) {
    final key = '$_highScorePrefix${difficulty.name}';
    return _prefs.getInt(key) ?? 0;
  }
  
  static Map<Difficulty, int> getAllHighScores() {
    return {
      for (var difficulty in Difficulty.values)
        difficulty: getHighScore(difficulty),
    };
  }
  
  static Future<void> clearHighScores() async {
    for (var difficulty in Difficulty.values) {
      await _prefs.remove('$_highScorePrefix${difficulty.name}');
    }
  }
  
  // Settings
  static bool get soundEnabled => _prefs. getBool(_soundEnabledKey) ?? true;
  static Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_soundEnabledKey, value);
  }
  
  static bool get musicEnabled => _prefs.getBool(_musicEnabledKey) ??  true;
  static Future<void> setMusicEnabled(bool value) async {
    await _prefs.setBool(_musicEnabledKey, value);
  }
  
  static Difficulty get difficulty {
    final index = _prefs.getInt(_difficultyKey) ?? 1;
    return Difficulty.values[index];
  }
  static Future<void> setDifficulty(Difficulty value) async {
    await _prefs.setInt(_difficultyKey, value.index);
  }
  
  // Statistics
  static int get totalGames => _prefs.getInt(_totalGamesKey) ?? 0;
  static Future<void> incrementTotalGames() async {
    await _prefs.setInt(_totalGamesKey, totalGames + 1);
  }
  
  static int get totalScore => _prefs.getInt(_totalScoreKey) ?? 0;
  static Future<void> addToTotalScore(int score) async {
    await _prefs.setInt(_totalScoreKey, totalScore + score);
  }
}