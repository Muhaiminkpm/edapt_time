import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/employee_model.dart';

/// SQLite database helper for employees.
/// Shares database with LeaveDbHelper and AttendanceDbHelper.
class EmployeeDbHelper {
  static const String _databaseName = 'edapt_time.db';
  static const int _databaseVersion = 3; // Version 3 adds attendance table
  static const String _tableEmployees = 'employees';

  static Database? _database;

  /// Get database instance (singleton).
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database.
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables.
  static Future<void> _onCreate(Database db, int version) async {
    // Leaves table (from LeaveDbHelper)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS leaves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        from_date TEXT NOT NULL,
        to_date TEXT NOT NULL,
        leave_type TEXT NOT NULL,
        reason TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Employees table
    await _createEmployeesTable(db);

    // Attendance table
    await _createAttendanceTable(db);
  }

  /// Handle database upgrades.
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add employees table in version 2
      await _createEmployeesTable(db);
    }
    if (oldVersion < 3) {
      // Add attendance table in version 3
      await _createAttendanceTable(db);
    }
  }

  /// Create employees table.
  static Future<void> _createEmployeesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableEmployees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'employee',
        shift_start TEXT NOT NULL,
        shift_end TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Create attendance table.
  static Future<void> _createAttendanceTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        punch_in_time TEXT,
        punch_in_photo_path TEXT,
        punch_in_location TEXT,
        punch_out_time TEXT,
        punch_out_photo_path TEXT,
        punch_out_location TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(employee_id, date)
      )
    ''');
  }

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
