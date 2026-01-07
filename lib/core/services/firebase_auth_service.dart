import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication service for login/logout operations.
/// Does NOT handle role validation - that's done via Firestore.
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with email and password.
  /// Returns the User on success, null on failure.
  static Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  /// Sign out current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current Firebase user.
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get current user UID.
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check if user is signed in.
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Create a new user account WITHOUT switching the current session.
  /// This is used when admin creates employees.
  /// 
  /// Returns a map with 'uid' on success, 'error' on failure.
  static Future<Map<String, String?>> createUserKeepingSession({
    required String email,
    required String password,
    required String adminEmail,
    required String adminPassword,
  }) async {
    String? newUserUid;
    try {
      // Create the new user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      newUserUid = credential.user?.uid;
      
      if (newUserUid == null) {
        return {'uid': null, 'error': 'Failed to create user'};
      }

      // SUCCESS! Return UID now - Firestore doc will be created by caller
      // Then try to re-authenticate as admin
      try {
        await _auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } catch (e) {
        // Admin re-auth failed, but user was created successfully
        debugPrint('Admin re-auth failed, but user created: $newUserUid');
      }

      return {'uid': newUserUid, 'error': null};
    } on FirebaseAuthException catch (e) {
      debugPrint('Create user error: ${e.code} - ${e.message}');
      return {'uid': null, 'error': getErrorMessage(e.code)};
    } catch (e) {
      debugPrint('Create user error: $e');
      return {'uid': null, 'error': e.toString()};
    }
  }

  /// Get error message from FirebaseAuthException code.
  static String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed';
    }
  }
}
