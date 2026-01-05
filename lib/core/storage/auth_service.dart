import 'package:shared_preferences/shared_preferences.dart';

/// MVP Auth Service with hard-coded credentials.
/// This is for TEST/DEVELOPMENT purposes only.
class AuthService {
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserRole = 'auth_user_role';

  // Hard-coded credentials (MVP only)
  static const String _adminEmail = 'admin@edapt.com';
  static const String _adminPassword = 'admin123';
  static const String _employeeEmail = 'employee@edapt.com';
  static const String _employeePassword = 'employee123';

  // Role constants
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';

  /// Validates credentials and returns the role if valid.
  /// Returns null if credentials are invalid.
  static String? validateCredentials(String email, String password) {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (trimmedEmail == _adminEmail && trimmedPassword == _adminPassword) {
      return roleAdmin;
    }
    if (trimmedEmail == _employeeEmail && trimmedPassword == _employeePassword) {
      return roleEmployee;
    }
    return null;
  }

  /// Logs in the user and saves state to SharedPreferences.
  /// Returns the role if successful, null otherwise.
  static Future<String?> login(String email, String password) async {
    final role = validateCredentials(email, password);
    if (role == null) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, role);
    return role;
  }

  /// Logs out and clears saved state.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
  }

  /// Returns the saved role if logged in, null otherwise.
  static Future<String?> getLoggedInRole() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return prefs.getString(_keyUserRole);
  }

  /// Checks if the user is currently logged in.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}
