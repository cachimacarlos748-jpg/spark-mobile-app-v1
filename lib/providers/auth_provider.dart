import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  Future<void> loginWithGoogle(String name, String email, String id) async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    _userId = id;

    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userId', id);

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _userId = null;

    await prefs.clear();
    notifyListeners();
  }
}
