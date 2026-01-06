/// Employee model for SQLite storage.
/// Represents an employee created by Admin.
class EmployeeModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String shiftStart;
  final String shiftEnd;
  final bool isActive;
  final DateTime createdAt;

  // Role constant
  static const String roleEmployee = 'employee';

  EmployeeModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = roleEmployee,
    required this.shiftStart,
    required this.shiftEnd,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from SQLite map.
  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String? ?? roleEmployee,
      shiftStart: map['shift_start'] as String,
      shiftEnd: map['shift_end'] as String,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to SQLite map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email.toLowerCase().trim(),
      'password': password,
      'role': role,
      'shift_start': shiftStart,
      'shift_end': shiftEnd,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields.
  EmployeeModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? shiftStart,
    String? shiftEnd,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftEnd: shiftEnd ?? this.shiftEnd,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, name: $name, email: $email, isActive: $isActive)';
  }
}
