import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

// ── Auth Status States ──────────────────────────
enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ── State ───────────────────────────────────
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _rememberMe = false;

  // ── Getters ─────────────────────────────────
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _status == AuthStatus.loading;

  // ─────────────────────────────────────────────
  // Sign In with Email / Connexion avec Email
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
      _setError('Login failed. Échec de la connexion.');
      return false;
    } on Exception catch (e) {
      _setError(_parseFirebaseError(e.toString()));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Register Patient / Inscription Patiente
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
      _setError(
        'Registration failed. / Échec de la création du compte.',
      );
      return false;
    } on Exception catch (e) {
      _setError(_parseFirebaseError(e.toString()));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Sign In with Google / Connexion avec Google
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
      // Cancelled by user / Annulé par l'utilisateur
      _setIdle();
      return false;
    } on Exception catch (e) {
      _setError(_parseFirebaseError(e.toString()));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Forgot Password → Admin Notification
  // Mot de passe oublié → Notification Admin
  // ─────────────────────────────────────────────
  Future<bool> requestPasswordResetToAdmin(String email) async {
    _setLoading();
    try {
      if (email.trim().isEmpty) {
        _setError(
          'Please enter your email. / Veuillez saisir votre e-mail.',
        );
        return false;
      }

      // Send notification to Admin in Firestore
      // Envoyer une notification à l'Admin dans Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'password_reset_request',
        'email': email.trim(),
        'read': false,
        'note':
            'Password reset request / Demande de réinitialisation du mot de passe',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setSuccess();
      return true;
    } on Exception catch (e) {
      _setError(_parseFirebaseError(e.toString()));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Load Current User / Charger l'utilisateur actuel
  // ─────────────────────────────────────────────
  Future<void> loadCurrentUser() async {
    _setLoading();
    try {
      _currentUser = await _authService.getCurrentUserModel();
      _setIdle();
    } on Exception {
      _currentUser = null;
      _setIdle();
    }
  }

  // ─────────────────────────────────────────────
  // Sign Out / Déconnexion
  // ─────────────────────────────────────────────
  Future<void> signOut() async {
    _setLoading();
    try {
      await _authService.signOut();
      _currentUser = null;
      _setIdle();
    } on Exception {
      _currentUser = null;
      _setIdle();
    }
  }

  // ─────────────────────────────────────────────
  // Remember Me / Se souvenir de moi
  // ─────────────────────────────────────────────
  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Clear Error / Effacer l'erreur
  // ─────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Firebase Error Parser (EN / FR)
  // ─────────────────────────────────────────────
  String _parseFirebaseError(String raw) {
    final msg = raw.toLowerCase();

    if (msg.contains('user-not-found') || msg.contains('no user record')) {
      return 'No account found with this email.\n'
          'Aucun compte trouvé avec cet e-mail.';
    }

    if (msg.contains('wrong-password') ||
        msg.contains('invalid-credential') ||
        msg.contains('invalid credential')) {
      return 'Incorrect password.\n'
          'Mot de passe incorrect.';
    }

    if (msg.contains('email-already-in-use')) {
      return 'This email is already in use.\n'
          'Cet e-mail est déjà utilisé.';
    }

    if (msg.contains('invalid-email')) {
      return 'Invalid email format.\n'
          'Format de l\'e-mail invalide.';
    }

    if (msg.contains('weak-password')) {
      return 'Password too weak. Minimum 6 characters.\n'
          'Mot de passe trop faible. Minimum 6 caractères.';
    }

    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please wait.\n'
          'Trop de tentatives. Veuillez patienter.';
    }

    if (msg.contains('network-request-failed') || msg.contains('network')) {
      return 'Check your internet connection.\n'
          'Vérifiez votre connexion internet.';
    }

    if (msg.contains('user-disabled')) {
      return 'This account is disabled. Contact the administrator.\n'
          'Ce compte est désactivé. Contactez l\'administrateur.';
    }

    if (msg.contains('operation-not-allowed')) {
      return 'Operation not allowed.\n'
          'Opération non autorisée.';
    }

    if (msg.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email via a different method.\n'
          'Un compte existe déjà avec cet e-mail via une autre méthode.';
    }

    if (msg.contains('requires-recent-login')) {
      return 'Please sign in again to continue.\n'
          'Veuillez vous reconnecter pour continuer.';
    }

    if (msg.contains('popup-closed-by-user') || msg.contains('cancelled')) {
      return 'Sign-in cancelled.\n'
          'Connexion annulée.';
    }

    // Unknown error / Erreur inconnue
    return 'An unexpected error occurred. Please try again.\n'
        'Une erreur inattendue s\'est produite. Réessayez.';
  }

  // ─────────────────────────────────────────────
  // Private State Helpers
  // ─────────────────────────────────────────────
  // ─────────────────────────────────────────────
  // Send Password Reset Email
  // Envoyer email de réinitialisation
  // ─────────────────────────────────────────────
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading();
    try {
      if (email.trim().isEmpty) {
        _setError('Please enter your email.');
        return false;
      }

      await _authService.sendPasswordResetEmail(email);
      _setSuccess();
      return true;
    } on Exception catch (e) {
      _setError(_parseFirebaseError(e.toString()));
      return false;
    }
  }

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
