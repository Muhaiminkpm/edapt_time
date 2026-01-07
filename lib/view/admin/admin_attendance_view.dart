import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../core/services/firestore_user_service.dart';

class AdminAttendanceView extends StatefulWidget {
  const AdminAttendanceView({super.key});

  @override
  State<AdminAttendanceView> createState() => _AdminAttendanceViewState();
}

class _AdminAttendanceViewState extends State<AdminAttendanceView> {
  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Cache for employee names from Firestore (keyed by Firebase UID)
  Map<String, String> _employeeNames = {};
  bool _isLoadingEmployees = true;
  int _totalEmployeeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load employees from Firestore
    setState(() => _isLoadingEmployees = true);
    try {
      final employees = await FirestoreUserService.getAllEmployees();
      _employeeNames = {
        for (var e in employees) e.uid: e.name,
      };
      _totalEmployeeCount = employees.length;
    } catch (e) {
      debugPrint('Error loading employees from Firestore: $e');
    }
    setState(() => _isLoadingEmployees = false);
    
    // Load attendance records
    if (mounted) {
      await context.read<AttendanceProvider>().loadTodayAllAttendance();
    }
  }

  /// Get employee name from cache, or return fallback
  String _getEmployeeName(String employeeId) {
    return _employeeNames[employeeId] ?? 'Unknown Employee';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Stats Row
            Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                return _buildStatsRow(provider);
              },
            ),
            // Content
            Expanded(
              child: Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  if (attendanceProvider.isLoading || _isLoadingEmployees) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final records = attendanceProvider.allAttendance;

                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 64,
                            color: textSub.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No attendance records for today',
                            style: TextStyle(
                              color: textSub,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Attendance",
                            style: TextStyle(
                              color: textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...records.map((record) {
                            // Get employee name from Firestore cache
                            final employeeName = _getEmployeeName(record.employeeId);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildAttendanceItem(
                                context,
                                record,
                                employeeName,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final today = DateFormat('d MMM yyyy').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Attendance',
            style: TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: textSub),
                const SizedBox(width: 8),
                Text(
                  today,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AttendanceProvider provider) {
    final records = provider.allAttendance;
    final presentCount = records.where((r) => r.hasPunchedIn).length;
    final lateCount = 0; // Would need shift data to calculate
    // Use Firestore employee count
    final absentCount = _totalEmployeeCount - presentCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Present', presentCount.toString(), const Color(0xFF22C55E))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Late', lateCount.toString(), const Color(0xFFF59E0B))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Absent', absentCount.toString(), const Color(0xFFEF4444))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: textSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(
    BuildContext context,
    AttendanceModel record,
    String employeeName,
  ) {
    // Format punch in time
    String timeDisplay = '--:--';
    if (record.punchInTime != null) {
      try {
        final time = DateFormat('HH:mm:ss').parse(record.punchInTime!);
        timeDisplay = DateFormat('hh:mm a').format(time);
      } catch (e) {
        timeDisplay = record.punchInTime!;
      }
    }

    // Determine status
    String status;
    if (!record.hasPunchedIn) {
      status = 'Absent';
    } else if (record.hasPunchedOut) {
      status = 'Completed';
    } else {
      status = 'Present';
    }

    Color statusColor;
    Color bgColor;
    switch (status) {
      case 'Present':
        statusColor = const Color(0xFF22C55E);
        bgColor = const Color(0xFFDCFCE7);
        break;
      case 'Completed':
        statusColor = const Color(0xFF3B82F6);
        bgColor = const Color(0xFFDBEAFE);
        break;
      case 'Absent':
        statusColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = textSub;
        bgColor = borderLight;
    }

    return GestureDetector(
      onTap: () => _showAttendanceDetails(context, record, employeeName),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8C9A0),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeName,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'In: $timeDisplay',
                        style: const TextStyle(
                          color: textSub,
                          fontSize: 12,
                        ),
                      ),
                      if (record.hasPunchedOut) ...[
                        const Text(' • ', style: TextStyle(color: textSub)),
                        Text(
                          'Out: ${_formatTime(record.punchOutTime)}',
                          style: const TextStyle(
                            color: textSub,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '--:--';
    try {
      final parsed = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsed);
    } catch (e) {
      return time;
    }
  }

  void _showAttendanceDetails(
    BuildContext context,
    AttendanceModel record,
    String employeeName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AttendanceDetailsSheet(
        record: record,
        employeeName: employeeName,
      ),
    );
  }
}

/// Bottom sheet for viewing attendance details including selfie photos
class _AttendanceDetailsSheet extends StatelessWidget {
  final AttendanceModel record;
  final String employeeName;

  const _AttendanceDetailsSheet({
    required this.record,
    required this.employeeName,
  });

  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8C9A0),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employeeName,
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            record.date,
                            style: const TextStyle(
                              color: textSub,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Punch In Section
                _buildPunchSection(
                  title: 'Punch In',
                  time: record.punchInTime,
                  location: record.punchInLocation,
                  photoPath: record.punchInPhotoPath,
                  iconColor: const Color(0xFF22C55E),
                ),

                const SizedBox(height: 20),

                // Punch Out Section
                _buildPunchSection(
                  title: 'Punch Out',
                  time: record.punchOutTime,
                  location: record.punchOutLocation,
                  photoPath: record.punchOutPhotoPath,
                  iconColor: const Color(0xFFEA580C),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchSection({
    required String title,
    required String? time,
    required String? location,
    required String? photoPath,
    required Color iconColor,
  }) {
    String formattedTime = '--:--';
    if (time != null) {
      try {
        final parsed = DateFormat('HH:mm:ss').parse(time);
        formattedTime = DateFormat('hh:mm a').format(parsed);
      } catch (e) {
        formattedTime = time;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: borderLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  title == 'Punch In' ? Icons.login : Icons.logout,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                formattedTime,
                style: TextStyle(
                  color: time != null ? textMain : textSub,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (location != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: textSub),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      color: textSub,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (photoPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildSelfieImage(photoPath),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelfieImage(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        height: 120,
        width: double.infinity,
        color: borderLight,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, size: 32, color: textSub),
              SizedBox(height: 8),
              Text(
                'Photo not found',
                style: TextStyle(color: textSub, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Image.file(
      file,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 120,
          width: double.infinity,
          color: borderLight,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 32, color: textSub),
          ),
        );
      },
    );
  }
}
