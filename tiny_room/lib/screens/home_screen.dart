import 'package:flutter/material.dart';

import '../state/game_state.dart';
import '../widgets/room_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _walk(BuildContext context, int steps) {
    final game = GameScope.of(context);
    final coinsBefore = game.coins;
    final unlocked = game.addFakeSteps(steps);
    final earned = game.coins - coinsBefore;

    final messages = [
      '🚶 +$steps алхам  →  🪙 +$earned coin',
      for (final f in unlocked) '🎉 ${f.emoji} ${f.name} нээгдлээ!',
    ];
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(messages.join('\n')),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('MY LITTLE ROOM'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const RoomView(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Stat(emoji: '🚶', value: '${game.todaySteps}', label: 'өнөөдөр'),
                      _Stat(emoji: '🪙', value: '${game.coins}', label: 'coin'),
                      _Stat(emoji: '🔥', value: '${game.streak}', label: 'streak'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Өдрийн зорилго: ${game.todaySteps} / $dailyStepGoal',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: game.dailyProgress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // LEVEL 1: fake алхам. LEVEL 2-т HealthKit / Health Connect-оор солино.
          Text('Туршилтын алхам (prototype)', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final s in [100, 1000, 5000])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton.tonal(
                      onPressed: () => _walk(context, s),
                      child: Text('+$s'),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _Stat({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
