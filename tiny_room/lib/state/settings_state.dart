import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// Аппын тохиргоо: хэл, account-гүй үргэлжлүүлэх сонголт.
class SettingsState extends ChangeNotifier {
  static const _langKey = 'tiny_room_lang';
  static const _authSkippedKey = 'tiny_room_auth_skipped';

  final SharedPreferences? _prefs;
  bool mongolian;

  /// Нэвтрэх дэлгэц дээр "Account-гүй үргэлжлүүлэх" дарсан эсэх.
  bool authSkipped;

  SettingsState(
      {SharedPreferences? prefs, this.mongolian = true, this.authSkipped = false})
      : _prefs = prefs;

  static Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsState(
      prefs: prefs,
      mongolian: (prefs.getString(_langKey) ?? 'mn') == 'mn',
      authSkipped: prefs.getBool(_authSkippedKey) ?? false,
    );
  }

  void setAuthSkipped(bool value) {
    authSkipped = value;
    _prefs?.setBool(_authSkippedKey, value);
    notifyListeners();
  }

  void setMongolian(bool value) {
    if (value == mongolian) return;
    mongolian = value;
    _prefs?.setString(_langKey, value ? 'mn' : 'en');
    notifyListeners();
  }
}

/// `S.of(context)` гэж бичээд одоогийн хэлээрх текстийг авна.
class SettingsScope extends InheritedNotifier<SettingsState> {
  const SettingsScope(
      {super.key, required SettingsState state, required super.child})
      : super(notifier: state);

  static SettingsState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;

  static S strings(BuildContext context) => S(of(context).mongolian);
}
