import 'package:flutter/material.dart';

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
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
                    _buildDateStatus(),
                    // Live Timer
                    _buildLiveTimer(),
                    // Punch In Button
                    _buildPunchInButton(),
                    // Location Info
                    _buildLocationInfo(),
                    const SizedBox(height: 24),
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 20),
                    // Shift Card
                    _buildShiftCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
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
              children: const [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Alex Morgan',
                  style: TextStyle(
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
                child: Icon(
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

  Widget _buildDateStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: const [
          Text(
            'Mon, 12 Oct 2023',
            style: TextStyle(
              color: textMain,
              fontSize: 18, // Slightly reduced
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "You're on time today",
            style: TextStyle(
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
          _buildTimerCard('04', 'Hours'),
          _buildTimerSeparator(),
          _buildTimerCard('12', 'Minutes'),
          _buildTimerSeparator(),
          _buildTimerCard('30', 'Seconds'),
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
            style: TextStyle(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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

  Widget _buildPunchInButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          // Glow Effect Container - reduced aggression
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.18), // Reduced glow
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
                    primaryColor,
                    const Color(0xFF1E40AF), // Deeper blue
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25), // Reduced
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fingerprint Icon Container - professional
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Punch In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tap to confirm',
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
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on_outlined,
          color: textMuted, // More secondary
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          'Office Location: New York, NY',
          style: TextStyle(
            color: textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
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
              time: '09:00 AM',
              status: 'On Time',
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
              time: '--:--',
              status: 'Not yet',
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
            style: TextStyle(
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
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryLight,
                              size: 18,
                            ),
                            const SizedBox(width: 7),
                            const Text(
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
                        Text(
                          'General Shift • 8h 00m',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
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

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: surfaceLight,
        border: Border(
          top: BorderSide(color: borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Home', isActive: true),
          _buildNavItem(Icons.calendar_today_outlined, 'History'),
          _buildNavItem(Icons.groups_outlined, 'Team'),
          _buildNavItem(Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? primaryColor : textMuted,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? primaryColor : textMuted,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
