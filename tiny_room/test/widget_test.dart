import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_room/l10n/strings.dart';
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

  /// Дээш гүйлгэж (доош гүйлгэхэд нуугдсан) доод цэсийг гаргана.
  Future<void> showMenuBar(WidgetTester tester) async {
    await tester.drag(
        find.byType(Scrollable).hitTestable().first, const Offset(0, 400));
    await tester.pumpAndSettle();
  }

  /// Доод талын мэдэгдэл (SnackBar) товчийг далдлахгүйн тулд хаана.
  Future<void> hideSnack(WidgetTester tester) async {
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
  }

  Future<GameState> pumpApp(WidgetTester tester,
      {AppLang lang = AppLang.mn, bool wide = false}) async {
    // Утас (360x800) эсвэл компьютерийн дэлгэц (1280x800).
    tester.view.physicalSize =
        wide ? const Size(3840, 2400) : const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final game = GameState();
    final steps = StepSync(game);
    await steps.start(); // тест орчин = утас биш → туршилтын товч гарна
    await tester.pumpWidget(TinyRoomApp(
      game: game,
      settings: SettingsState(lang: lang),
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

    await showMenuBar(tester);
    await tester.tap(find.text('Дэлгүүр').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('100 🪙'));
    await hideSnack(tester);
    expect(game.owned, contains('chair'));

    await showMenuBar(tester);
    await tester.tap(find.text('Өрөө').last);
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
    await showMenuBar(tester);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Firebase-гүй үед Найзууд таб тайлбар харуулна', (tester) async {
    await pumpApp(tester, lang: AppLang.en);
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Firebase'), findsOneWidget);
  });

  testWidgets('Хятад хэл: текст, улаан-алтан өнгө, дэнлүү', (tester) async {
    await pumpApp(tester, lang: AppLang.zh);
    expect(find.text('我的小屋'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('🏮'), findsWidgets);
    final ctx = tester.element(find.text('我的小屋'));
    expect(Theme.of(ctx).colorScheme.primary.r,
        greaterThan(Theme.of(ctx).colorScheme.primary.b));
  });

  testWidgets('Компьютер дээр хажуугийн цэсийг хураах/дэлгэх', (tester) async {
    await pumpApp(tester, wide: true);
    final rail = find.byType(NavigationRail);
    expect(tester.widget<NavigationRail>(rail).extended, isTrue);
    await tester.tap(find.byKey(const ValueKey('menu_toggle')));
    await tester.pumpAndSettle();
    expect(tester.widget<NavigationRail>(rail).extended, isFalse);
    await tester.tap(find.byKey(const ValueKey('menu_toggle')));
    await tester.pumpAndSettle();
    expect(tester.widget<NavigationRail>(rail).extended, isTrue);
  });
}
