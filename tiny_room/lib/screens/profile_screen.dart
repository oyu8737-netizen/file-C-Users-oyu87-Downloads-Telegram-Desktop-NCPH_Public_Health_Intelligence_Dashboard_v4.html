import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/step_service.dart';
import '../state/app_services.dart';
import '../state/game_state.dart';
import '../state/settings_state.dart';
import '../widgets/bar_chart.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final settings = SettingsScope.of(context);
    final s = SettingsScope.strings(context);
    final services = AppServices.of(context);
    final cloud = services.cloud;
    final theme = Theme.of(context);
    final week = game.recentDays(7);

    return Scaffold(
      appBar: AppBar(title: Text(s.profileTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Account ──
          if (cloud != null)
            ListenableBuilder(
              listenable: cloud,
              builder: (context, _) {
                final user = cloud.user;
                if (user == null) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(s.notSignedIn),
                      subtitle: Text(s.notSignedInHint),
                      trailing: FilledButton(
                        onPressed: () => settings.setAuthSkipped(false),
                        child: Text(s.signIn),
                      ),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(cloud.profile?.name ?? ''),
                        subtitle: Text(user.email ?? ''),
                        trailing: TextButton(
                          onPressed: () => _confirmSignOut(context),
                          child: Text(s.signOut),
                        ),
                      ),
                      if (cloud.isAdmin)
                        ListTile(
                          leading: const Icon(Icons.insights),
                          title: Text(s.adminTitle),
                          subtitle: Text(s.adminSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => AdminScreen(cloud: cloud))),
                        ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 8),

          // ── Level ──
          Center(
            child: Text('LEVEL ${game.level}',
                style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: game.levelProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          Text(
            s.toNextLevel(stepsPerLevel - game.totalSteps % stepsPerLevel),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // ── 7 хоногийн алхам ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.last7Days, style: theme.textTheme.titleMedium),
                  Text(s.goalLineHint(dailyStepGoal),
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  SimpleBarChart(
                    values: [for (final d in week) d.value],
                    labels: [for (final d in week) s.weekday(d.key)],
                    goal: dailyStepGoal,
                    tooltip: (v) => s.stepsCount(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Статистик ──
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🚶', style: TextStyle(fontSize: 24)),
                  title: Text(s.stepsCount(game.totalSteps)),
                  subtitle: Text(s.totalLabel),
                ),
                ListTile(
                  leading: const Text('🔥', style: TextStyle(fontSize: 24)),
                  title: Text(s.streakDays(game.streak)),
                  subtitle: Text(s.activeDaysText(game.activeDays)),
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

          // ── Хэл ──
          Text(s.language, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('🇲🇳 Монгол')),
              ButtonSegment(value: false, label: Text('🇬🇧 English')),
            ],
            selected: {settings.mongolian},
            onSelectionChanged: (v) => settings.setMongolian(v.first),
          ),

          // ── Туршилт (зөвхөн хөгжүүлэлт эсвэл вэб дээр) ──
          if (kDebugMode ||
              services.steps.status == StepStatus.unsupported) ...[
            const Divider(height: 40),
            Text(s.testTools, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.nightlight_round),
              label: Text(s.nextDay),
              onPressed: game.debugNextDay,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: Text(s.resetAll),
              onPressed: () => _confirmReset(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final s = SettingsScope.strings(context);
    final cloud = AppServices.of(context).cloud;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.signOutQ),
        content: Text(s.signOutBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.signOut)),
        ],
      ),
    );
    if (ok == true) await cloud?.signOut();
  }

  Future<void> _confirmReset(BuildContext context) async {
    final s = SettingsScope.strings(context);
    final game = GameScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.resetQ),
        content: Text(s.resetBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true) game.reset();
  }
}
