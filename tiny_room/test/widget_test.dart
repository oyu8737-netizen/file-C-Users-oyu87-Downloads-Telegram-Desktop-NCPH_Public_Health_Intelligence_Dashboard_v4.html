import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_room/main.dart';
import 'package:tiny_room/services/step_service.dart';
import 'package:tiny_room/state/game_state.dart';
import 'package:tiny_room/state/settings_state.dart';

void main() {
  /// Одоо харагдаж буй дэлгэцийг [target] харагдтал доош гүйлгэнэ.
  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(target, 200,
        scrollable: find.byType(Scrollable).hitTestable().first);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  /// Доод талын мэдэгдэл (SnackBar) товчийг далдлахгүйн тулд хаана.
  Future<void> hideSnack(WidgetTester tester) async {
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
  }

  Future<GameState> pumpApp(WidgetTester tester, {bool mongolian = true}) async {
    // Утасны хэмжээтэй дэлгэц (360x800).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final game = GameState();
    final steps = StepSync(game);
    await steps.start(); // тест орчин = утас биш → туршилтын товч гарна
    await tester.pumpWidget(TinyRoomApp(
      game: game,
      settings: SettingsState(mongolian: mongolian),
      cloud: null, // Firebase-гүй (offline горим)
      steps: steps,
    ));
    return game;
  }

  testWidgets('+5000 → coin, дэлгүүрээс сандал авч, өрөөнд тавьж будна',
      (tester) async {
    final game = await pumpApp(tester);
    expect(find.text('МИНИЙ ӨРӨӨ'), findsOneWidget);

    await scrollTo(tester, find.text('+5000'));
    await tester.tap(find.text('+5000'));
    await hideSnack(tester);
    await tester.tap(find.text('+5000'));
    await hideSnack(tester);
    // 100 алхмын coin + 20 зорилго + 5 streak
    expect(game.coins, 125);
    expect(game.streak, 1);

    await tester.tap(find.text('Дэлгүүр').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('100 🪙'));
    await hideSnack(tester);
    expect(game.owned, contains('chair'));

    await tester.tap(find.text('Өрөө'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActionChip));
    await tester.pump();
    expect(game.placed.single.furnitureId, 'chair');

    // Сонгогдсон тавилгыг цэнхэр өнгөөр будах (5 дахь өнгө).
    await scrollTo(tester, find.byKey(const ValueKey('color_5')));
    await tester.tap(find.byKey(const ValueKey('color_5')));
    await tester.pump();
    expect(game.placed.single.color, isNotNull);
  });

  testWidgets('Хэл солиход англиар харагдана', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Би').last);
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('🇬🇧 English'));
    await tester.tap(find.text('🇬🇧 English'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Firebase-гүй үед Найзууд таб тайлбар харуулна', (tester) async {
    await pumpApp(tester, mongolian: false);
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Firebase'), findsOneWidget);
  });
}
