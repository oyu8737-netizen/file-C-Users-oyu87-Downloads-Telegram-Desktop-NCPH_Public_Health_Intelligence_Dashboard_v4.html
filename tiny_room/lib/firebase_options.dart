// ⚠️ ЭНЭ ФАЙЛ ТҮР ЗУУРЫН.
//
// Firebase төслөө үүсгээд `flutterfire configure` тушаал ажиллуулахад
// энэ файл таны Firebase-ийн жинхэнэ тохиргоогоор автоматаар солигдоно.
// (Заавар: GUIDE_FIREBASE_MN.md)
//
// Солигдох хүртэл апп "offline горим"-оор ажиллана: алхам, coin, өрөө ажиллана,
// харин account, найзууд, admin статистик идэвхгүй байна.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
      'Firebase is not configured yet. Run `flutterfire configure`.');
}
