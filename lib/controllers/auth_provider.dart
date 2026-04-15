import 'package:flutter/material.dart';
import '../services/auth_db_service.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  AuthUser({required this.uid, required this.email, required this.displayName});
}

class AuthProvider extends ChangeNotifier {
  final AuthDbService _authDbService;
  AuthUser? _user;
  bool _isLoading = false;
  bool _isInitLoading = true;
  String _errorMessage = '';
  String _lastSuccessMessage = '';

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitLoading => _isInitLoading;
  String get errorMessage => _errorMessage;
  String get lastSuccessMessage => _lastSuccessMessage;

  AuthProvider({AuthDbService? authDbService})
    : _authDbService = authDbService ?? AuthDbService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final localUser = await _authDbService.getSignedInUser();
      _user = _mapLocalUser(localUser);
    } catch (_) {
      _errorMessage = 'Could not initialize local authentication.';
      _user = null;
    } finally {
      _isInitLoading = false;
      notifyListeners();
    }
  }

  AuthUser? _mapLocalUser(LocalAuthUser? localUser) {
    if (localUser == null) return null;

    return AuthUser(
      uid: localUser.id.toString(),
      email: localUser.email,
      displayName: localUser.displayName,
    );
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Email and password are required.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = '';

    try {
      final result = await _authDbService.signIn(
        email: email,
        password: password,
      );

      if (!result.isSuccess) {
        _errorMessage = result.error ?? 'Invalid email or password.';
        return false;
      }

      _user = _mapLocalUser(result.user);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Something went wrong while signing in.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Email and password are required.';
      notifyListeners();
      return false;
    }

    if (password.trim().length < 6) {
      _errorMessage = 'Password is too weak. Use at least 6 characters.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = '';

    try {
      final result = await _authDbService.signUp(
        email: email,
        password: password,
        displayName: name,
      );

      if (!result.isSuccess) {
        _errorMessage = result.error ?? 'Could not create account.';
        return false;
      }

      _user = _mapLocalUser(result.user);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Something went wrong while signing up.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authDbService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return false;
    if (newPassword.trim().length < 6) {
      _errorMessage = 'Password is too weak. Use at least 6 characters.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = '';
    _lastSuccessMessage = '';
    try {
      final ok = await _authDbService.changePasswordForActiveUser(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!ok) {
        _errorMessage = 'Current password is incorrect.';
        return false;
      }
      _lastSuccessMessage = 'Password updated.';
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Could not update password.';
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
