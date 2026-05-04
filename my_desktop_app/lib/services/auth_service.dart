import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user
  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────
  // EMAIL / PASSWORD LOGIN
  // ─────────────────────────────────────────────

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) return null;

      return await _firestoreService.getUser(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER WITH EMAIL / PASSWORD
  // ─────────────────────────────────────────────

  Future<UserModel?> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? wilaya,
    DateTime? dateOfBirth,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // Update display name
      await firebaseUser.updateDisplayName('$firstName $lastName');

      // Create user model
      final userModel = UserModel(
        uid: firebaseUser.uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        role: AppConstants.defaultRole,
        phone: phone?.trim(),
        wilaya: wilaya,
        dateOfBirth: dateOfBirth,
        createdAt: DateTime.now(),
      );

      // Store in Firestore (NO password stored)
      await _firestoreService.createUser(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ─────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ─────────────────────────────────────────────

  // ✅ الكود الصحيح
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user; // ✅ مباشرة بدون extension

      if (firebaseUser == null) return null;

      final exists = await _firestoreService.userExists(firebaseUser.uid);

      if (!exists) {
        final displayName = firebaseUser.displayName ?? '';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final userModel = UserModel(
          uid: firebaseUser.uid,
          firstName: firstName,
          lastName: lastName,
          email: firebaseUser.email ?? '',
          role: AppConstants.defaultRole,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
        return userModel;
      }

      return await _firestoreService.getUser(firebaseUser.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google Sign-In failed. Please try again.');
    }
  }
  // ─────────────────────────────────────────────
  // FETCH CURRENT USER MODEL
  // ─────────────────────────────────────────────

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _firestoreService.getUser(user.uid);
  }

  // ─────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SEND PASSWORD RESET EMAIL
  // ─────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ─────────────────────────────────────────────
  // ERROR HANDLER
  // ─────────────────────────────────────────────

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Email or password is incorrect.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return Exception('No internet connection. Please check your network.');
      case 'operation-not-allowed':
        return Exception('This sign-in method is not enabled.');
      default:
        return Exception('An error occurred. Please try again.');
    }
  }
}
