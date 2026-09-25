import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_room/models/furniture.dart';
import 'package:tiny_room/state/game_state.dart';

void main() {
  late DateTime now;
  late GameState game;

  setUp(() {
    now = DateTime(2026, 9, 25, 12);
    game = GameState(clock: () => now);
  });

  test('8,000 алхам → 80 coin', () {
    game.syncTodaySteps(8000);
    expect(game.coins, 80);
  });

  test('Incremental: 7,000 → 8,000 бол зөвхөн +10 coin', () {
    game.syncTodaySteps(7000);
    expect(game.coins, 70);
    game.syncTodaySteps(8000);
    expect(game.coins, 80);
    // Ижил тоог дахин илгээхэд coin давхар өгөхгүй.
    game.syncTodaySteps(8000);
    expect(game.coins, 80);
  });

  test('Жижиг алхмууд coin-оо алдахгүй хуримтлагдана', () {
    for (var i = 0; i < 10; i++) {
      game.addFakeSteps(50);
    }
    expect(game.todaySteps, 500);
    expect(game.coins, 5);
  });

  test('Шинэ өдөр эхлэхэд өдрийн алхам тэглэгдэнэ, нийт хадгалагдана', () {
    game.syncTodaySteps(6000);
    now = now.add(const Duration(days: 1));
    game.syncTodaySteps(3000);
    expect(game.todaySteps, 3000);
    expect(game.totalSteps, 9000);
    expect(game.coins, 90);
  });

  test('7 хоног дараалан зорилгод хүрвэл буйдан нээгдэнэ', () {
    final sofa = furnitureById('sofa');
    List<Furniture> unlocked = [];
    for (var day = 0; day < 7; day++) {
      unlocked = game.syncTodaySteps(dailyStepGoal);
      now = now.add(const Duration(days: 1));
    }
    expect(game.streak, 7);
    expect(game.isUnlocked(sofa), isTrue);
    expect(unlocked.map((f) => f.id), contains('sofa'));
  });

  test('Нэг өдөр алгасвал streak тасарна', () {
    game.syncTodaySteps(dailyStepGoal);
    now = now.add(const Duration(days: 2));
    game.syncTodaySteps(100);
    expect(game.streak, 0);
    game.syncTodaySteps(dailyStepGoal);
    expect(game.streak, 1);
  });

  test('Худалдан авах, өрөөнд тавих', () {
    final chair = furnitureById('chair');
    expect(game.buy(chair), isFalse); // coin хүрэхгүй
    game.syncTodaySteps(10000);
    expect(game.buy(chair), isTrue);
    expect(game.coins, 0);
    expect(game.inventory, [chair]);
    game.placeItem('chair');
    expect(game.inventory, isEmpty);
    expect(game.placed.single.furnitureId, 'chair');
  });
}
