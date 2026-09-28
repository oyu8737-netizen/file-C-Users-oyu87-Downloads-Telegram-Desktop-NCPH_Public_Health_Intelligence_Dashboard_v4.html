import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_room/models/furniture.dart';
import 'package:tiny_room/state/game_state.dart';

void main() {
  late DateTime now;
  late GameState game;

  setUp(() {
    now = DateTime(2026, 9, 25, 12);
    game = GameState(clock: () => now);
  });

  void nextDay([int n = 1]) => now = now.add(Duration(days: n));

  group('Алхам → coin', () {
    test('4,000 алхам → 40 coin (зорилгод хүрээгүй тул bonus-гүй)', () {
      game.syncSteps({now: 4000});
      expect(game.coins, 40);
    });

    test('Incremental: 3,000 → 4,000 бол зөвхөн +10, давхар өгөхгүй', () {
      game.syncSteps({now: 3000});
      expect(game.coins, 30);
      final r = game.syncSteps({now: 4000});
      expect(r.stepCoins, 10);
      expect(game.coins, 40);
      expect(game.syncSteps({now: 4000}).isEmpty, isTrue);
      expect(game.coins, 40);
    });

    test('Жижиг алхмууд coin-оо алдахгүй хуримтлагдана', () {
      for (var i = 0; i < 10; i++) {
        game.addFakeSteps(50);
      }
      expect(game.todaySteps, 500);
      expect(game.coins, 5);
    });

    test('Өдрийн зорилго: 5,000 → 50 + 20 bonus + 5 streak bonus', () {
      final r = game.syncSteps({now: 5000});
      expect(r.stepCoins, 50);
      expect(r.goalBonus, goalBonusCoins);
      expect(r.streakBonus, 5);
      expect(game.coins, 75);
      // Зорилгын bonus өдөрт нэг л удаа.
      game.syncSteps({now: 6000});
      expect(game.coins, 85);
    });
  });

  group('Streak', () {
    test('7 хоног дараалан → streak 7, буйдан нээгдэж, bonus өснө', () {
      SyncResult last = SyncResult();
      for (var d = 0; d < 7; d++) {
        last = game.syncSteps({now: dailyStepGoal});
        if (d < 6) nextDay();
      }
      expect(game.streak, 7);
      expect(game.isUnlocked(furnitureById('sofa')!), isTrue);
      expect(last.unlocked.map((f) => f.id), contains('sofa'));
      // 7×50 алхмын coin + 7×20 зорилго + 5×(1+…+7) streak
      expect(game.coins, 350 + 140 + 140);
    });

    test('Өнөөдөр хараахан хүрээгүй ч өчигдрийн streak тасрахгүй', () {
      game.syncSteps({now: dailyStepGoal});
      nextDay();
      game.syncSteps({now: 100});
      expect(game.streak, 1);
    });

    test('Нэг өдөр алгасвал streak тасарна', () {
      game.syncSteps({now: dailyStepGoal});
      nextDay(2);
      game.syncSteps({now: 100});
      expect(game.streak, 0);
      game.syncSteps({now: dailyStepGoal});
      expect(game.streak, 1);
    });

    test('Аппаа нээгээгүй өдрүүдийн алхам (Health) нөхөгдөнө', () {
      final r = game.syncSteps({
        now.subtract(const Duration(days: 2)): 6000,
        now.subtract(const Duration(days: 1)): 6000,
        now: 6000,
      });
      expect(game.streak, 3);
      expect(r.newSteps, 18000);
      expect(game.totalSteps, 18000);
      expect(r.streakBonus, 5 + 10 + 15);
    });

    test('Ирээдүйн өдрийн алхмыг хүлээж авахгүй', () {
      game.syncSteps({now.add(const Duration(days: 1)): 9000});
      expect(game.totalSteps, 0);
    });
  });

  group('Дэлгүүр ба өрөө', () {
    test('Худалдан авах, өрөөнд тавих, будах', () {
      final chair = furnitureById('chair')!;
      expect(game.buy(chair), isFalse); // coin хүрэхгүй
      game.syncSteps({now: 4000});
      game.syncSteps({now.subtract(const Duration(days: 1)): 4000});
      expect(game.coins, 80);
      game.addFakeSteps(2000); // 6000 → +20 coin +20 bonus +5 streak
      expect(game.buy(chair), isTrue);
      expect(game.inventory, [chair]);
      game.placeItem('chair');
      final item = game.placed.single;
      game.setItemColor(item, 0xFF4FC3F7);
      expect(game.placed.single.color, 0xFF4FC3F7);
      game.setItemColor(item, null);
      expect(game.placed.single.color, isNull);
    });

    test('JSON-оор хадгалаад буцааж ачаалахад адилхан', () {
      game.syncSteps({now: 8000}); // 80 + 20 + 5 = 105 coin
      expect(game.buy(furnitureById('chair')!), isTrue);
      game.placeItem('chair');
      game.setItemColor(game.placed.first, 0xFFE57373);

      final copy = GameState(clock: () => now)
        ..loadJson(jsonDecode(jsonEncode(game.toJson())) as Map<String, dynamic>);
      expect(copy.coins, game.coins);
      expect(copy.totalSteps, 8000);
      expect(copy.todaySteps, 8000);
      expect(copy.streak, 1);
      expect(copy.placed.single.color, 0xFFE57373);
    });
  });

  group('Өөр төхөөрөмж дээр нэвтрэх', () {
    test('Cloud-ын өрөө, coin сэргэж, энэ утасны илүү алхам нэмэгдэнэ', () {
      // Хуучин утас: 2 өдөр алхаж, сандал авч тавьсан → cloud-д хадгалагдсан.
      final oldPhone = GameState(clock: () => now);
      oldPhone.syncSteps({now.subtract(const Duration(days: 1)): 6000});
      oldPhone.syncSteps({now: 3000});
      oldPhone.buy(furnitureById('chair')!);
      oldPhone.placeItem('chair');
      final cloud = jsonDecode(jsonEncode(oldPhone.toJson()))
          as Map<String, dynamic>;

      // Шинэ утас: нэвтрэхээс өмнө өнөөдөр 4,000 алхам тоолсон.
      final newPhone = GameState(clock: () => now);
      newPhone.syncSteps({now: 4000});
      newPhone.mergeRemote(cloud);

      expect(newPhone.placed.single.furnitureId, 'chair'); // өрөө сэргэв
      expect(newPhone.owned, contains('chair'));
      expect(newPhone.todaySteps, 4000); // илүү алхам нэмэгдэв
      expect(newPhone.totalSteps, 6000 + 4000);
      // coin = cloud-ынх + зөвхөн нэмэгдсэн 1,000 алхмын 10 coin
      expect(newPhone.coins, oldPhone.coins + 10);
      expect(newPhone.streak, 1);
    });

    test('Энэ утсан дээр cloud-оос бага алхам байвал давхар coin өгөхгүй', () {
      final oldPhone = GameState(clock: () => now)..syncSteps({now: 8000});
      final cloud = jsonDecode(jsonEncode(oldPhone.toJson()))
          as Map<String, dynamic>;
      final newPhone = GameState(clock: () => now)..syncSteps({now: 2000});
      newPhone.mergeRemote(cloud);
      expect(newPhone.todaySteps, 8000);
      expect(newPhone.coins, oldPhone.coins);
    });
  });

  test('LEVEL 1 хувилбарын өгөгдөл шинэ хувилбар руу шилжинэ', () async {
    final today = GameState.dateKey(DateTime.now());
    SharedPreferences.setMockInitialValues({
      'tiny_room_state_v1': jsonEncode({
        'coins': 120,
        'totalSteps': 9000,
        'todaySteps': 3000,
        'coinsRewardedToday': 30,
        'todayDate': today,
        'owned': ['chair'],
        'placed': [
          {'id': 'chair', 'x': 0.3, 'y': 0.6, 'r': 1}
        ],
      }),
    });
    final migrated = await GameState.load();
    expect(migrated.coins, 120);
    expect(migrated.totalSteps, 9000);
    expect(migrated.todaySteps, 3000);
    expect(migrated.owned, {'chair'});
    expect(migrated.placed.single.rotation, 1);
    // Ижил алхам дахин ирэхэд coin давхар өгөхгүй.
    migrated.syncSteps({DateTime.now(): 3000});
    expect(migrated.coins, 120);
  });
}
