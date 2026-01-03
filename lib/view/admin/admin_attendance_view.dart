import 'package:flutter/material.dart';

class AdminAttendanceView extends StatelessWidget {
  const AdminAttendanceView({super.key});

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF1F5F9);

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
            _buildStatsRow(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                    _buildAttendanceItem('Sarah Jenkins', '09:02 AM', 'Present'),
                    const SizedBox(height: 12),
                    _buildAttendanceItem('David Kim', '09:15 AM', 'Late'),
                    const SizedBox(height: 12),
                    _buildAttendanceItem('Michael Ross', '--:--', 'Absent'),
                    const SizedBox(height: 12),
                    _buildAttendanceItem('Elena Rodriguez', '08:55 AM', 'Present'),
                    const SizedBox(height: 12),
                    _buildAttendanceItem('James Wilson', '09:30 AM', 'Late'),
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
            child: const Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: textSub),
                SizedBox(width: 8),
                Text(
                  'Today',
                  style: TextStyle(
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

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Present', '128', const Color(0xFF22C55E))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Late', '8', const Color(0xFFF59E0B))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Absent', '6', const Color(0xFFEF4444))),
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

  Widget _buildAttendanceItem(String name, String time, String status) {
    Color statusColor;
    Color bgColor;
    switch (status) {
      case 'Present':
        statusColor = const Color(0xFF22C55E);
        bgColor = const Color(0xFFDCFCE7);
        break;
      case 'Late':
        statusColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'Absent':
        statusColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = textSub;
        bgColor = borderLight;
    }

    return Container(
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
                Text(
                  'Check in: $time',
                  style: const TextStyle(
                    color: textSub,
                    fontSize: 12,
                  ),
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
    );
  }
}
