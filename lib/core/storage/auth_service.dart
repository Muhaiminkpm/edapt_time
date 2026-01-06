import 'package:shared_preferences/shared_preferences.dart';

/// MVP Auth Service with admin credentials and employee database support.
/// This is for TEST/DEVELOPMENT purposes only.
class AuthService {
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserRole = 'auth_user_role';
  static const String _keyEmployeeId = 'auth_employee_id';
  static const String _keyEmployeeEmail = 'auth_employee_email';
  static const String _keyEmployeeName = 'auth_employee_name';

  // Hard-coded admin credentials (MVP only)
  static const String _adminEmail = 'admin@edapt.com';
  static const String _adminPassword = 'admin123';

  // Role constants
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';

  /// Validates admin credentials only.
  /// Returns roleAdmin if valid, null otherwise.
  static String? validateAdminCredentials(String email, String password) {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (trimmedEmail == _adminEmail && trimmedPassword == _adminPassword) {
      return roleAdmin;
    }
    return null;
  }

  /// Login as admin (saves session).
  static Future<String?> loginAsAdmin(String email, String password) async {
    final role = validateAdminCredentials(email, password);
    if (role == null) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, roleAdmin);
    // Clear employee-specific data
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeEmail);
    await prefs.remove(_keyEmployeeName);
    return role;
  }

  /// Save employee session after successful login.
  static Future<void> saveEmployeeSession({
    required int employeeId,
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, roleEmployee);
    await prefs.setInt(_keyEmployeeId, employeeId);
    await prefs.setString(_keyEmployeeEmail, email);
    await prefs.setString(_keyEmployeeName, name);
  }

  /// Get current logged-in employee ID.
  static Future<int?> getLoggedInEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_keyUserRole);
    if (role != roleEmployee) return null;
    return prefs.getInt(_keyEmployeeId);
  }

  /// Get current logged-in employee email.
  static Future<String?> getLoggedInEmployeeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_keyUserRole);
    if (role != roleEmployee) return null;
    return prefs.getString(_keyEmployeeEmail);
  }

  /// Get current logged-in employee name.
  static Future<String?> getLoggedInEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeName);
  }

  /// Logs out and clears saved state.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeEmail);
    await prefs.remove(_keyEmployeeName);
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
