import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Centralized database manager for all tables.
/// All DB helpers should use this shared database instance.
class DatabaseManager {
  static const String databaseName = 'edapt_time.db';
  static const int databaseVersion = 4;

  static Database? _database;

  /// Get the shared database instance (singleton).
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with all tables.
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables on fresh database.
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
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
    if (oldVersion < 4) {
      // Migrate employee_id from INTEGER to TEXT in version 4
      // Drop and recreate attendance table (data loss for migration)
      await db.execute('DROP TABLE IF EXISTS attendance');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          employee_id TEXT NOT NULL,
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
  }

  /// Close the database connection.
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
