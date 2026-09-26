import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/game_state.dart';

/// Алхам хаанаас ирж байна вэ.
enum StepSource {
  /// Вэб / компьютер — автомат алхам байхгүй, туршилтын товч ашиглана.
  none,

  /// iPhone: Apple Health (HealthKit). Android: Health Connect.
  /// Утас өөрөө өдөржин тоолдог тул апп хаалттай байсан ч алхам алдагдахгүй.
  health,

  /// Health Connect байхгүй Android: утасны алхмын мэдрэгч.
  /// Апп нээлттэй үед л тоолно.
  sensor,
}

enum StepStatus { starting, unsupported, needsPermission, ready, error }

/// Утаснаас алхам уншиж GameState руу дамжуулна.
///
/// GameState нь зөвхөн "тухайн өдрийн нийт алхам"-ыг хүлээж авдаг тул
/// алхмын эх сурвалж солигдоход тоглоомын логик өөрчлөгдөхгүй.
class StepSync extends ChangeNotifier with WidgetsBindingObserver {
  final GameState game;

  /// Шинэ coin авах бүрд дуудагдана (Home дэлгэц мэдэгдэл харуулна).
  void Function(SyncResult result)? onReward;

  StepSource source = StepSource.none;
  StepStatus status = StepStatus.starting;
  DateTime? lastSync;

  /// Android: Health Connect суулгах/шинэчлэх боломжтой эсэх.
  bool canInstallHealthConnect = false;

  final Health _health = Health();
  Timer? _timer;
  StreamSubscription<StepCount>? _pedometerSub;
  SharedPreferences? _prefs;

  static const _iosAuthorizedKey = 'steps_ios_authorized';
  static const _pedoDateKey = 'pedo_date';
  static const _pedoBaseKey = 'pedo_base';
  static const _pedoLastKey = 'pedo_last';

  /// Health-ээс хэдэн өдрийн түүх татах вэ.
  static const _daysToFetch = 7;

  StepSync(this.game);

  static bool get platformSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  Future<void> start() async {
    if (!platformSupported) {
      _set(StepStatus.unsupported);
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    _prefs = await SharedPreferences.getInstance();
    try {
      await _health.configure();
      if (Platform.isIOS) {
        source = StepSource.health;
        // iOS нь "уншихыг зөвшөөрсөн үү" гэдгийг нууцалдаг тул
        // өмнө нь зөвшөөрөл асуусан эсэхийг өөрсдөө тэмдэглэнэ.
        _set(_prefs!.getBool(_iosAuthorizedKey) == true
            ? StepStatus.ready
            : StepStatus.needsPermission);
      } else {
        final sdk = await _health.getHealthConnectSdkStatus();
        canInstallHealthConnect = sdk != HealthConnectSdkStatus.sdkAvailable;
        if (sdk == HealthConnectSdkStatus.sdkAvailable) {
          source = StepSource.health;
          final ok = await _health.hasPermissions([HealthDataType.STEPS],
                  permissions: [HealthDataAccess.READ]) ??
              false;
          _set(ok ? StepStatus.ready : StepStatus.needsPermission);
        } else {
          source = StepSource.sensor;
          final granted = await Permission.activityRecognition.isGranted;
          _set(granted ? StepStatus.ready : StepStatus.needsPermission);
        }
      }
    } catch (e) {
      debugPrint('StepSync.start: $e');
      _set(StepStatus.error);
      return;
    }
    if (status == StepStatus.ready) await _begin();
    // Апп нээлттэй байх үед 2 минут тутамд шинэчилнэ.
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => refresh());
  }

  /// "Алхам холбох" товч дарахад: зөвшөөрөл асууна.
  Future<void> connect() async {
    if (!platformSupported) return;
    try {
      if (source == StepSource.health) {
        if (Platform.isAndroid) {
          await Permission.activityRecognition.request();
        }
        final granted = await _health.requestAuthorization(
            [HealthDataType.STEPS],
            permissions: [HealthDataAccess.READ]);
        if (Platform.isIOS) await _prefs?.setBool(_iosAuthorizedKey, true);
        _set(granted || Platform.isIOS
            ? StepStatus.ready
            : StepStatus.needsPermission);
      } else if (source == StepSource.sensor) {
        final result = await Permission.activityRecognition.request();
        _set(result.isGranted ? StepStatus.ready : StepStatus.needsPermission);
      }
    } catch (e) {
      debugPrint('StepSync.connect: $e');
      _set(StepStatus.error);
    }
    if (status == StepStatus.ready) await _begin();
  }

  /// Android: Play Store-оос Health Connect суулгах.
  Future<void> installHealthConnect() => _health.installHealthConnect();

  Future<void> _begin() async {
    if (source == StepSource.sensor) {
      _pedometerSub ??= Pedometer.stepCountStream.listen(_onSensorSteps,
          onError: (e) {
        debugPrint('Pedometer: $e');
        _set(StepStatus.error);
      });
    } else {
      await refresh();
    }
  }

  /// Health-ээс сүүлийн 7 хоногийн алхмыг уншина.
  Future<void> refresh() async {
    if (status != StepStatus.ready || source != StepSource.health) return;
    try {
      final now = DateTime.now();
      final perDay = <DateTime, int>{};
      for (var i = 0; i < _daysToFetch; i++) {
        final dayStart = DateTime(now.year, now.month, now.day - i);
        final dayEnd = i == 0 ? now : DateTime(now.year, now.month, now.day - i + 1);
        // Гараар оруулсан алхмыг тооцохгүй — зөвхөн утас/цагны тоолсон алхам.
        final steps = await _health.getTotalStepsInInterval(dayStart, dayEnd,
            includeManualEntry: false);
        if (steps != null && steps > 0) perDay[dayStart] = steps;
      }
      _apply(perDay);
    } catch (e) {
      debugPrint('StepSync.refresh: $e');
    }
  }

  /// Утасны мэдрэгч: утас асснаас хойшхи нийт алхмыг өгдөг.
  /// Өнөөдрийн алхам = одоогийн тоо − өдрийн эхний тоо.
  void _onSensorSteps(StepCount event) {
    final prefs = _prefs;
    if (prefs == null) return;
    final count = event.steps;
    final today = GameState.dateKey(DateTime.now());
    var base = prefs.getInt(_pedoBaseKey) ?? count;
    final last = prefs.getInt(_pedoLastKey) ?? count;

    if (prefs.getString(_pedoDateKey) != today) {
      base = count; // шинэ өдөр
    } else if (count < last) {
      base = count - (last - base); // утас унтарч асчээ
    }
    prefs
      ..setString(_pedoDateKey, today)
      ..setInt(_pedoBaseKey, base)
      ..setInt(_pedoLastKey, count);
    _apply({DateTime.now(): count - base});
  }

  void _apply(Map<DateTime, int> perDay) {
    final result = game.syncSteps(perDay);
    lastSync = DateTime.now();
    notifyListeners();
    if (!result.isEmpty) onReward?.call(result);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Аппыг дахин нээхэд шууд шинэчилнэ.
    if (state == AppLifecycleState.resumed) refresh();
  }

  void _set(StepStatus s) {
    status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pedometerSub?.cancel();
    if (platformSupported) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
