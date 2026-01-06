import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../core/storage/auth_service.dart';

class EmployeeDashboardView extends StatefulWidget {
  const EmployeeDashboardView({super.key});

  @override
  State<EmployeeDashboardView> createState() => _EmployeeDashboardViewState();
}

class _EmployeeDashboardViewState extends State<EmployeeDashboardView> {
  // Enterprise-grade color palette - calm and professional
  static const Color primaryColor = Color(0xFF1A56DB); // Deeper corporate blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color backgroundLight = Color(0xFFF8FAFC); // Softer off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color textMain = Color(0xFF1E293B); // Slate-800
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400
  static const Color successColor = Color(0xFF16A34A); // Professional green
  static const Color warningColor = Color(0xFFEA580C); // Professional orange

  int? _employeeId;
  String _employeeName = 'Employee';

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final employeeId = await AuthService.getLoggedInEmployeeId();
    final employeeName = await AuthService.getLoggedInEmployeeName();
    
    if (mounted) {
      setState(() {
        _employeeId = employeeId;
        _employeeName = employeeName ?? 'Employee';
      });
      
      if (employeeId != null) {
        // Load today's attendance
        context.read<AttendanceProvider>().loadTodayAttendance(employeeId);
      }
    }
  }

  Future<void> _handlePunchAction() async {
    if (_employeeId == null) {
      _showError('Employee not logged in');
      return;
    }

    final provider = context.read<AttendanceProvider>();
    
    bool success;
    if (!provider.hasPunchedIn) {
      // Punch In
      success = await provider.punchIn(_employeeId!);
      if (success && mounted) {
        _showSuccess('Punched in successfully!');
      }
    } else if (!provider.hasPunchedOut) {
      // Punch Out
      success = await provider.punchOut(_employeeId!);
      if (success && mounted) {
        _showSuccess('Punched out successfully!');
      }
    } else {
      _showError('Already completed attendance for today');
      return;
    }

    if (!success && provider.error != null && mounted) {
      _showError(provider.error!);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Consumer<AttendanceProvider>(
          builder: (context, attendanceProvider, child) {
            return Column(
              children: [
                // Header
                _buildHeader(),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        // Date & Status
                        _buildDateStatus(attendanceProvider),
                        // Live Timer
                        _buildLiveTimer(),
                        // Punch Button
                        _buildPunchButton(attendanceProvider),
                        // Location Info
                        _buildLocationInfo(attendanceProvider),
                        const SizedBox(height: 24),
                        // Quick Stats
                        _buildQuickStats(attendanceProvider),
                        const SizedBox(height: 20),
                        // Shift Card
                        _buildShiftCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          // Avatar with online indicator - balanced size
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8C9A0),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Reduced shadow
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: successColor,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Welcome Text - secondary feel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _employeeName,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w600, // Semibold, not overly bold
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // Notification Button - subtle
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surfaceLight,
                  border: Border.all(color: borderLight, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03), // Very subtle
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: textSecondary,
                  size: 20, // Reduced size
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDC2626),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateStatus(AttendanceProvider provider) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, d MMM yyyy').format(now);
    
    String statusText;
    if (provider.hasPunchedOut) {
      statusText = 'Completed for today';
    } else if (provider.hasPunchedIn) {
      statusText = 'Currently working';
    } else {
      statusText = "Ready to punch in";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            dateStr,
            style: const TextStyle(
              color: textMain,
              fontSize: 18, // Slightly reduced
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerCard('--', 'Hours'),
          _buildTimerSeparator(),
          _buildTimerCard('--', 'Minutes'),
          _buildTimerSeparator(),
          _buildTimerCard('--', 'Seconds'),
        ],
      ),
    );
  }

  Widget _buildTimerCard(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 72, // Slightly reduced
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02), // Very subtle
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 28, // Reduced dominance
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: textMuted, // More secondary
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSeparator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          color: borderLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPunchButton(AttendanceProvider provider) {
    // Determine button state
    String buttonText;
    String subText;
    Color buttonColor;
    Color buttonGradientEnd;
    bool isEnabled;
    IconData buttonIcon;

    if (provider.isLoading) {
      buttonText = 'Processing...';
      subText = 'Please wait';
      buttonColor = textSecondary;
      buttonGradientEnd = textMuted;
      isEnabled = false;
      buttonIcon = Icons.hourglass_empty_rounded;
    } else if (provider.hasPunchedOut) {
      buttonText = 'Completed';
      subText = 'See you tomorrow';
      buttonColor = successColor;
      buttonGradientEnd = const Color(0xFF15803D);
      isEnabled = false;
      buttonIcon = Icons.check_circle_rounded;
    } else if (provider.hasPunchedIn) {
      buttonText = 'Punch Out';
      subText = 'Tap to confirm';
      buttonColor = warningColor;
      buttonGradientEnd = const Color(0xFFC2410C);
      isEnabled = true;
      buttonIcon = Icons.logout_rounded;
    } else {
      buttonText = 'Punch In';
      subText = 'Tap to confirm';
      buttonColor = primaryColor;
      buttonGradientEnd = const Color(0xFF1E40AF);
      isEnabled = true;
      buttonIcon = Icons.fingerprint_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          // Glow Effect Container - reduced aggression
          GestureDetector(
            onTap: isEnabled ? _handlePunchAction : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(isEnabled ? 0.18 : 0.08),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Container(
                width: 176, // Slightly smaller
                height: 176,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      buttonColor,
                      buttonGradientEnd,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withOpacity(isEnabled ? 0.25 : 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Container - professional
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            child: Icon(
                              buttonIcon,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6), // More subtle
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(AttendanceProvider provider) {
    String locationText;
    if (provider.todayAttendance?.punchInLocation != null) {
      locationText = provider.todayAttendance!.punchInLocation!;
    } else {
      locationText = 'Location captured on punch';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: textMuted, // More secondary
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          locationText,
          style: const TextStyle(
            color: textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(AttendanceProvider provider) {
    final punchInTime = provider.getFormattedPunchInTime() ?? '--:--';
    final punchOutTime = provider.getFormattedPunchOutTime() ?? '--:--';
    
    String checkInStatus;
    if (provider.hasPunchedIn) {
      checkInStatus = 'Recorded';
    } else {
      checkInStatus = 'Pending';
    }

    String checkOutStatus;
    if (provider.hasPunchedOut) {
      final workingHours = provider.getWorkingHours();
      checkOutStatus = workingHours ?? 'Recorded';
    } else if (provider.hasPunchedIn) {
      checkOutStatus = 'Pending';
    } else {
      checkOutStatus = 'Not yet';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Check In Card
          Expanded(
            child: _buildStatCard(
              icon: Icons.login_rounded,
              iconColor: const Color(0xFF16A34A), // Slightly desaturated
              bgColor: const Color(0xFFDCFCE7).withOpacity(0.7),
              label: 'Check In',
              labelColor: const Color(0xFF166534),
              time: punchInTime,
              status: checkInStatus,
            ),
          ),
          const SizedBox(width: 12),
          // Check Out Card
          Expanded(
            child: _buildStatCard(
              icon: Icons.logout_rounded,
              iconColor: const Color(0xFFEA580C), // Slightly desaturated
              bgColor: const Color(0xFFFFEDD5).withOpacity(0.7),
              label: 'Check Out',
              labelColor: const Color(0xFFC2410C),
              time: punchOutTime,
              status: checkOutStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required Color labelColor,
    required String time,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderLight, width: 1),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 13),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            time,
            style: const TextStyle(
              color: textMain,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            status,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Slightly lighter for comfort
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Reduced shadow
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circles - subtle
            Positioned(
              top: -12,
              right: -12,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              left: -12,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.12),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryLight,
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              "Today's Shift",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          '09:00 AM - 06:00 PM',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'General Shift • 8h 00m',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.08),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
