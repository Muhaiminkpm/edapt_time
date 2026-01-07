import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firebase_auth_service.dart';
import '../core/services/firestore_user_service.dart';

/// Result of login attempt.
class LoginResult {
  final bool success;
  final String? role;
  final String? errorMessage;
  final FirestoreUser? user;

  LoginResult({
    required this.success,
    this.role,
    this.errorMessage,
    this.user,
  });

  factory LoginResult.success(FirestoreUser user) {
    return LoginResult(
      success: true,
      role: user.role,
      user: user,
    );
  }

  factory LoginResult.failure(String message) {
    return LoginResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Result of user creation.
class CreateUserResult {
  final bool success;
  final String? uid;
  final String message;

  CreateUserResult({
    required this.success,
    this.uid,
    required this.message,
  });
}

/// Authentication Provider using Firebase Auth + Firestore roles.
/// Handles login, logout, session management, and user creation.
class AuthProvider extends ChangeNotifier {
  // Session keys for SharedPreferences
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserRole = 'auth_user_role';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserName = 'auth_user_name';

  // Role constants
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';

  // State
  bool _isLoading = false;
  FirestoreUser? _currentUser;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  FirestoreUser? get currentUser => _currentUser;
  String? get error => _error;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEmployee => _currentUser?.isEmployee ?? false;

  /// Login with email and password.
  /// Validates credentials via Firebase Auth, then checks Firestore for role.
  Future<LoginResult> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Authenticate with Firebase
      final firebaseUser = await FirebaseAuthService.signIn(email, password);
      
      if (firebaseUser == null) {
        _isLoading = false;
        _error = 'Invalid email or password';
        notifyListeners();
        return LoginResult.failure('Invalid email or password');
      }

      // 2. Get user document from Firestore
      final firestoreUser = await FirestoreUserService.getUser(firebaseUser.uid);
      
      if (firestoreUser == null) {
        // User exists in Firebase but not in Firestore
        await FirebaseAuthService.signOut();
        _isLoading = false;
        _error = 'Account not found. Please contact admin.';
        notifyListeners();
        return LoginResult.failure('Account not found. Please contact admin.');
      }

      // 3. Check if account is active
      if (!firestoreUser.isActive) {
        await FirebaseAuthService.signOut();
        _isLoading = false;
        _error = 'Account is disabled. Contact admin for access.';
        notifyListeners();
        return LoginResult.failure('Account is disabled. Contact admin for access.');
      }

      // 4. Save session locally
      await _saveSession(firestoreUser);

      _currentUser = firestoreUser;
      _isLoading = false;
      notifyListeners();

      return LoginResult.success(firestoreUser);

    } catch (e) {
      await FirebaseAuthService.signOut();
      _isLoading = false;
      _error = 'Login failed: ${e.toString()}';
      notifyListeners();
      return LoginResult.failure('Login failed');
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    await FirebaseAuthService.signOut();
    await _clearSession();
    _currentUser = null;
    notifyListeners();
  }

  /// Check auth state on app startup.
  /// Returns the saved role if logged in, null otherwise.
  Future<String?> checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return null;

    // Check if Firebase session is still valid
    if (!FirebaseAuthService.isSignedIn()) {
      await _clearSession();
      return null;
    }

    // Load user from Firestore
    final uid = FirebaseAuthService.getCurrentUserId();
    if (uid != null) {
      final user = await FirestoreUserService.getUser(uid);
      if (user != null && user.isActive) {
        _currentUser = user;
        notifyListeners();
        return user.role;
      }
    }

    // Session invalid, clear it
    await logout();
    return null;
  }

  /// Create employee account (admin only).
  /// Creates Firebase Auth user and Firestore document.
  /// Admin stays logged in after creation.
  Future<CreateUserResult> createEmployee({
    required String name,
    required String email,
    required String password,
    required String adminEmail,
    required String adminPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create Firebase Auth user and restore admin session
      final result = await FirebaseAuthService.createUserKeepingSession(
        email: email,
        password: password,
        adminEmail: adminEmail,
        adminPassword: adminPassword,
      );

      final newUserUid = result['uid'];
      final error = result['error'];

      if (newUserUid == null) {
        _isLoading = false;
        notifyListeners();
        return CreateUserResult(
          success: false,
          message: error ?? 'Failed to create account',
        );
      }

      // Create Firestore document
      final created = await FirestoreUserService.createUser(
        uid: newUserUid,
        name: name,
        email: email,
        role: roleEmployee,
        isActive: true,
      );

      _isLoading = false;
      notifyListeners();

      if (!created) {
        return CreateUserResult(
          success: false,
          message: 'Account created but profile setup failed.',
        );
      }

      return CreateUserResult(
        success: true,
        uid: newUserUid,
        message: 'Employee created successfully',
      );

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return CreateUserResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Save session to SharedPreferences.
  Future<void> _saveSession(FirestoreUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, user.role);
    await prefs.setString(_keyUserId, user.uid);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserName, user.name);
  }

  /// Clear session from SharedPreferences.
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
  }

  /// Get saved user ID (for attendance, etc.).
  static Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Get saved user name.
  static Future<String?> getLoggedInUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Get saved user role.
  static Future<String?> getLoggedInRole() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return prefs.getString(_keyUserRole);
  }

  /// Clear error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
