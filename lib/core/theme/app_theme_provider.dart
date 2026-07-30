import 'package:flutter/material.dart';

class AppThemeNotifier extends ValueNotifier<ThemeMode> {
  AppThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    if (value == ThemeMode.light) {
      value = ThemeMode.dark;
    } else {
      value = ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) {
    value = mode;
  }
}

final appThemeNotifier = AppThemeNotifier();
