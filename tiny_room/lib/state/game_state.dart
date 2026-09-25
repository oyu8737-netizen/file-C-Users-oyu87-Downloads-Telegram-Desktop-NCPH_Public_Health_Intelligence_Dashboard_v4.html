import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';

/// Алхалт 1 coin болох харьцаа: 100 алхам = 1 coin (8,000 алхам → 80 coin).
const int stepsPerCoin = 100;

/// Өдрийн зорилго. Үүнд хүрсэн өдөр streak-д тооцогдоно.
const int dailyStepGoal = 5000;

/// Нэг level ахихад шаардагдах алхам.
const int stepsPerLevel = 10000;

/// Тоглоомын бүх өгөгдөл ба логик энд байна.
/// UI нь зөвхөн эндээс уншаад, эндэх method-уудыг дуудна.
class GameState extends ChangeNotifier {
  static const _storageKey = 'tiny_room_state_v1';

  final SharedPreferences? _prefs;
  final DateTime Function() _clock;

  int coins = 0;
  int totalSteps = 0;
  int todaySteps = 0;

  /// Өнөөдөр алхалтаас аль хэдийн олгосон coin.
  /// Incremental reward: зөвхөн шинээр нэмэгдсэн алхамд coin өгнө.
  int coinsRewardedToday = 0;

  int streak = 0;
  String? lastGoalDate;
  late String todayDate;

  /// Туршилтад зориулж "маргааш" руу үсрэх (Level 1 prototype-д хэрэгтэй).
  int debugDayOffset = 0;

  final Set<String> owned = {};
  final List<PlacedItem> placed = [];

  GameState({SharedPreferences? prefs, DateTime Function()? clock})
      : _prefs = prefs,
        _clock = clock ?? DateTime.now {
    todayDate = _dateKey(_now());
  }

  static Future<GameState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = GameState(prefs: prefs);
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      state._fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    state._rollDayIfNeeded();
    return state;
  }

  // ───────────────────────── Алхалт → Coin ─────────────────────────

  /// Утаснаас (эсвэл fake товчноос) ирсэн "өнөөдрийн нийт алхам"-ыг хүлээж авна.
  /// HealthKit / Health Connect нь яг ийм байдлаар өдрийн нийлбэр буцаадаг.
  ///
  /// Буцаах утга: энэ удаад шинээр нээгдсэн тавилгууд.
  List<Furniture> syncTodaySteps(int stepsToday) {
    _rollDayIfNeeded();
    if (stepsToday <= todaySteps) return const [];

    final unlockedBefore = _unlockedIds();

    final newSteps = stepsToday - todaySteps;
    todaySteps = stepsToday;
    totalSteps += newSteps;

    // Өнөөдөр нийт хэдэн coin авах эрхтэй вэ − аль хэдийн авсан нь = шинэ coin.
    final earned = todaySteps ~/ stepsPerCoin - coinsRewardedToday;
    if (earned > 0) {
      coins += earned;
      coinsRewardedToday += earned;
    }

    _updateStreak();
    _save();
    notifyListeners();

    return furnitureCatalog
        .where((f) =>
            f.unlockType != UnlockType.none &&
            !unlockedBefore.contains(f.id) &&
            isUnlocked(f))
        .toList();
  }

  /// Level 1: жинхэнэ алхам биш, товч дарж алхам нэмнэ.
  List<Furniture> addFakeSteps(int steps) => syncTodaySteps(todaySteps + steps);

  void _updateStreak() {
    if (todaySteps < dailyStepGoal || lastGoalDate == todayDate) return;
    final yesterday = _dateKey(_now().subtract(const Duration(days: 1)));
    streak = lastGoalDate == yesterday ? streak + 1 : 1;
    lastGoalDate = todayDate;
  }

  /// Шинэ өдөр эхэлсэн бол өдрийн тоолуурыг тэглэнэ.
  void _rollDayIfNeeded() {
    final today = _dateKey(_now());
    if (today == todayDate) return;
    todayDate = today;
    todaySteps = 0;
    coinsRewardedToday = 0;
    final yesterday = _dateKey(_now().subtract(const Duration(days: 1)));
    if (lastGoalDate != yesterday) streak = 0;
    _save();
  }

  /// Туршилтын товч: нэг өдөр урагшлуулна.
  void debugNextDay() {
    debugDayOffset++;
    _rollDayIfNeeded();
    notifyListeners();
  }

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
    _save();
    notifyListeners();
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
    _save();
    notifyListeners();
  }

  void removeFromRoom(PlacedItem item) {
    placed.remove(item);
    _save();
    notifyListeners();
  }

  /// Чирж байх үед дуудагдана — хадгалахгүй, зөвхөн дэлгэц шинэчилнэ.
  void moveItem(PlacedItem item, double x, double y) {
    item.x = x.clamp(0.05, 0.95);
    item.y = y.clamp(0.1, 0.95);
    notifyListeners();
  }

  void rotateItem(PlacedItem item) {
    item.rotation = (item.rotation + 1) % 4;
    _save();
    notifyListeners();
  }

  /// Чирж дууссаны дараа хадгална.
  void commit() => _save();

  /// Бүгдийг эхнээс нь.
  void reset() {
    coins = 0;
    totalSteps = 0;
    todaySteps = 0;
    coinsRewardedToday = 0;
    streak = 0;
    lastGoalDate = null;
    debugDayOffset = 0;
    todayDate = _dateKey(_now());
    owned.clear();
    placed.clear();
    _save();
    notifyListeners();
  }

  // ───────────────────────── Хадгалах ─────────────────────────

  DateTime _now() => _clock().add(Duration(days: debugDayOffset));

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Set<String> _unlockedIds() =>
      furnitureCatalog.where(isUnlocked).map((f) => f.id).toSet();

  Map<String, dynamic> _toJson() => {
        'coins': coins,
        'totalSteps': totalSteps,
        'todaySteps': todaySteps,
        'coinsRewardedToday': coinsRewardedToday,
        'streak': streak,
        'lastGoalDate': lastGoalDate,
        'todayDate': todayDate,
        'debugDayOffset': debugDayOffset,
        'owned': owned.toList(),
        'placed': placed.map((p) => p.toJson()).toList(),
      };

  void _fromJson(Map<String, dynamic> j) {
    coins = j['coins'] as int? ?? 0;
    totalSteps = j['totalSteps'] as int? ?? 0;
    todaySteps = j['todaySteps'] as int? ?? 0;
    coinsRewardedToday = j['coinsRewardedToday'] as int? ?? 0;
    streak = j['streak'] as int? ?? 0;
    lastGoalDate = j['lastGoalDate'] as String?;
    todayDate = j['todayDate'] as String? ?? todayDate;
    debugDayOffset = j['debugDayOffset'] as int? ?? 0;
    owned
      ..clear()
      ..addAll((j['owned'] as List? ?? []).cast<String>());
    placed
      ..clear()
      ..addAll((j['placed'] as List? ?? [])
          .map((e) => PlacedItem.fromJson(e as Map<String, dynamic>)));
  }

  void _save() {
    _prefs?.setString(_storageKey, jsonEncode(_toJson()));
  }
}

/// Аль ч дэлгэцнээс `GameScope.of(context)` гэж GameState-д хандана.
class GameScope extends InheritedNotifier<GameState> {
  const GameScope({super.key, required GameState state, required super.child})
      : super(notifier: state);

  static GameState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;
}
