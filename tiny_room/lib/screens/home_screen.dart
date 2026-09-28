import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/step_service.dart';
import '../state/app_services.dart';
import '../state/game_state.dart';
import '../state/settings_state.dart';
import '../widgets/room_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final s = SettingsScope.strings(context);
    final steps = AppServices.of(context).steps;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.homeTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Greeting(),
          const SizedBox(height: 12),
          RoomView(items: game.placed, emptyText: s.roomEmpty),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Stat(emoji: '🚶', value: '${game.todaySteps}', label: s.today),
                      _Stat(emoji: '🪙', value: '${game.coins}', label: s.coinsLabel),
                      _Stat(emoji: '🔥', value: '${game.streak}', label: s.streakLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.dailyGoal(game.todaySteps, dailyStepGoal),
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
          ListenableBuilder(
            listenable: steps,
            builder: (context, _) => _StepSourceCard(steps: steps),
          ),
          // Вэб дээр эсвэл хөгжүүлэлтийн үед туршилтын товч харагдана.
          ListenableBuilder(
            listenable: steps,
            builder: (context, _) {
              if (!kDebugMode && steps.status != StepStatus.unsupported) {
                return const SizedBox.shrink();
              }
              return const _TestButtons();
            },
          ),
        ],
      ),
    );
  }
}

/// Алхам хаанаас ирж байгааг харуулж, холбох товч санал болгоно.
class _StepSourceCard extends StatelessWidget {
  final StepSync steps;

  const _StepSourceCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    final sourceName = steps.source == StepSource.sensor
        ? s.sourceSensor
        : s.sourceHealth;

    late final Widget body;
    switch (steps.status) {
      case StepStatus.starting:
        body = ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(s.stepsStarting),
        );
      case StepStatus.unsupported:
        body = ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(s.stepsUnsupported),
        );
      case StepStatus.needsPermission:
        body = Column(
          children: [
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: Text(s.connectStepsTitle(sourceName)),
              subtitle: Text(s.connectStepsBody),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.link),
                      label: Text(s.connectSteps),
                      onPressed: steps.connect,
                    ),
                  ),
                  if (steps.canInstallHealthConnect) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: steps.installHealthConnect,
                      child: Text(s.installHealthConnect),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case StepStatus.ready:
        final t = steps.lastSync;
        body = ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(s.stepsConnected(sourceName)),
          subtitle: Text(t == null
              ? s.sensorHint(steps.source == StepSource.sensor)
              : s.lastSynced(
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')),
          trailing: steps.source == StepSource.health
              ? IconButton(
                  tooltip: s.refresh,
                  icon: const Icon(Icons.refresh),
                  onPressed: steps.refresh,
                )
              : null,
        );
      case StepStatus.error:
        body = ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(s.stepsError),
          trailing: TextButton(onPressed: steps.connect, child: Text(s.retry)),
        );
    }
    return Card(child: body);
  }
}

class _TestButtons extends StatelessWidget {
  const _TestButtons();

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.testSteps, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final n in [100, 1000, 5000])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton.tonal(
                      onPressed: () {
                        final r = GameScope.of(context).addFakeSteps(n);
                        showRewardSnack(ScaffoldMessenger.of(context), r, s);
                      },
                      child: Text('+$n'),
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

/// Хэл бүрийн улсын өнгөөр мэндчилгээ: 🐎 Сайн байна уу! / ☕ Hello there! / 🏮 你好！
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    final vibe = SettingsScope.vibe(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [
          vibe.seed,
          Color.lerp(vibe.seed, Colors.white, 0.35)!,
        ]),
      ),
      child: Row(
        children: [
          Text(vibe.greetingEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.greeting,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(s.greetingLine,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
