import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluxter/features/auth/domain/token.dart';
import 'package:fluxter/features/auth/domain/user.dart';

part '../../gen/core/storage/local_storage.g.dart';

class LocalStorage {
  static late final LocalStorage _instance;
  static LocalStorage get instance => _instance;

  final SharedPreferences _prefs;

  LocalStorage._(this._prefs);

  /// Inits and returns the LocalStorage instance.
  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorage._(prefs);
    return _instance;
  }

  // ── Token ─────────────────────────────────────────
  static const _tokenKey = 'TOKEN_KEY';

  Token? get token {
    final jsonString = _prefs.getString(_tokenKey);
    if (jsonString == null) return null;
    return Token.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<void> saveToken(Token token) =>
      _prefs.setString(_tokenKey, jsonEncode(token.toJson()));

  // ── User ──────────────────────────────────────────
  static const _userKey = 'USER_KEY';

  User? get user {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null) return null;
    return User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  bool get isLoggedIn => user != null;

  // ── Dark Mode ─────────────────────────────────────
  static const _darkModeKey = 'DARK_MODE_KEY';

  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> saveDarkMode(bool isDark) =>
      _prefs.setBool(_darkModeKey, isDark);

  // ── Locale ────────────────────────────────────────
  static const _localeKey = 'LOCALE_KEY';

  String get localeCode => _prefs.getString(_localeKey) ?? 'en';

  Future<void> saveLocale(String localeCode) =>
      _prefs.setString(_localeKey, localeCode);

  // ── Clear ─────────────────────────────────────────
  Future<void> clear() async {
    await _prefs.clear();
  }
}

@Riverpod(keepAlive: true)
LocalStorage localStorage(Ref ref) => LocalStorage.instance;
