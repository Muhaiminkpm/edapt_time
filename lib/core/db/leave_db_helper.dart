import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/leave_model.dart';

/// SQLite database helper for leave requests.
class LeaveDbHelper {
  static const String _databaseName = 'edapt_time.db';
  static const int _databaseVersion = 1;
  static const String _tableLeaves = 'leaves';

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
    );
  }

  /// Create tables.
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableLeaves (
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
  }

  /// Insert a new leave request.
  static Future<int> insertLeave(LeaveModel leave) async {
    final db = await database;
    return await db.insert(_tableLeaves, leave.toMap());
  }

  /// Get all leaves.
  static Future<List<LeaveModel>> getAllLeaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableLeaves,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => LeaveModel.fromMap(map)).toList();
  }

  /// Get leaves by employee ID.
  static Future<List<LeaveModel>> getLeavesByEmployee(String employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableLeaves,
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => LeaveModel.fromMap(map)).toList();
  }

  /// Get pending leaves for admin.
  static Future<List<LeaveModel>> getPendingLeaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableLeaves,
      where: 'status = ?',
      whereArgs: [LeaveModel.statusPending],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => LeaveModel.fromMap(map)).toList();
  }

  /// Get approved/rejected leaves for admin history.
  static Future<List<LeaveModel>> getProcessedLeaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableLeaves,
      where: 'status != ?',
      whereArgs: [LeaveModel.statusPending],
      orderBy: 'created_at DESC',
      limit: 10,
    );
    return maps.map((map) => LeaveModel.fromMap(map)).toList();
  }

  /// Update leave status.
  static Future<int> updateLeaveStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      _tableLeaves,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get leave count by status.
  static Future<Map<String, int>> getLeaveCountsByStatus() async {
    final db = await database;
    
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableLeaves WHERE status = ?',
      [LeaveModel.statusPending],
    );
    final approvedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableLeaves WHERE status = ?',
      [LeaveModel.statusApproved],
    );
    final rejectedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableLeaves WHERE status = ?',
      [LeaveModel.statusRejected],
    );

    return {
      'pending': Sqflite.firstIntValue(pendingResult) ?? 0,
      'approved': Sqflite.firstIntValue(approvedResult) ?? 0,
      'rejected': Sqflite.firstIntValue(rejectedResult) ?? 0,
    };
  }
}
