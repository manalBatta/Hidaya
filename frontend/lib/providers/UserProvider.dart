import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _sessionId;

  // Chat session initialization flag
  bool _chatInitialized = false;
  bool get chatInitialized => _chatInitialized;
  void setChatInitialized(bool value) {
    _chatInitialized = value;
    notifyListeners();
  }

  Map<String, dynamic>? get user => _user;
  String? get sessionId => _sessionId;

  String get userId => _user?['id']?.toString() ?? '';

  bool get isLoggedIn => _user != null;

  // Add this field to store chat messages globally
  List<dynamic> _messages = [];
  List<dynamic> get messages => _messages;

  void addMessage(dynamic message) {
    _messages.add(message);
    notifyListeners();
  }

  void setMessages(List<dynamic> messages) {
    _messages = messages;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Set user after login or profile update
  Future<void> setUser(
    Map<String, dynamic> userData, {
    String? sessionId,
  }) async {
    print("setUser called with: $userData");
    _user = userData;
    if (sessionId != null) {
      _sessionId = sessionId;
    }
    print("User set, isLoggedIn: $isLoggedIn");
    notifyListeners();
    print("Listeners notified");
    await _saveUserToPrefs(userData);
    print("User saved to prefs");
    final prefs = await SharedPreferences.getInstance();
    if (_sessionId != null) {
      await prefs.setString('sessionId', _sessionId!);
    }
  }

  void setSessionId(String sessionId) async {
    _sessionId = sessionId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', sessionId);
  }

  // Clear user on logout
  Future<void> logout() async {
    _user = null;
    _sessionId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    prefs.remove('sessionId');
    setChatInitialized(true);
  }

  // Add a question to savedQuestions and persist
  void toggleSavedQuestion(String questionId) {
    if (_user == null) return;
    _user!["savedQuestions"] ??= [];
    final saved = _user!["savedQuestions"] as List;
    if (saved.contains(questionId)) {
      saved.remove(questionId);
    } else {
      saved.add(questionId);
    }
    notifyListeners();
    _saveUserToPrefs(_user!);
  }

  // Getter for savedQuestions
  List<String> get savedQuestions {
    if (_user == null) return [];
    return List<String>.from(_user!["savedQuestions"] ?? []);
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
    final sessionId = prefs.getString('sessionId');
    if (userData != null) {
      _user = jsonDecode(userData);
      _sessionId = sessionId;
      notifyListeners();
    }
  }
}
