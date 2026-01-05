/// Leave request model for MVP.
class LeaveModel {
  final int? id;
  final String employeeId;
  final String employeeName;
  final DateTime fromDate;
  final DateTime toDate;
  final String leaveType;
  final String? reason;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  LeaveModel({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    this.reason,
    required this.status,
    required this.createdAt,
  });

  /// Convert to map for SQLite insert.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'from_date': fromDate.toIso8601String(),
      'to_date': toDate.toIso8601String(),
      'leave_type': leaveType,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from SQLite row.
  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map['id'] as int?,
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      fromDate: DateTime.parse(map['from_date'] as String),
      toDate: DateTime.parse(map['to_date'] as String),
      leaveType: map['leave_type'] as String,
      reason: map['reason'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Create a copy with updated status.
  LeaveModel copyWith({String? status}) {
    return LeaveModel(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      fromDate: fromDate,
      toDate: toDate,
      leaveType: leaveType,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// Status constants.
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
}
