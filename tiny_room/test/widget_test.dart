import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_room/main.dart';
import 'package:tiny_room/state/game_state.dart';

void main() {
  testWidgets('+5000 товч → coin нэмэгдэж, дэлгүүрээс сандал авна',
      (tester) async {
    // Утасны хэмжээтэй дэлгэц (360x800).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final game = GameState();
    await tester.pumpWidget(TinyRoomApp(game: game));

    expect(find.text('MY LITTLE ROOM'), findsOneWidget);

    await tester.tap(find.text('+5000'));
    await tester.pump();
    await tester.tap(find.text('+5000'));
    await tester.pump();
    expect(game.coins, 100);
    expect(game.streak, 1);

    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('100 🪙'));
    await tester.pump();
    expect(game.owned, contains('chair'));

    await tester.tap(find.text('Room'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActionChip));
    await tester.pump();
    expect(game.placed.single.furnitureId, 'chair');
  });
}
