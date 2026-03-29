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
      return;
    }
    if (value == 'pro') {
      // v3.0: lock basic — migrate persisted pro → basic (Phase 14)
      state = AppMode.basic;
      await prefs.setString(_key, AppMode.basic.name);
      return;
    }
    state = AppMode.basic;
  }

  /// Pro mode is not user-accessible; keep API for dead code paths (e.g. ModeToggle).
  Future<void> toggle() async {
    state = AppMode.basic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AppMode.basic.name);
  }

  Future<void> setMode(AppMode mode) async {
    state = AppMode.basic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AppMode.basic.name);
    if (mode == AppMode.pro) {
      // Ignore request to enter pro — state stays basic (Phase 14)
    }
  }
}
