import 'package:flutter/foundation.dart';
import '../core/db/leave_db_helper.dart';
import '../models/leave_model.dart';

/// Provider for leave request state management.
class LeaveProvider extends ChangeNotifier {
  List<LeaveModel> _pendingLeaves = [];
  List<LeaveModel> _processedLeaves = [];
  List<LeaveModel> _employeeLeaves = [];
  Map<String, int> _statusCounts = {'pending': 0, 'approved': 0, 'rejected': 0};
  bool _isLoading = false;

  // Getters
  List<LeaveModel> get pendingLeaves => _pendingLeaves;
  List<LeaveModel> get processedLeaves => _processedLeaves;
  List<LeaveModel> get employeeLeaves => _employeeLeaves;
  Map<String, int> get statusCounts => _statusCounts;
  bool get isLoading => _isLoading;

  /// Apply for leave (User side).
  Future<bool> applyLeave({
    required String employeeId,
    required String employeeName,
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    String? reason,
  }) async {
    try {
      final leave = LeaveModel(
        employeeId: employeeId,
        employeeName: employeeName,
        fromDate: fromDate,
        toDate: toDate,
        leaveType: leaveType,
        reason: reason,
        status: LeaveModel.statusPending,
        createdAt: DateTime.now(),
      );

      await LeaveDbHelper.insertLeave(leave);
      
      // Refresh employee leaves
      await loadEmployeeLeaves(employeeId);
      
      return true;
    } catch (e) {
      debugPrint('Error applying leave: $e');
      return false;
    }
  }

  /// Load pending leaves (Admin side).
  Future<void> loadPendingLeaves() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pendingLeaves = await LeaveDbHelper.getPendingLeaves();
      _statusCounts = await LeaveDbHelper.getLeaveCountsByStatus();
    } catch (e) {
      debugPrint('Error loading pending leaves: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load processed leaves (Admin history).
  Future<void> loadProcessedLeaves() async {
    try {
      _processedLeaves = await LeaveDbHelper.getProcessedLeaves();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading processed leaves: $e');
    }
  }

  /// Load leaves by employee (User side).
  Future<void> loadEmployeeLeaves(String employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _employeeLeaves = await LeaveDbHelper.getLeavesByEmployee(employeeId);
    } catch (e) {
      debugPrint('Error loading employee leaves: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Approve a leave request (Admin side).
  Future<bool> approveLeave(int leaveId) async {
    try {
      await LeaveDbHelper.updateLeaveStatus(leaveId, LeaveModel.statusApproved);
      await loadPendingLeaves();
      await loadProcessedLeaves();
      return true;
    } catch (e) {
      debugPrint('Error approving leave: $e');
      return false;
    }
  }

  /// Reject a leave request (Admin side).
  Future<bool> rejectLeave(int leaveId) async {
    try {
      await LeaveDbHelper.updateLeaveStatus(leaveId, LeaveModel.statusRejected);
      await loadPendingLeaves();
      await loadProcessedLeaves();
      return true;
    } catch (e) {
      debugPrint('Error rejecting leave: $e');
      return false;
    }
  }

  /// Load all data for admin.
  Future<void> loadAdminData() async {
    await loadPendingLeaves();
    await loadProcessedLeaves();
  }
}
