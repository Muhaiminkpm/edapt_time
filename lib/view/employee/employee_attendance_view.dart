import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../core/db/attendance_db_helper.dart';
import '../../models/attendance_model.dart';

class EmployeeAttendanceView extends StatefulWidget {
  const EmployeeAttendanceView({super.key});

  @override
  State<EmployeeAttendanceView> createState() => _EmployeeAttendanceViewState();
}

class _EmployeeAttendanceViewState extends State<EmployeeAttendanceView> {
  static const Color primaryColor = Color(0xFF1A56DB);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color statusPresent = Color(0xFF22C55E);
  static const Color statusAbsent = Color(0xFFDC2626);

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String? _employeeId;
  
  // Map of date -> attendance record
  Map<String, AttendanceModel> _attendanceRecords = {};
  AttendanceModel? _selectedAttendance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when dependencies change (e.g., tab becomes visible)
    if (_employeeId != null && !_isLoading) {
      _loadAttendanceRecords().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Get employee ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null) {
      _employeeId = currentUser.uid;
      debugPrint('Employee ID from AuthProvider: $_employeeId');
    } else {
      _employeeId = await AuthProvider.getLoggedInUserId();
      debugPrint('Employee ID from saved session: $_employeeId');
    }
    
    if (_employeeId != null) {
      await _loadAttendanceRecords();
    } else {
      debugPrint('ERROR: No employee ID found!');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadAttendanceRecords() async {
    if (_employeeId == null) return;
    
    try {
      debugPrint('Loading attendance for employee: $_employeeId');
      final records = await AttendanceDbHelper.getEmployeeAttendance(_employeeId!);
      debugPrint('Found ${records.length} attendance records');
      
      _attendanceRecords = {
        for (var r in records) r.date: r,
      };
      
      // Debug: Print all records
      for (var r in records) {
        debugPrint('Record: date=${r.date}, punchIn=${r.punchInTime}, punchOut=${r.punchOutTime}');
      }
      
      // Load selected date attendance
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      _selectedAttendance = _attendanceRecords[selectedDateStr];
      debugPrint('Selected date: $selectedDateStr, has record: ${_selectedAttendance != null}');
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        _currentMonth = nextMonth;
      });
    }
  }

  void _selectDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      _selectedDate = date;
      _selectedAttendance = _attendanceRecords[dateStr];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
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
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance History',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'View your attendance records',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderLight, width: 1),
        ),
        child: Column(
          children: [
            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundLight,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    monthName,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundLight,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Week day headers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
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
                        style: const TextStyle(
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
            // Calendar grid
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
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    
    final totalCells = startingWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    
    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNumber = cellIndex - startingWeekday + 1;
            
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }
            
            final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final attendance = _attendanceRecords[dateStr];
            final isSelected = _selectedDate.year == date.year &&
                _selectedDate.month == date.month &&
                _selectedDate.day == date.day;
            final isFuture = date.isAfter(now);
            final isToday = date.year == now.year && 
                date.month == now.month && 
                date.day == now.day;
            
            return Expanded(
              child: GestureDetector(
                onTap: isFuture ? null : () => _selectDate(date),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: _buildDayCell(
                    dayNumber.toString(),
                    attendance: attendance,
                    isSelected: isSelected,
                    isFuture: isFuture,
                    isToday: isToday,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(
    String day, {
    AttendanceModel? attendance,
    bool isSelected = false,
    bool isFuture = false,
    bool isToday = false,
  }) {
    Color? dotColor;
    if (attendance != null && attendance.hasPunchedIn) {
      dotColor = statusPresent;
    }
    
    if (isSelected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
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
    
    if (isFuture) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: isToday
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: 1.5),
                )
              : null,
          child: Text(
            day,
            style: const TextStyle(
              color: textMain,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildLegendChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildLegendChip('Present', statusPresent),
          _buildLegendChip('Absent', statusAbsent),
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
            style: const TextStyle(
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
    final dateStr = DateFormat('MMMM d, yyyy').format(_selectedDate);
    final isPresent = _selectedAttendance?.hasPunchedIn ?? false;
    final checkInTime = _formatTime(_selectedAttendance?.punchInTime);
    final checkOutTime = _formatTime(_selectedAttendance?.punchOutTime);
    final totalHours = _calculateTotalHours();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              dateStr,
              style: const TextStyle(
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
            ),
            child: Column(
              children: [
                // Status row
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
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
                          color: isPresent
                              ? statusPresent.withOpacity(0.1)
                              : statusAbsent.withOpacity(0.1),
                        ),
                        child: Icon(
                          isPresent
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          color: isPresent ? statusPresent : statusAbsent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPresent ? 'Present' : 'No Record',
                          style: const TextStyle(
                            color: textMain,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Check In / Check Out row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: borderLight),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Check In',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              checkInTime,
                              style: const TextStyle(
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
                            const Text(
                              'Check Out',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              checkOutTime,
                              style: const TextStyle(
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
                // Total hours row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: const BoxDecoration(
                    color: backgroundLight,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: textMuted,
                            size: 16,
                          ),
                          SizedBox(width: 6),
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
                        totalHours,
                        style: const TextStyle(
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

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) {
      return '--:--';
    }
    try {
      final parsed = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsed);
    } catch (e) {
      return time;
    }
  }

  String _calculateTotalHours() {
    if (_selectedAttendance?.punchInTime == null) {
      return '--:--';
    }
    if (_selectedAttendance?.punchOutTime == null) {
      return '--:--';
    }
    
    try {
      final inTime = DateFormat('HH:mm:ss').parse(_selectedAttendance!.punchInTime!);
      final outTime = DateFormat('HH:mm:ss').parse(_selectedAttendance!.punchOutTime!);
      final duration = outTime.difference(inTime);
      
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } catch (e) {
      return '--:--';
    }
  }
}
