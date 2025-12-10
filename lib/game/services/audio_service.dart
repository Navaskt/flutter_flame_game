import 'package:flame_audio/flame_audio.dart';
import 'storage_service.dart';

class AudioService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Preload audio files
    await FlameAudio.audioCache.loadAll([
      'eat.wav',
      'power_up.wav',
      'game_over.wav',
      'background_music.wav',
    ]);

    _initialized = true;
  }

  static Future<void> playEat() async {
    if (StorageService.soundEnabled) {
      await FlameAudio.play('eat.wav', volume: 0.5);
    }
  }

  static Future<void> playPowerUp() async {
    if (StorageService.soundEnabled) {
      await FlameAudio.play('power_up.wav', volume: 0.6);
    }
  }

  static Future<void> playGameOver() async {
    if (StorageService.soundEnabled) {
      await FlameAudio.play('game_over.wav', volume: 0.7);
    }
  }

  static Future<void> startBackgroundMusic() async {
    if (StorageService.musicEnabled) {
      await FlameAudio.bgm.play('background_music.wav', volume: 0.3);
    }
  }

  static Future<void> stopBackgroundMusic() async {
    await FlameAudio.bgm.stop();
  }

  static Future<void> toggleMusic(bool enabled) async {
    if (enabled) {
      await startBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }
}
