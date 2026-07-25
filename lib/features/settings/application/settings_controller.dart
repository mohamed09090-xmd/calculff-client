import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('ar'));

  void setLocale(String code) {
    if (code == 'ar' || code == 'fr') {
      state = Locale(code);
    }
  }
}

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => state = mode;
}
