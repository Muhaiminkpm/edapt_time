import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leave_model.dart';
import '../../providers/leave_provider.dart';
import 'package:intl/intl.dart';

class EmployeeRequestLeaveView extends StatefulWidget {
  const EmployeeRequestLeaveView({super.key});

  @override
  State<EmployeeRequestLeaveView> createState() => _EmployeeRequestLeaveViewState();
}

class _EmployeeRequestLeaveViewState extends State<EmployeeRequestLeaveView> {
  static const Color primaryColor = Color(0xFF1A56DB);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color statusPending = Color(0xFFD97706);
  static const Color statusApproved = Color(0xFF059669);
  static const Color statusRejected = Color(0xFFDC2626);

  final List<String> _leaveTypes = ['Sick Leave', 'Casual Leave', 'Annual Leave', 'Personal Leave', 'Unpaid Leave'];
  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  // MVP: Using fixed employee ID
  static const String _employeeId = 'emp001';
  static const String _employeeName = 'Current Employee';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().loadEmployeeLeaves(_employeeId);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? (_fromDate ?? DateTime.now()) : (_toDate ?? _fromDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = picked;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _submitLeave() async {
    if (_selectedLeaveType == null || _fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context.read<LeaveProvider>().applyLeave(
      employeeId: _employeeId,
      employeeName: _employeeName,
      fromDate: _fromDate!,
      toDate: _toDate!,
      leaveType: _selectedLeaveType!,
      reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully!'),
          backgroundColor: statusApproved,
        ),
      );
      // Reset form
      setState(() {
        _selectedLeaveType = null;
        _fromDate = null;
        _toDate = null;
        _reasonController.clear();
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit leave request'),
          backgroundColor: statusRejected,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNewRequestCard(),
                    const SizedBox(height: 24),
                    _buildRecentRequestsSection(),
                    const SizedBox(height: 32),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border(
          bottom: BorderSide(color: borderLight.withOpacity(0.7)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              'Request Leave',
              style: TextStyle(
                color: textMain,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {
                context.read<LeaveProvider>().loadEmployeeLeaves(_employeeId);
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: textSecondary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequestCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderLight),
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
          Text(
            'New Request',
            style: TextStyle(
              color: textMain,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 18),
          _buildDropdownField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateField(label: 'From', isFromDate: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateField(label: 'To', isFromDate: false)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextAreaField(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Type',
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLeaveType,
              hint: Text(
                'Select type...',
                style: TextStyle(color: textMuted, fontSize: 14),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary, size: 22),
              items: _leaveTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLeaveType = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required bool isFromDate}) {
    final date = isFromDate ? _fromDate : _toDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _selectDate(isFromDate),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _formatDate(date) : 'mm/dd/yyyy',
                  style: TextStyle(
                    color: date != null ? textMain : textMuted,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today_outlined, color: textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Reason',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' (Optional)',
                style: TextStyle(
                  color: textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 88,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderLight),
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 3,
            style: TextStyle(color: textMain, fontSize: 14),
            decoration: InputDecoration(
              hintText: "e.g., Doctor's appointment",
              hintStyle: TextStyle(color: textMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitLeave,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: _isSubmitting ? primaryColor.withOpacity(0.7) : primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSubmitting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else ...[
              Text(
                'Submit Request',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.send_rounded, color: Colors.white, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequestsSection() {
    return Consumer<LeaveProvider>(
      builder: (context, provider, child) {
        final leaves = provider.employeeLeaves;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Leave History',
                    style: TextStyle(
                      color: textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${leaves.length} requests',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (leaves.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderLight),
                ),
                child: Center(
                  child: Text(
                    'No leave requests yet',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                ),
              )
            else
              ...leaves.map((leave) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildRequestItem(leave),
              )),
          ],
        );
      },
    );
  }

  Widget _buildRequestItem(LeaveModel leave) {
    Color statusColor;
    IconData statusIcon;
    Color bgColor;

    switch (leave.status) {
      case LeaveModel.statusPending:
        statusColor = statusPending;
        statusIcon = Icons.schedule_rounded;
        bgColor = const Color(0xFFFEF3C7).withOpacity(0.7);
        break;
      case LeaveModel.statusApproved:
        statusColor = statusApproved;
        statusIcon = Icons.check_circle_rounded;
        bgColor = const Color(0xFFD1FAE5).withOpacity(0.7);
        break;
      case LeaveModel.statusRejected:
        statusColor = statusRejected;
        statusIcon = Icons.cancel_rounded;
        bgColor = const Color(0xFFFEE2E2).withOpacity(0.7);
        break;
      default:
        statusColor = statusPending;
        statusIcon = Icons.schedule_rounded;
        bgColor = const Color(0xFFFEF3C7).withOpacity(0.7);
    }

    final dateRange = leave.fromDate == leave.toDate
        ? _formatDate(leave.fromDate)
        : '${_formatDate(leave.fromDate)} - ${_formatDate(leave.toDate)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(statusIcon, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave.leaveType,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateRange,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              leave.status[0].toUpperCase() + leave.status.substring(1),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
