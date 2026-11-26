import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import '../database/database_helper.dart';

class AppState extends ChangeNotifier {
  final db = DatabaseHelper.instance;

  User? user;
  ThemeMode themeMode = ThemeMode.system;
  bool _ready = false;

  bool get ready => _ready;
  bool get loggedIn => user != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('theme_mode') ?? 'auto';
    themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final id = prefs.getInt('user_id');
    if (id != null) {
      user = await db.userById(id);
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _setUserId(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove('user_id');
    } else {
      await prefs.setInt('user_id', id);
    }
  }

  Future<void> login(String email, String password) async {
    user = await db.login(email, password);
    await _setUserId(user!.id);
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    user = await db.signup(name, email, password);
    await _setUserId(user!.id);
    notifyListeners();
  }

  void logout() {
    user = null;
    _setUserId(null);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'auto',
    });
    notifyListeners();
  }

  Future<void> recordSort(String wasteType) async {
    await db.recordSort(user!.id!, wasteType);
    await refresh();
  }

  Future<void> refresh() async {
    user = await db.userById(user!.id!);
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    await db.updateName(user!.id!, name);
    await refresh();
  }

  Future<void> resetProgress() async {
    await db.resetProgress(user!.id!);
    await refresh();
  }
}
