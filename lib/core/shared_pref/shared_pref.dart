import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance =
      SharedPreferencesHelper._internal();
  SharedPreferences? _prefs;

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._internal();

  /// Initialize SharedPreferences (Call this once in main.dart)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save data
  Future<void> saveData(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get data
  String? getData(String key) {
    return _prefs?.getString(key);
  }

  /// Remove data
  Future<void> removeData(String key) async {
    log("removing data: $key");
    final isCleared = await _prefs?.remove(key);

    log("data removed: $isCleared");
    await _prefs?.clear();
  }
}
