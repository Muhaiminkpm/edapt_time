/// Attendance model for SQLite storage.
/// Represents a single day's attendance record for an employee.
/// Supports punch in/out with selfie photo paths and location data.
class AttendanceModel {
  final int? id;
  final int employeeId;
  final String date; // YYYY-MM-DD format

  // Punch In data
  final String? punchInTime;
  final String? punchInPhotoPath;
  final String? punchInLocation;

  // Punch Out data
  final String? punchOutTime;
  final String? punchOutPhotoPath;
  final String? punchOutLocation;

  final DateTime createdAt;

  AttendanceModel({
    this.id,
    required this.employeeId,
    required this.date,
    this.punchInTime,
    this.punchInPhotoPath,
    this.punchInLocation,
    this.punchOutTime,
    this.punchOutPhotoPath,
    this.punchOutLocation,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if punched in today.
  bool get hasPunchedIn => punchInTime != null;

  /// Check if punched out today.
  bool get hasPunchedOut => punchOutTime != null;

  /// Create from SQLite map.
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as int?,
      employeeId: map['employee_id'] as int,
      date: map['date'] as String,
      punchInTime: map['punch_in_time'] as String?,
      punchInPhotoPath: map['punch_in_photo_path'] as String?,
      punchInLocation: map['punch_in_location'] as String?,
      punchOutTime: map['punch_out_time'] as String?,
      punchOutPhotoPath: map['punch_out_photo_path'] as String?,
      punchOutLocation: map['punch_out_location'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to SQLite map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'date': date,
      'punch_in_time': punchInTime,
      'punch_in_photo_path': punchInPhotoPath,
      'punch_in_location': punchInLocation,
      'punch_out_time': punchOutTime,
      'punch_out_photo_path': punchOutPhotoPath,
      'punch_out_location': punchOutLocation,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields.
  AttendanceModel copyWith({
    int? id,
    int? employeeId,
    String? date,
    String? punchInTime,
    String? punchInPhotoPath,
    String? punchInLocation,
    String? punchOutTime,
    String? punchOutPhotoPath,
    String? punchOutLocation,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      punchInTime: punchInTime ?? this.punchInTime,
      punchInPhotoPath: punchInPhotoPath ?? this.punchInPhotoPath,
      punchInLocation: punchInLocation ?? this.punchInLocation,
      punchOutTime: punchOutTime ?? this.punchOutTime,
      punchOutPhotoPath: punchOutPhotoPath ?? this.punchOutPhotoPath,
      punchOutLocation: punchOutLocation ?? this.punchOutLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, date: $date, '
        'punchIn: $punchInTime, punchOut: $punchOutTime)';
  }
}
