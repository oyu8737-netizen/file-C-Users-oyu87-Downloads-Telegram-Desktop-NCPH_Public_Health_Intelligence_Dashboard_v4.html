import 'package:flutter/material.dart';

import '../state/game_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text('LEVEL ${game.level}', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: game.levelProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          Text(
            'Дараагийн level хүртэл ${stepsPerLevel - game.totalSteps % stepsPerLevel} алхам',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🚶', style: TextStyle(fontSize: 24)),
                  title: Text('${game.totalSteps} алхам'),
                  subtitle: const Text('Нийт'),
                ),
                ListTile(
                  leading: const Text('🔥', style: TextStyle(fontSize: 24)),
                  title: Text('${game.streak} хоногийн streak'),
                  subtitle: const Text('Өдөрт $dailyStepGoal+ алхам'),
                ),
                ListTile(
                  leading: const Text('🪙', style: TextStyle(fontSize: 24)),
                  title: Text('${game.coins} coin'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('ROOM SCORE', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: game.roomScore,
            minHeight: 14,
            borderRadius: BorderRadius.circular(7),
          ),
          Text('${(game.roomScore * 100).round()}%', textAlign: TextAlign.end),
          const Divider(height: 40),
          // Streak-ийн логикийг шалгахад зориулсан туршилтын товчнууд.
          Text('Туршилт (prototype)', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.nightlight_round),
            label: const Text('Дараагийн өдөр рүү шилжих'),
            onPressed: game.debugNextDay,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.restart_alt),
            label: const Text('Бүгдийг эхнээс нь'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Бүгдийг устгах уу?'),
                  content: const Text('Coin, алхам, тавилга бүгд тэглэгдэнэ.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Болих'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Устгах'),
                    ),
                  ],
                ),
              );
              if (ok == true) game.reset();
            },
          ),
        ],
      ),
    );
  }
}
