import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/firestore_user_service.dart';
import '../../core/db/attendance_db_helper.dart';
import '../../models/attendance_model.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color textMain = Color(0xFF1A1F36);
  static const Color textSub = Color(0xFF697386);
  static const Color textMeta = Color(0xFF8792A2);
  static const Color borderColor = Color(0xFFE3E8EE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFD97706);
  static const Color dangerColor = Color(0xFFDC6B6B);

  // Dashboard data
  int _totalStaff = 0;
  int _presentCount = 0;
  int _absentCount = 0;
  int _pendingCount = 0;
  List<_RecentActivity> _recentActivities = [];
  Map<String, String> _employeeNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load employees from Firestore
      final employees = await FirestoreUserService.getAllEmployees();
      _totalStaff = employees.length;
      _employeeNames = {
        for (var e in employees) e.uid: e.name,
      };
      
      // Load today's attendance
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayAttendance = await AttendanceDbHelper.getAttendanceByDate(todayStr);
      
      // Calculate stats
      _presentCount = todayAttendance.where((a) => a.hasPunchedIn).length;
      _pendingCount = todayAttendance.where((a) => a.hasPunchedIn && !a.hasPunchedOut).length;
      _absentCount = _totalStaff - _presentCount;
      if (_absentCount < 0) _absentCount = 0;
      
      // Build recent activities from today's attendance
      _recentActivities = _buildRecentActivities(todayAttendance);
      
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<_RecentActivity> _buildRecentActivities(List<AttendanceModel> attendance) {
    final activities = <_RecentActivity>[];
    
    // Sort by most recent activity first
    final sorted = [...attendance];
    sorted.sort((a, b) {
      // Compare punch out time first, then punch in time
      final aTime = a.punchOutTime ?? a.punchInTime ?? '';
      final bTime = b.punchOutTime ?? b.punchInTime ?? '';
      return bTime.compareTo(aTime);
    });
    
    for (var record in sorted.take(5)) {
      final employeeName = _employeeNames[record.employeeId] ?? 'Unknown Employee';
      
      if (record.hasPunchedOut) {
        // Punch out activity
        activities.add(_RecentActivity(
          name: employeeName,
          description: 'Checked out at ${_formatTime(record.punchOutTime)}',
          status: 'Completed',
          statusColor: successColor,
          statusBgColor: const Color(0xFFECFDF5),
        ));
      } else if (record.hasPunchedIn) {
        // Punch in activity
        activities.add(_RecentActivity(
          name: employeeName,
          description: 'Checked in at ${_formatTime(record.punchInTime)}',
          status: 'Working',
          statusColor: primaryColor,
          statusBgColor: const Color(0xFFEEF4FF),
        ));
      }
    }
    
    return activities;
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadDashboardData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(),
                            _buildStatsGrid(),
                            _buildQuickActions(),
                            _buildRecentActivity(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8C9A0),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Dashboard',
              style: TextStyle(
                color: textMain,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: _loadDashboardData,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardBg,
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.refresh,
                color: textSub,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final today = DateFormat('EEE, d MMM yyyy').format(DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, Admin',
            style: const TextStyle(
              color: textMain,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            today,
            style: const TextStyle(
              color: textMeta,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.group_outlined,
                  iconColor: primaryColor,
                  iconBgColor: const Color(0xFFEEF4FF),
                  label: 'Total Staff',
                  value: _totalStaff.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outlined,
                  iconColor: successColor,
                  iconBgColor: const Color(0xFFECFDF5),
                  label: 'Present',
                  value: _presentCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.person_off_outlined,
                  iconColor: dangerColor,
                  iconBgColor: const Color(0xFFFDF2F2),
                  label: 'Absent',
                  value: _absentCount.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildPendingCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: textMeta,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: textMain,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pending_actions_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _pendingCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildActionCard(Icons.person_add_outlined, 'Add Staff'),
              const SizedBox(width: 12),
              _buildActionCard(Icons.assignment_turned_in_outlined, 'Approvals'),
              const SizedBox(width: 12),
              _buildActionCard(Icons.download_outlined, 'Report'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: textSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentActivities.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: Text(
                  'No activity today',
                  style: TextStyle(
                    color: textMeta,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_recentActivities.length, (index) {
              final activity = _recentActivities[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < _recentActivities.length - 1 ? 8 : 0),
                child: _buildActivityItem(
                  name: activity.name,
                  description: activity.description,
                  status: activity.status,
                  statusColor: activity.statusColor,
                  statusBgColor: activity.statusBgColor,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String name,
    required String description,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD4A574),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: textMeta,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class for recent activity items
class _RecentActivity {
  final String name;
  final String description;
  final String status;
  final Color statusColor;
  final Color statusBgColor;

  _RecentActivity({
    required this.name,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
  });
}
