import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../utils/game_constant.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  late Difficulty _difficulty;

  @override
  void initState() {
    super.initState();
    _soundEnabled = StorageService.soundEnabled;
    _musicEnabled = StorageService.musicEnabled;
    _difficulty = StorageService.difficulty;
  }

  Future<void> _setSound(bool enabled) async {
    await StorageService.setSoundEnabled(enabled);
    setState(() => _soundEnabled = enabled);
  }

  Future<void> _setMusic(bool enabled) async {
    await StorageService.setMusicEnabled(enabled);
    setState(() => _musicEnabled = enabled);
    await AudioService.toggleMusic(enabled);
  }

  Future<void> _setDifficulty(Difficulty d) async {
    await StorageService.setDifficulty(d);
    setState(() => _difficulty = d);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Difficulty set to ${GameConstants.difficultyNames[d]}')),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear High Scores'),
        content: const Text('This will clear all high scores. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );

    if (confirmed ?? false) {
      await StorageService.clearHighScores();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('High scores cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFF051A07),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 8),

          // Sound toggle
          SwitchListTile(
            value: _soundEnabled,
            onChanged: (v) => _setSound(v),
            title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Play sound effects (eating, power-ups)', style: TextStyle(color: Colors.white70)),
            activeColor: Colors.green,
          ),

          const SizedBox(height: 6),

          // Music toggle
          SwitchListTile(
            value: _musicEnabled,
            onChanged: (v) => _setMusic(v),
            title: const Text('Background Music', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Play background music during gameplay', style: TextStyle(color: Colors.white70)),
            activeColor: Colors.green,
          ),

          const Divider(color: Colors.white12),

          const SizedBox(height: 6),

          // Difficulty selection
          ListTile(
            title: const Text('Difficulty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(GameConstants.difficultyNames[_difficulty] ?? _difficulty.name, style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.edit, color: Colors.white70),
            onTap: () => _showDifficultyPicker(),
          ),

          const Divider(color: Colors.white12),

          const SizedBox(height: 6),

          // Clear high scores
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Clear High Scores'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, minimumSize: const Size.fromHeight(48)),
            onPressed: _confirmClearAll,
          ),

          const SizedBox(height: 12),

          // About / version
          Card(
            color: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Advanced Snake — Flutter + Flame', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  const Text('Version: 1.0.0', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDifficultyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF081306),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Difficulty.values.map((d) {
              final name = GameConstants.difficultyNames[d] ?? d.name;
              return RadioListTile<Difficulty>(
                value: d,
                groupValue: _difficulty,
                onChanged: (val) {
                  if (val != null) {
                    _setDifficulty(val);
                    Navigator.pop(context);
                  }
                },
                title: Text(name, style: const TextStyle(color: Colors.white)),
                activeColor: Colors.green,
                secondary: Icon(
                  _iconForDifficulty(d),
                  color: _colorForDifficulty(d),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  IconData _iconForDifficulty(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_dissatisfied;
      case Difficulty.extreme:
        return Icons.whatshot;
    }
  }

  Color _colorForDifficulty(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.extreme:
        return Colors.purple;
    }
  }
}