import 'package:sqflite/sqflite.dart';
import '../../models/employee_model.dart';
import 'database_manager.dart';

/// SQLite database helper for employees.
class EmployeeDbHelper {
  static const String _tableEmployees = 'employees';

  /// Get database instance from centralized manager.
  static Future<Database> get database => DatabaseManager.database;

  /// Insert a new employee.
  /// Returns the inserted row ID, or -1 if email already exists.
  static Future<int> insertEmployee(EmployeeModel employee) async {
    final db = await database;
    try {
      return await db.insert(
        _tableEmployees,
        employee.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      // Email already exists (UNIQUE constraint)
      return -1;
    }
  }

  /// Get employee by email (for login validation).
  static Future<EmployeeModel?> getEmployeeByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      _tableEmployees,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return EmployeeModel.fromMap(result.first);
  }

  /// Get all employees.
  static Future<List<EmployeeModel>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableEmployees,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EmployeeModel.fromMap(map)).toList();
  }

  /// Get active employees only.
  static Future<List<EmployeeModel>> getActiveEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableEmployees,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => EmployeeModel.fromMap(map)).toList();
  }

  /// Update employee active status.
  static Future<int> updateEmployeeStatus(int id, bool isActive) async {
    final db = await database;
    return await db.update(
      _tableEmployees,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get employee count.
  static Future<int> getEmployeeCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableEmployees',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get active employee count.
  static Future<int> getActiveEmployeeCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableEmployees WHERE is_active = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Delete employee by ID.
  static Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete(
      _tableEmployees,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete ALL employees from the database.
  static Future<int> deleteAllEmployees() async {
    final db = await database;
    return await db.delete(_tableEmployees);
  }
}
