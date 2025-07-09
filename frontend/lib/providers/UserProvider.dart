import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLoggedIn => _user != null;

  // Set user after login or profile update
  Future<void> setUser(Map<String, dynamic> userData) async {
    _user = userData;
    notifyListeners();
    await _saveUserToPrefs(userData);
  }

  // Clear user on logout
  Future<void> logout() async {
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  // Save user data to local storage
  Future<void> _saveUserToPrefs(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(userData));
  }

  // Load user data at app startup
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = jsonDecode(userData);
      notifyListeners();
    }
  }
}
