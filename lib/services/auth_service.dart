import 'package:shared_preferences/shared_preferences.dart';
import 'package:ders_project/models/user.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  static const _kCurrentUsername = 'current_username';
  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  Future<void> init() async {
    await getCurrentUser();
  }

  Future<User?> getCurrentUser() async {
    if (currentUser.value != null) return currentUser.value;
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_kCurrentUsername);
    if (username == null) return null;
    final db = DatabaseHelper.instance;
    final user = await db.getUserByUsername(username);
    currentUser.value = user;
    return user;
  }

  Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentUsername, user.username);
    currentUser.value = user;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentUsername);
    currentUser.value = null;
  }
}

