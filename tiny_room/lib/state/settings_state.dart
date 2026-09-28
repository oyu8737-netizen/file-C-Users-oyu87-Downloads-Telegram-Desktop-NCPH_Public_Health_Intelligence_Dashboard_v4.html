import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// Аппын тохиргоо: хэл, цэс дэлгэсэн эсэх, account-гүй үргэлжлүүлэх сонголт.
class SettingsState extends ChangeNotifier {
  static const _langKey = 'tiny_room_lang';
  static const _authSkippedKey = 'tiny_room_auth_skipped';
  static const _menuExpandedKey = 'tiny_room_menu_expanded';

  final SharedPreferences? _prefs;

  /// 🇲🇳 / 🇬🇧 / 🇨🇳 — өнгө, өрөөний загвар ч мөн хамт солигдоно.
  AppLang lang;

  /// Нэвтрэх дэлгэц дээр "Account-гүй үргэлжлүүлэх" дарсан эсэх.
  bool authSkipped;

  /// Том дэлгэц дээрх хажуугийн цэс дэлгэгдсэн (нэртэй) эсэх.
  bool menuExpanded;

  SettingsState({
    SharedPreferences? prefs,
    this.lang = AppLang.mn,
    this.authSkipped = false,
    this.menuExpanded = true,
  }) : _prefs = prefs;

  static Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsState(
      prefs: prefs,
      lang: AppLang.fromCode(prefs.getString(_langKey)),
      authSkipped: prefs.getBool(_authSkippedKey) ?? false,
      menuExpanded: prefs.getBool(_menuExpandedKey) ?? true,
    );
  }

  void setLang(AppLang value) {
    if (value == lang) return;
    lang = value;
    _prefs?.setString(_langKey, value.code);
    notifyListeners();
  }

  void setAuthSkipped(bool value) {
    authSkipped = value;
    _prefs?.setBool(_authSkippedKey, value);
    notifyListeners();
  }

  void toggleMenu() {
    menuExpanded = !menuExpanded;
    _prefs?.setBool(_menuExpandedKey, menuExpanded);
    notifyListeners();
  }
}

/// `SettingsScope.strings(context)` → одоогийн хэлээрх текст.
/// `SettingsScope.vibe(context)` → одоогийн хэлний улсын өнгө, чимэглэл.
class SettingsScope extends InheritedNotifier<SettingsState> {
  const SettingsScope(
      {super.key, required SettingsState state, required super.child})
      : super(notifier: state);

  static SettingsState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;

  static S strings(BuildContext context) => S(of(context).lang);

  static LangVibe vibe(BuildContext context) => of(context).lang.vibe;
}
