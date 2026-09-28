import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/cloud_service.dart';
import '../services/step_service.dart';
import 'game_state.dart';

/// Дэлгэц бүрээс Firebase болон алхмын үйлчилгээнд хандах.
/// [cloud] null бол Firebase тохируулаагүй (offline горим).
class AppServices extends InheritedWidget {
  final CloudService? cloud;
  final StepSync steps;

  const AppServices({
    super.key,
    required this.cloud,
    required this.steps,
    required super.child,
  });

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppServices>()!;

  @override
  bool updateShouldNotify(AppServices old) =>
      cloud != old.cloud || steps != old.steps;
}

/// Алхмаас coin авсныг доод талд мэдэгдэх.
void showRewardSnack(
    ScaffoldMessengerState messenger, SyncResult r, S s) {
  final lines = [
    s.stepsEarned(r.newSteps, r.stepCoins),
    if (r.goalBonus > 0) s.goalBonusText(r.goalBonus),
    if (r.streakBonus > 0) s.streakBonusText(r.streakBonus),
    for (final f in r.unlocked) s.unlockedText(f.emoji, f.name(s.lang)),
  ];
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(lines.join('\n')),
      duration: const Duration(seconds: 3),
    ));
}
