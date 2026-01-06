import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../core/db/employee_db_helper.dart';

/// Result class for employee operations.
class EmployeeResult {
  final bool success;
  final String message;
  final EmployeeModel? employee;

  EmployeeResult({
    required this.success,
    required this.message,
    this.employee,
  });
}

/// Provider for employee state management.
/// All employee logic must go through this provider.
/// UI must NOT directly access storage.
class EmployeeProvider extends ChangeNotifier {
  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Add a new employee (Admin only).
  /// Returns EmployeeResult with success/failure status.
  Future<EmployeeResult> addEmployee({
    required String name,
    required String email,
    required String password,
    required String shiftStart,
    required String shiftEnd,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) {
      return EmployeeResult(
        success: false,
        message: 'Name is required',
      );
    }
    if (email.trim().isEmpty) {
      return EmployeeResult(
        success: false,
        message: 'Email is required',
      );
    }
    if (password.isEmpty) {
      return EmployeeResult(
        success: false,
        message: 'Password is required',
      );
    }
    if (shiftStart.isEmpty || shiftEnd.isEmpty) {
      return EmployeeResult(
        success: false,
        message: 'Shift timing is required',
      );
    }

    // Create employee model
    final employee = EmployeeModel(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: password,
      role: EmployeeModel.roleEmployee,
      shiftStart: shiftStart,
      shiftEnd: shiftEnd,
      isActive: true,
    );

    // Insert into database
    final id = await EmployeeDbHelper.insertEmployee(employee);

    if (id == -1) {
      return EmployeeResult(
        success: false,
        message: 'Email already exists',
      );
    }

    // Refresh employee list
    await loadEmployees();

    return EmployeeResult(
      success: true,
      message: 'Employee added successfully',
      employee: employee.copyWith(id: id),
    );
  }

  /// Load all employees from database.
  Future<void> loadEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await EmployeeDbHelper.getAllEmployees();
    } catch (e) {
      _errorMessage = 'Failed to load employees';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle employee active status (Admin only).
  Future<EmployeeResult> toggleEmployeeStatus(int employeeId, bool isActive) async {
    final result = await EmployeeDbHelper.updateEmployeeStatus(employeeId, isActive);

    if (result > 0) {
      await loadEmployees();
      return EmployeeResult(
        success: true,
        message: isActive ? 'Employee activated' : 'Employee deactivated',
      );
    }

    return EmployeeResult(
      success: false,
      message: 'Failed to update employee status',
    );
  }

  /// Validate employee login credentials.
  /// Returns EmployeeResult with appropriate message.
  Future<EmployeeResult> validateLogin(String email, String password) async {
    final employee = await EmployeeDbHelper.getEmployeeByEmail(email);

    if (employee == null) {
      return EmployeeResult(
        success: false,
        message: 'Invalid email or password',
      );
    }

    if (employee.password != password) {
      return EmployeeResult(
        success: false,
        message: 'Invalid email or password',
      );
    }

    if (!employee.isActive) {
      return EmployeeResult(
        success: false,
        message: 'Account is inactive. Contact Admin.',
      );
    }

    return EmployeeResult(
      success: true,
      message: 'Login successful',
      employee: employee,
    );
  }

  /// Get employee by email (for session recovery).
  Future<EmployeeModel?> getEmployeeByEmail(String email) async {
    return await EmployeeDbHelper.getEmployeeByEmail(email);
  }

  /// Get employee count.
  Future<int> getEmployeeCount() async {
    return await EmployeeDbHelper.getEmployeeCount();
  }

  /// Get active employee count.
  Future<int> getActiveEmployeeCount() async {
    return await EmployeeDbHelper.getActiveEmployeeCount();
  }

  /// Delete ALL employees from database (Admin only).
  /// Use with caution - this cannot be undone!
  Future<EmployeeResult> deleteAllEmployees() async {
    try {
      final count = await EmployeeDbHelper.deleteAllEmployees();
      _employees = [];
      notifyListeners();
      return EmployeeResult(
        success: true,
        message: 'Deleted $count employees',
      );
    } catch (e) {
      return EmployeeResult(
        success: false,
        message: 'Failed to delete employees',
      );
    }
  }
}
