import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/attendance_model.dart';

/// SQLite database helper for attendance records.
/// Stores punch in/out data with selfie photo paths and location.
class AttendanceDbHelper {
  static const String _databaseName = 'edapt_time.db';
  static const int _databaseVersion = 3; // Version 3 adds attendance table
  static const String tableAttendance = 'attendance';

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

  /// Create all tables.
  static Future<void> _onCreate(Database db, int version) async {
    // Leaves table
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS employees (
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

    // Attendance table
    await _createAttendanceTable(db);
  }

  /// Handle database upgrades.
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add employees table in version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS employees (
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
    if (oldVersion < 3) {
      // Add attendance table in version 3
      await _createAttendanceTable(db);
    }
  }

  /// Create attendance table.
  static Future<void> _createAttendanceTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableAttendance (
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

  /// Insert a new attendance record (for punch in).
  static Future<int> insertAttendance(AttendanceModel attendance) async {
    final db = await database;
    return await db.insert(
      tableAttendance,
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Update attendance record with punch out data.
  static Future<int> updatePunchOut({
    required int employeeId,
    required String date,
    required String punchOutTime,
    required String punchOutPhotoPath,
    required String punchOutLocation,
  }) async {
    final db = await database;
    return await db.update(
      tableAttendance,
      {
        'punch_out_time': punchOutTime,
        'punch_out_photo_path': punchOutPhotoPath,
        'punch_out_location': punchOutLocation,
      },
      where: 'employee_id = ? AND date = ?',
      whereArgs: [employeeId, date],
    );
  }

  /// Get today's attendance for an employee.
  static Future<AttendanceModel?> getTodayAttendance(int employeeId, String date) async {
    final db = await database;
    final result = await db.query(
      tableAttendance,
      where: 'employee_id = ? AND date = ?',
      whereArgs: [employeeId, date],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AttendanceModel.fromMap(result.first);
  }

  /// Get all attendance records (for admin).
  static Future<List<AttendanceModel>> getAllAttendance() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAttendance,
      orderBy: 'date DESC, punch_in_time DESC',
    );
    return maps.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  /// Get attendance records for a specific date (for admin).
  static Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAttendance,
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'punch_in_time ASC',
    );
    return maps.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  /// Get attendance history for an employee.
  static Future<List<AttendanceModel>> getEmployeeAttendance(int employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAttendance,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  /// Get present count for today.
  static Future<int> getTodayPresentCount(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableAttendance WHERE date = ? AND punch_in_time IS NOT NULL',
      [date],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
