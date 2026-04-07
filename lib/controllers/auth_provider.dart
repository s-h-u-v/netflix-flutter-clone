import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  AuthUser({required this.uid, required this.email, required this.displayName});
}

class AuthProvider extends ChangeNotifier {
  AuthUser? _user;
  bool _isLoading = false;
  bool _isInitLoading = true;
  String _errorMessage = '';

  Map<String, String> _registeredUsers = {};
  Map<String, String> _userProfiles = {};

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitLoading => _isInitLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _initPersistentState();
  }

  Future<void> _initPersistentState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final usersJson = prefs.getString('registered_users');
    final profilesJson = prefs.getString('user_profiles');
    
    if (usersJson != null) {
      _registeredUsers = Map<String, String>.from(jsonDecode(usersJson));
    }
    if (profilesJson != null) {
      _userProfiles = Map<String, String>.from(jsonDecode(profilesJson));
    }

    final currentEmail = prefs.getString('current_user_email');
    if (currentEmail != null && _registeredUsers.containsKey(currentEmail)) {
      final displayName = _userProfiles[currentEmail] ?? 'Mock User';
      _user = AuthUser(uid: 'mock_uid_${currentEmail.hashCode}', email: currentEmail, displayName: displayName);
    }
    
    _isInitLoading = false;
    notifyListeners();
  }

  Future<void> _savePersistentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_users', jsonEncode(_registeredUsers));
    await prefs.setString('user_profiles', jsonEncode(_userProfiles));
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = '';
    await Future.delayed(const Duration(seconds: 1));

    if (!_registeredUsers.containsKey(email) || _registeredUsers[email] != password) {
      _errorMessage = 'invalid login credentials';
      _setLoading(false);
      return false;
    }

    final displayName = _userProfiles[email] ?? 'Mock User';
    _user = AuthUser(uid: 'mock_uid_${email.hashCode}', email: email, displayName: displayName);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);

    _setLoading(false);
    return true;
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _errorMessage = '';
    await Future.delayed(const Duration(seconds: 1));

    if (_registeredUsers.containsKey(email)) {
      _errorMessage = 'email already exists, try some other mail';
      _setLoading(false);
      return false;
    }

    _registeredUsers[email] = password;
    _userProfiles[email] = name;
    
    await _savePersistentState();
    
    _user = AuthUser(uid: 'mock_uid_${email.hashCode}', email: email, displayName: name);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);

    _setLoading(false);
    return true;
  }

  Future<void> signOut() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    notifyListeners();
  }
}
