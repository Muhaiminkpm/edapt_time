import 'package:sqflite/sqflite.dart';
import '../../models/attendance_model.dart';
import 'database_manager.dart';

/// SQLite database helper for attendance records.
/// Stores punch in/out data with selfie photo paths and location.
class AttendanceDbHelper {
  static const String tableAttendance = 'attendance';

  /// Get database instance from centralized manager.
  static Future<Database> get database => DatabaseManager.database;

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
    required String employeeId,
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
  static Future<AttendanceModel?> getTodayAttendance(String employeeId, String date) async {
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
  static Future<List<AttendanceModel>> getEmployeeAttendance(String employeeId) async {
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
