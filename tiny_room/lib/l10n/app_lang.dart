import 'package:flutter/material.dart';

/// Аппын хэлүүд. Хэл бүр өөрийн улсын "vibe"-тай: өнгө, өрөөний загвар, чимэглэл.
enum AppLang {
  mn('mn', '🇲🇳', 'Монгол'),
  en('en', '🇬🇧', 'English'),
  zh('zh', '🇨🇳', '中文');

  final String code;
  final String flag;
  final String label;
  const AppLang(this.code, this.flag, this.label);

  static AppLang fromCode(String? code) =>
      AppLang.values.firstWhere((l) => l.code == code, orElse: () => AppLang.mn);

  LangVibe get vibe => switch (this) {
        AppLang.mn => LangVibe.mongolia,
        AppLang.en => LangVibe.england,
        AppLang.zh => LangVibe.china,
      };
}

/// Нэг ханын чимэглэл (өрөөнд байнга харагдах, хөдөлгөх боломжгүй).
class WallDecor {
  final String emoji;
  final double x; // 0..1
  final double y; // 0..1
  final double size; // өрөөний өргөнтэй харьцуулсан хэмжээ
  const WallDecor(this.emoji, this.x, this.y, [this.size = 0.09]);
}

/// Улсын "мэдрэмж": аппын үндсэн өнгө, өрөөний хана/шал, цонхны гадна харагдах
/// зураг, хананы чимэглэл, хээ.
class LangVibe {
  /// Аппын бүх товч, цэсний үндсэн өнгө.
  final Color seed;
  final List<Color> wall;
  final List<Color> floor;

  /// Цонхоор харагдах байгаль.
  final String windowView;
  final List<WallDecor> decor;

  /// Хана, шалны заагт хээ (Монгол алхан хээ / Хятад 回纹) зурах эсэх.
  final Color? patternColor;

  /// Home дэлгэцийн мэндчилгээний хажуугийн эмодзи.
  final String greetingEmoji;

  const LangVibe({
    required this.seed,
    required this.wall,
    required this.floor,
    required this.windowView,
    required this.decor,
    required this.greetingEmoji,
    this.patternColor,
  });

  /// 🇲🇳 Мөнх хөх тэнгэр, гэрийн улаан-улбар хивс, алтан алхан хээ.
  static const mongolia = LangVibe(
    seed: Color(0xFF1565C0),
    wall: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    floor: [Color(0xFFC0592B), Color(0xFF8E3A1B)],
    windowView: '🏔️',
    decor: [
      WallDecor('🐎', 0.82, 0.22),
      WallDecor('🏹', 0.62, 0.14, 0.07),
    ],
    greetingEmoji: '🐎',
    patternColor: Color(0xFFFFC107),
  );

  /// 🇬🇧 Цайвар ногоон зуслангийн байшин, модон шал, цай, бороо.
  static const england = LangVibe(
    seed: Color(0xFF1B3A6B),
    wall: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],
    floor: [Color(0xFF8D6E63), Color(0xFF5D4037)],
    windowView: '🌧️',
    decor: [
      WallDecor('🫖', 0.80, 0.24),
      WallDecor('📮', 0.63, 0.20, 0.07),
    ],
    greetingEmoji: '☕',
  );

  /// 🇨🇳 Улаан-алтан өнгө, дэнлүү, хулс, 回纹 хээ.
  static const china = LangVibe(
    seed: Color(0xFFC62828),
    wall: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    floor: [Color(0xFFB71C1C), Color(0xFF7F0000)],
    windowView: '🎋',
    decor: [
      WallDecor('🏮', 0.60, 0.06),
      WallDecor('🏮', 0.84, 0.06),
      WallDecor('🧧', 0.72, 0.26, 0.07),
    ],
    greetingEmoji: '🏮',
    patternColor: Color(0xFFFFD54F),
  );
}
