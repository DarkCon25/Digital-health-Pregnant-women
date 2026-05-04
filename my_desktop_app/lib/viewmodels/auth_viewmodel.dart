import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ── State ──
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _rememberMe = false;

  // ── Getters ──
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _status == AuthStatus.loading;

  // ─────────────────────────────────────────────
  // LOGIN WITH EMAIL
  // ─────────────────────────────────────────────

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        _currentUser = user;
        _setSuccess();
        return true;
      }
      _setError('Login failed. Please try again.');
      return false;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────

  Future<bool> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? wilaya,
    DateTime? dateOfBirth,
  }) async {
    _setLoading();
    try {
      final user = await _authService.registerWithEmail(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        wilaya: wilaya,
        dateOfBirth: dateOfBirth,
      );
      if (user != null) {
        _currentUser = user;
        _setSuccess();
        return true;
      }
      _setError('Registration failed. Please try again.');
      return false;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ─────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _setSuccess();
        return true;
      }
      _setIdle();
      return false;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // LOAD CURRENT USER
  // ─────────────────────────────────────────────

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserModel();
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _setIdle();
    } catch (e) {
      _setError('Failed to sign out.');
    }
  }

  // ─────────────────────────────────────────────
  // REMEMBER ME
  // ─────────────────────────────────────────────

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // CLEAR ERROR
  // ─────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setIdle() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
