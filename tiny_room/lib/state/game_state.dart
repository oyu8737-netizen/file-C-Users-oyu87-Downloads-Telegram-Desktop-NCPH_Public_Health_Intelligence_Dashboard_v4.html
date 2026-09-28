import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';

// ───────────────────────── Тоглоомын дүрэм ─────────────────────────
// Эдгээр тоог өөрчилбөл бүх апп даяар дүрэм өөрчлөгдөнө.

/// 100 алхам = 1 coin (8,000 алхам → 80 coin).
const int stepsPerCoin = 100;

/// Өдрийн зорилго. Үүнд хүрсэн өдөр streak-д тооцогдоно.
const int dailyStepGoal = 5000;

/// Өдрийн зорилгодоо хүрэхэд өгөх bonus coin.
const int goalBonusCoins = 20;

/// Streak-ийн өдөр бүрт нэмэлт bonus: streak × 5 (дээд тал нь 50).
const int streakBonusPerDay = 5;
const int streakBonusCap = 50;

/// Нэг level ахихад шаардагдах алхам.
const int stepsPerLevel = 10000;

/// Хэдэн өдрийн түүх хадгалах вэ.
const int historyDays = 60;

/// Нэг өдрийн бүртгэл.
class DayRecord {
  int steps;

  /// Энэ өдрийн алхмаас аль хэдийн олгосон coin (давхар өгөхгүйн тулд).
  int coinsFromSteps;

  /// Өдрийн зорилгын bonus олгосон эсэх.
  bool goalBonusGiven;

  DayRecord({this.steps = 0, this.coinsFromSteps = 0, this.goalBonusGiven = false});

  bool get goalReached => steps >= dailyStepGoal;

  Map<String, dynamic> toJson() =>
      {'s': steps, 'c': coinsFromSteps, 'g': goalBonusGiven};

  factory DayRecord.fromJson(Map<String, dynamic> j) => DayRecord(
        steps: (j['s'] as num?)?.toInt() ?? 0,
        coinsFromSteps: (j['c'] as num?)?.toInt() ?? 0,
        goalBonusGiven: j['g'] as bool? ?? false,
      );
}

/// Нэг удаагийн алхам шинэчлэлтээр юу олж авсныг UI-д мэдэгдэх.
class SyncResult {
  int newSteps = 0;
  int stepCoins = 0;
  int goalBonus = 0;
  int streakBonus = 0;
  final List<Furniture> unlocked = [];

  int get totalCoins => stepCoins + goalBonus + streakBonus;
  bool get isEmpty => newSteps == 0;
}

/// Тоглоомын бүх өгөгдөл ба логик энд байна.
/// UI нь зөвхөн эндээс уншаад, эндэх method-уудыг дуудна.
class GameState extends ChangeNotifier {
  static const _storageKey = 'tiny_room_state_v2';
  static const _legacyKey = 'tiny_room_state_v1';

  final SharedPreferences? _prefs;
  final DateTime Function() _clock;

  int coins = 0;
  int totalSteps = 0;

  /// Өдөр бүрийн алхам. Түлхүүр нь 'yyyy-mm-dd'.
  final Map<String, DayRecord> days = {};

  /// Туршилтад зориулж "маргааш" руу үсрэх.
  int debugDayOffset = 0;

  final Set<String> owned = {};
  final List<PlacedItem> placed = [];

  /// Сүүлд өөрчлөгдсөн цаг (cloud-тай харьцуулахад).
  int updatedAt = 0;

  GameState({SharedPreferences? prefs, DateTime Function()? clock})
      : _prefs = prefs,
        _clock = clock ?? DateTime.now;

  static Future<GameState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = GameState(prefs: prefs);
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      state.loadJson(jsonDecode(raw) as Map<String, dynamic>, save: false);
    } else {
      state._migrateV1(prefs.getString(_legacyKey));
    }
    return state;
  }

  // ───────────────────────── Огноо ─────────────────────────

  DateTime now() => _clock().add(Duration(days: debugDayOffset));

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get todayKey => dateKey(now());

  int get todaySteps => days[todayKey]?.steps ?? 0;

  // ───────────────────────── Алхам → Coin ─────────────────────────

  /// Алхмын эх сурвалжаас (HealthKit, Health Connect, мэдрэгч, туршилтын товч)
  /// ирсэн "тухайн өдрийн нийт алхам"-ыг хүлээж авна.
  ///
  /// Олон өдрийг зэрэг өгч болно: жишээ нь аппаа 3 хоног нээгээгүй байсан ч
  /// утас алхмыг чинь тоолсон тул тэр өдрүүдийн coin, streak алдагдахгүй.
  SyncResult syncSteps(Map<DateTime, int> stepsPerDay) {
    final result = SyncResult();
    final unlockedBefore = _unlockedIds();
    final today = DateTime(now().year, now().month, now().day);

    final entries = stepsPerDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // хуучин өдрөөс эхэлнэ

    for (final e in entries) {
      final day = DateTime(e.key.year, e.key.month, e.key.day);
      if (day.isAfter(today) || today.difference(day).inDays >= historyDays) {
        continue;
      }
      final rec = days.putIfAbsent(dateKey(day), DayRecord.new);
      // Алхам буурахгүй. Ижил тоо дахин ирвэл юу ч хийхгүй.
      if (e.value <= rec.steps) continue;

      final added = e.value - rec.steps;
      rec.steps = e.value;
      totalSteps += added;
      result.newSteps += added;

      // Тухайн өдөр нийт авах ёстой coin − аль хэдийн авсан = шинэ coin.
      final earned = rec.steps ~/ stepsPerCoin - rec.coinsFromSteps;
      if (earned > 0) {
        rec.coinsFromSteps += earned;
        coins += earned;
        result.stepCoins += earned;
      }

      // Өдрийн зорилгод анх хүрэхэд: bonus + streak bonus.
      if (rec.goalReached && !rec.goalBonusGiven) {
        rec.goalBonusGiven = true;
        final streakThatDay = _streakEndingAt(day);
        final sBonus =
            math.min(streakThatDay * streakBonusPerDay, streakBonusCap);
        coins += goalBonusCoins + sBonus;
        result.goalBonus += goalBonusCoins;
        result.streakBonus += sBonus;
      }
    }

    if (result.isEmpty) return result;

    _trimHistory();
    result.unlocked.addAll(furnitureCatalog.where((f) =>
        f.unlockType != UnlockType.none &&
        !unlockedBefore.contains(f.id) &&
        isUnlocked(f)));
    _changed();
    return result;
  }

  /// Туршилтын товч: өнөөдрийн алхамд нэмнэ.
  SyncResult addFakeSteps(int steps) =>
      syncSteps({now(): todaySteps + steps});

  /// Туршилтын товч: нэг өдөр урагшлуулна.
  void debugNextDay() {
    debugDayOffset++;
    _changed();
  }

  // ───────────────────────── Streak ─────────────────────────

  /// [day]-аар дуусах, зорилгодоо хүрсэн дараалсан өдрийн тоо.
  int _streakEndingAt(DateTime day) {
    var count = 0;
    var d = day;
    while (days[dateKey(d)]?.goalReached ?? false) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Одоогийн streak. Өнөөдөр зорилгодоо хүрээгүй ч өчигдөр хүрсэн бол
  /// streak тасраагүй гэж үзнэ (өдөр дуустал хугацаа бий).
  int get streak {
    final today = now();
    if (days[dateKey(today)]?.goalReached ?? false) {
      return _streakEndingAt(today);
    }
    return _streakEndingAt(today.subtract(const Duration(days: 1)));
  }

  /// Сүүлийн [n] өдрийн алхам (хуучнаас шинэ рүү). Profile-ийн график.
  List<MapEntry<DateTime, int>> recentDays(int n) {
    final today = now();
    return [
      for (var i = n - 1; i >= 0; i--)
        () {
          final d = today.subtract(Duration(days: i));
          return MapEntry(d, days[dateKey(d)]?.steps ?? 0);
        }(),
    ];
  }

  /// Зорилгодоо хүрсэн нийт өдөр.
  int get activeDays => days.values.where((d) => d.goalReached).length;

  // ───────────────────────── Level / Score ─────────────────────────

  int get level => 1 + totalSteps ~/ stepsPerLevel;
  double get levelProgress => (totalSteps % stepsPerLevel) / stepsPerLevel;
  double get dailyProgress => (todaySteps / dailyStepGoal).clamp(0.0, 1.0);

  /// Өрөөнд байрлуулсан тавилга / бүх тавилга.
  double get roomScore => placed.length / furnitureCatalog.length;

  // ───────────────────────── Дэлгүүр ─────────────────────────

  bool isUnlocked(Furniture f) {
    switch (f.unlockType) {
      case UnlockType.none:
        return true;
      case UnlockType.streak:
        return streak >= f.unlockValue;
      case UnlockType.totalSteps:
        return totalSteps >= f.unlockValue;
      case UnlockType.level:
        return level >= f.unlockValue;
    }
  }

  bool isOwned(Furniture f) => owned.contains(f.id);

  bool canBuy(Furniture f) =>
      !isOwned(f) && isUnlocked(f) && coins >= f.price;

  bool buy(Furniture f) {
    if (!canBuy(f)) return false;
    coins -= f.price;
    owned.add(f.id);
    _changed();
    return true;
  }

  // ───────────────────────── Өрөө засах ─────────────────────────

  bool isPlaced(String furnitureId) =>
      placed.any((p) => p.furnitureId == furnitureId);

  /// Худалдаж авсан ч өрөөнд хараахан тавиагүй тавилгууд.
  List<Furniture> get inventory => furnitureCatalog
      .where((f) => owned.contains(f.id) && !isPlaced(f.id))
      .toList();

  void placeItem(String furnitureId) {
    if (!owned.contains(furnitureId) || isPlaced(furnitureId)) return;
    placed.add(PlacedItem(furnitureId: furnitureId));
    _changed();
  }

  void removeFromRoom(PlacedItem item) {
    placed.remove(item);
    _changed();
  }

  /// Чирж байх үед дуудагдана — хадгалахгүй, зөвхөн дэлгэц шинэчилнэ.
  void moveItem(PlacedItem item, double x, double y) {
    item.x = x.clamp(0.05, 0.95);
    item.y = y.clamp(0.1, 0.95);
    notifyListeners();
  }

  void rotateItem(PlacedItem item) {
    item.rotation = (item.rotation + 1) % 4;
    _changed();
  }

  /// Тавилгын өнгө солих. null бол анхны өнгө рүү буцна.
  void setItemColor(PlacedItem item, int? color) {
    item.color = color;
    _changed();
  }

  /// Чирж дууссаны дараа хадгална.
  void commit() => _changed();

  /// Бүгдийг эхнээс нь.
  void reset() {
    coins = 0;
    totalSteps = 0;
    days.clear();
    debugDayOffset = 0;
    owned.clear();
    placed.clear();
    _changed();
  }

  // ───────────────────────── Хадгалах ─────────────────────────

  Set<String> _unlockedIds() =>
      furnitureCatalog.where(isUnlocked).map((f) => f.id).toSet();

  void _trimHistory() {
    final oldest = dateKey(now().subtract(const Duration(days: historyDays)));
    days.removeWhere((k, _) => k.compareTo(oldest) < 0);
  }

  void _changed() {
    updatedAt = DateTime.now().millisecondsSinceEpoch;
    _prefs?.setString(_storageKey, jsonEncode(toJson()));
    notifyListeners();
  }

  /// Бүх өгөгдлийг JSON болгох (утсан дээр болон cloud-д хадгалахад).
  Map<String, dynamic> toJson() => {
        'coins': coins,
        'totalSteps': totalSteps,
        'days': days.map((k, v) => MapEntry(k, v.toJson())),
        'debugDayOffset': debugDayOffset,
        'owned': owned.toList(),
        'placed': placed.map((p) => p.toJson()).toList(),
        'updatedAt': updatedAt,
      };

  void loadJson(Map<String, dynamic> j, {bool save = true}) {
    coins = (j['coins'] as num?)?.toInt() ?? 0;
    totalSteps = (j['totalSteps'] as num?)?.toInt() ?? 0;
    days
      ..clear()
      ..addAll(((j['days'] as Map?) ?? {}).map((k, v) => MapEntry(
          k as String, DayRecord.fromJson(Map<String, dynamic>.from(v as Map)))));
    debugDayOffset = (j['debugDayOffset'] as num?)?.toInt() ?? 0;
    owned
      ..clear()
      ..addAll(((j['owned'] as List?) ?? []).cast<String>());
    placed
      ..clear()
      ..addAll(((j['placed'] as List?) ?? []).map(
          (e) => PlacedItem.fromJson(Map<String, dynamic>.from(e as Map))));
    placed.removeWhere((p) => furnitureById(p.furnitureId) == null);
    updatedAt = (j['updatedAt'] as num?)?.toInt() ?? 0;
    if (save) {
      _prefs?.setString(_storageKey, jsonEncode(toJson()));
    }
    notifyListeners();
  }

  /// Өөр төхөөрөмж дээр нэвтрэхэд: cloud-оос ирсэн өгөгдлийг үндэс болгоод,
  /// энэ төхөөрөмж дээр байсан ч cloud-д хараахан ороогүй зүйлсийг нэмнэ.
  ///
  /// - Өрөө, coin, streak → cloud-ынх (таны account-ын жинхэнэ хувилбар)
  /// - Энэ утсан дээр тоологдсон илүү алхам → нэмэгдэж, coin нь олгогдоно
  ///   (өдөр бүрээр харьцуулдаг тул нэг алхамд хоёр удаа coin өгөхгүй)
  /// - Энэ утсан дээр авсан тавилга → алга болохгүй
  void mergeRemote(Map<String, dynamic> remote) {
    final localSteps = {
      for (final e in days.entries) DateTime.parse(e.key): e.value.steps
    };
    final localOwned = {...owned};
    final localPlaced = [...placed];

    loadJson(remote, save: false);

    owned.addAll(localOwned);
    if (placed.isEmpty) placed.addAll(localPlaced);
    syncSteps(localSteps);
    _changed();
  }

  /// Өмнөх (LEVEL 1) хувилбарын өгөгдлийг шинэ бүтэц рүү шилжүүлэх.
  void _migrateV1(String? raw) {
    if (raw == null) return;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final today = j['todayDate'] as String?;
    final todaySteps = (j['todaySteps'] as num?)?.toInt() ?? 0;
    loadJson({
      ...j,
      'days': {
        if (today != null && todaySteps > 0)
          today: {
            's': todaySteps,
            'c': (j['coinsRewardedToday'] as num?)?.toInt() ?? 0,
            'g': todaySteps >= dailyStepGoal,
          },
      },
    });
  }
}

/// Аль ч дэлгэцнээс `GameScope.of(context)` гэж GameState-д хандана.
class GameScope extends InheritedNotifier<GameState> {
  const GameScope({super.key, required GameState state, required super.child})
      : super(notifier: state);

  static GameState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;
}
