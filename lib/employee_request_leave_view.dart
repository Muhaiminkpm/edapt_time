import 'package:flutter/material.dart';

class EmployeeRequestLeaveView extends StatelessWidget {
  const EmployeeRequestLeaveView({super.key});

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New Request Form Card
                    _buildNewRequestCard(),
                    const SizedBox(height: 24),
                    // Recent Requests Section
                    _buildRecentRequestsSection(),
                    const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundLight.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(color: borderLight),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back,
                color: textMain,
                size: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          // Title
          const Expanded(
            child: Text(
              'Request Leave',
              style: TextStyle(
                color: textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildNewRequestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'New Request',
            style: TextStyle(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // Leave Type Field
          _buildDropdownField(
            label: 'Leave Type',
            placeholder: 'Select type...',
          ),
          const SizedBox(height: 20),
          // Date Range Fields
          Row(
            children: [
              Expanded(
                child: _buildDateField(label: 'From'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(label: 'To'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Reason Field
          _buildTextAreaField(
            label: 'Reason',
            isOptional: true,
            placeholder: 'e.g., Doctor\'s appointment',
          ),
          const SizedBox(height: 24),
          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSub,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                placeholder,
                style: const TextStyle(
                  color: textSub,
                  fontSize: 15,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: textSub,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSub,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'mm/dd/yyyy',
                style: TextStyle(
                  color: textSub.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                color: textSub,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required bool isOptional,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: textSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: isOptional
                ? [
                    TextSpan(
                      text: ' (Optional)',
                      style: TextStyle(
                        color: textSub.withOpacity(0.6),
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          alignment: Alignment.topLeft,
          child: Text(
            placeholder,
            style: TextStyle(
              color: textSub.withOpacity(0.7),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Submit Request',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.send,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsSection() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Requests',
                style: TextStyle(
                  color: textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Request Items
        _buildRequestItem(
          title: 'Sick Leave',
          date: 'Oct 24 - Oct 25, 2023',
          status: 'Pending',
          statusColor: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),
        _buildRequestItem(
          title: 'Vacation',
          date: 'Sep 10 - Sep 15, 2023',
          status: 'Approved',
          statusColor: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildRequestItem(
          title: 'Casual Leave',
          date: 'Aug 05, 2023',
          status: 'Rejected',
          statusColor: const Color(0xFFEF4444),
        ),
        const SizedBox(height: 12),
        _buildRequestItem(
          title: 'Doctor Appointment',
          date: 'Jul 12, 2023',
          status: 'Approved',
          statusColor: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildRequestItem({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    IconData statusIcon;
    Color bgColor;

    switch (status) {
      case 'Pending':
        statusIcon = Icons.schedule;
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'Approved':
        statusIcon = Icons.check_circle;
        bgColor = const Color(0xFFD1FAE5);
        break;
      case 'Rejected':
        statusIcon = Icons.cancel;
        bgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusIcon = Icons.schedule;
        bgColor = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    color: textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Status Badge
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
