/// Алхалтын мэдээлэл хаанаас ирэхийг тодорхойлох interface.
///
/// LEVEL 1 (одоо): `GameState.addFakeSteps` — товч дарж алхам нэмнэ.
/// LEVEL 2 (дараа): `HealthStepService` — iPhone дээр HealthKit,
///                  Android дээр Health Connect-оос жинхэнэ алхам уншина.
///
/// GameState нь зөвхөн `syncTodaySteps(int)`-ийг л мэддэг тул
/// алхамын эх сурвалжийг солиход тоглоомын логик өөрчлөгдөхгүй.
abstract class StepService {
  /// Өнөөдрийн (00:00-оос хойших) нийт алхам.
  Future<int> getTodaySteps();
}

// ───────────────────────────────────────────────────────────────────
// LEVEL 2-т ашиглах жишээ (одоогоор comment-лосон):
//
// 1) pubspec.yaml-д нэмнэ:   health: ^13.0.0
// 2) iOS: Xcode → Signing & Capabilities → HealthKit асаах,
//    Info.plist-д NSHealthShareUsageDescription нэмэх.
// 3) Android: AndroidManifest.xml-д
//    <uses-permission android:name="android.permission.health.READ_STEPS"/>
//
// import 'package:health/health.dart';
//
// class HealthStepService implements StepService {
//   final Health _health = Health();
//
//   Future<bool> requestPermission() async {
//     await _health.configure();
//     return _health.requestAuthorization(
//       [HealthDataType.STEPS],
//       permissions: [HealthDataAccess.READ],
//     );
//   }
//
//   @override
//   Future<int> getTodaySteps() async {
//     final now = DateTime.now();
//     final midnight = DateTime(now.year, now.month, now.day);
//     return await _health.getTotalStepsInInterval(midnight, now) ?? 0;
//   }
// }
//
// Дараа нь HomeScreen дээр:
//   final steps = await HealthStepService().getTodaySteps();
//   game.syncTodaySteps(steps);
// ───────────────────────────────────────────────────────────────────
