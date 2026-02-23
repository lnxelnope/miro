import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { basic, pro }

final appModeProvider = StateNotifierProvider<AppModeNotifier, AppMode>((ref) {
  return AppModeNotifier();
});

class AppModeNotifier extends StateNotifier<AppMode> {
  static const String _key = 'app_mode';

  AppModeNotifier() : super(AppMode.basic) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) {
      state = AppMode.basic;
    } else {
      state = value == 'pro' ? AppMode.pro : AppMode.basic;
    }
  }

  Future<void> toggle() async {
    final newMode = state == AppMode.basic ? AppMode.pro : AppMode.basic;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newMode.name);
  }

  Future<void> setMode(AppMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
