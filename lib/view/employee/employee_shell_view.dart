import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'employee_dashboard_view.dart';
import 'employee_attendance_view.dart';
import 'employee_request_leave_view.dart';
import 'employee_profile_view.dart';

class EmployeeShellView extends StatefulWidget {
  const EmployeeShellView({super.key});

  @override
  State<EmployeeShellView> createState() => _EmployeeShellViewState();
}

class _EmployeeShellViewState extends State<EmployeeShellView> {
  int _currentIndex = 0;

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color textSub = Color(0xFF64748B);

  final List<Widget> _screens = const [
    EmployeeDashboardView(),
    EmployeeAttendanceView(),
    EmployeeRequestLeaveView(),
    EmployeeProfileView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_currentIndex != 0) {
            // Go back to Dashboard if not already there
            setState(() {
              _currentIndex = 0;
            });
          } else {
            // Exit app from Dashboard
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                  _buildNavItem(1, Icons.calendar_today_outlined, 'Calendar'),
                  _buildNavItem(2, Icons.event_note_outlined, 'Leave'),
                  _buildNavItem(3, Icons.person_outline, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : textSub,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : textSub,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
