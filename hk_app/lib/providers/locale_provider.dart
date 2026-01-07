import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    final String? countryCode = prefs.getString('country_code');

    if (languageCode != null) {
      // Validate if the loaded language is supported
      if (['zh', 'en'].contains(languageCode)) {
        _locale = Locale(languageCode, countryCode);
      } else {
        // If not supported (e.g. was 'ja' but now removed), reset to null
        // so MaterialApp uses system default or fallback
        _locale = null;
        await prefs.remove('language_code');
        await prefs.remove('country_code');
      }
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    if (locale.countryCode != null) {
      await prefs.setString('country_code', locale.countryCode!);
    } else {
      await prefs.remove('country_code');
    }
  }

  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    await prefs.remove('country_code');
  }
}
