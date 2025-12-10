import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/game_constant.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  late Map<Difficulty, int> _highScores;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  void _loadHighScores() {
    _highScores = StorageService.getAllHighScores();
    setState(() {});
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

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear High Scores'),
        content: const Text(
          'Are you sure you want to clear all high scores? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await StorageService.clearHighScores();
      _loadHighScores();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('High scores cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure _highScores is initialized (it will be after initState)
    final scores = _highScores;
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Scores'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF051A07),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: Difficulty.values.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  final difficulty = Difficulty.values[index];
                  final name =
                      GameConstants.difficultyNames[difficulty] ??
                      difficulty.name.toUpperCase();
                  final score = scores[difficulty] ?? 0;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _difficultyColor(difficulty),
                      child: Text(
                        name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear High Scores'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                    onPressed: _confirmClear,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
