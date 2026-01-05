import 'package:flutter/material.dart';

class EmployeeAttendanceView extends StatelessWidget {
  const EmployeeAttendanceView({super.key});

  static const Color primaryColor = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color statusPresent = Color(0xFF2563EB);
  static const Color statusAbsent = Color(0xFFDC2626);
  static const Color statusLeave = Color(0xFFD97706);
  static const Color statusHalf = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                _buildStatsRow(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendar(),
                        _buildLegendChips(),
                        _buildDateDetails(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFAB(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: backgroundLight,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8C9A0),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Employee View',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surfaceLight,
              border: Border.all(color: borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Present', '18', statusPresent)),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('Leaves', '1', statusLeave)),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('Absent', '0', statusAbsent)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color dotColor) {
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
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(
              color: textMain,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(12),
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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundLight,
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: textSecondary,
                      size: 20,
                    ),
                  ),
                  const Text(
                    'September 2023',
                    style: TextStyle(
                      color: textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundLight,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderLight),
                ),
              ),
              child: Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                  return Expanded(
                    child: Container(
                      height: 28,
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _buildCalendarGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final List<Map<String, dynamic>> calendarData = [
      {'day': '', 'status': null},
      {'day': '', 'status': null},
      {'day': '', 'status': null},
      {'day': '1', 'status': statusPresent},
      {'day': '2', 'status': const Color(0xFFCBD5E1)},
      {'day': '3', 'status': const Color(0xFFCBD5E1)},
      {'day': '4', 'status': statusPresent},
      {'day': '5', 'status': statusPresent},
      {'day': '6', 'status': statusHalf},
      {'day': '7', 'status': statusPresent},
      {'day': '8', 'status': statusPresent},
      {'day': '9', 'status': const Color(0xFFCBD5E1)},
      {'day': '10', 'status': const Color(0xFFCBD5E1)},
      {'day': '11', 'status': statusAbsent},
      {'day': '12', 'status': statusPresent},
      {'day': '13', 'status': statusPresent},
      {'day': '14', 'status': 'selected'},
      {'day': '15', 'status': statusLeave},
      {'day': '16', 'status': const Color(0xFFCBD5E1)},
      {'day': '17', 'status': const Color(0xFFCBD5E1)},
      {'day': '18', 'status': statusPresent},
      {'day': '19', 'status': 'future'},
      {'day': '20', 'status': 'future'},
      {'day': '21', 'status': 'future'},
      {'day': '22', 'status': 'future'},
      {'day': '23', 'status': 'future'},
      {'day': '24', 'status': 'future'},
      {'day': '25', 'status': 'future'},
      {'day': '26', 'status': 'future'},
      {'day': '27', 'status': 'future'},
      {'day': '28', 'status': 'future'},
      {'day': '29', 'status': 'future'},
      {'day': '30', 'status': 'future'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 0,
        childAspectRatio: 1,
      ),
      itemCount: calendarData.length,
      itemBuilder: (context, index) {
        final data = calendarData[index];
        final day = data['day'] as String;
        final status = data['status'];

        if (day.isEmpty) {
          return const SizedBox();
        }

        if (status == 'selected') {
          return _buildSelectedDay(day);
        }

        if (status == 'future') {
          return _buildFutureDay(day);
        }

        return _buildCalendarDay(day, status as Color?);
      },
    );
  }

  Widget _buildCalendarDay(String day, Color? dotColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          day,
          style: const TextStyle(
            color: textMain,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        if (dotColor != null)
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedDay(String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFutureDay(String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          day,
          style: TextStyle(
            color: textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildLegendChip('Present', statusPresent),
          _buildLegendChip('Absent', statusAbsent),
          _buildLegendChip('Leave', statusLeave),
          _buildLegendChip('Half-day', statusHalf),
        ],
      ),
    );
  }

  Widget _buildLegendChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'September 14 Details',
              style: TextStyle(
                color: textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: surfaceLight,
              borderRadius: BorderRadius.circular(12),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.08),
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Present',
                              style: TextStyle(
                                color: textMain,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Regular Shift',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'On Time',
                          style: TextStyle(
                            color: const Color(0xFF166534),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: borderLight),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check In',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '09:02 AM',
                              style: TextStyle(
                                color: textMain,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check Out',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '06:05 PM',
                              style: TextStyle(
                                color: textMain,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: backgroundLight,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Total Hours',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '9h 03m',
                        style: TextStyle(
                          color: textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Request Leave',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
