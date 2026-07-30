import 'package:flutter/material.dart';

class AppLanguageNotifier extends ValueNotifier<Locale> {
  AppLanguageNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    if (value != locale) {
      value = locale;
    }
  }

  void toggleLanguage() {
    if (value.languageCode == 'en') {
      value = const Locale('fr');
    } else {
      value = const Locale('en');
    }
  }
}

final appLanguageNotifier = AppLanguageNotifier();
