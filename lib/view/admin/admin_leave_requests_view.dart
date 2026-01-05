import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/leave_model.dart';
import '../../providers/leave_provider.dart';

class AdminLeaveRequestsView extends StatefulWidget {
  const AdminLeaveRequestsView({super.key});

  @override
  State<AdminLeaveRequestsView> createState() => _AdminLeaveRequestsViewState();
}

class _AdminLeaveRequestsViewState extends State<AdminLeaveRequestsView> {
  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE3E8EE);
  static const Color textMain = Color(0xFF1A1F36);
  static const Color textSub = Color(0xFF697386);
  static const Color textMeta = Color(0xFF8792A2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().loadAdminData();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }

  Future<void> _handleApprove(int leaveId) async {
    final success = await context.read<LeaveProvider>().approveLeave(leaveId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Leave approved' : 'Failed to approve'),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFDC6B6B),
        ),
      );
    }
  }

  Future<void> _handleReject(int leaveId) async {
    final success = await context.read<LeaveProvider>().rejectLeave(leaveId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Leave rejected' : 'Failed to reject'),
          backgroundColor: success ? const Color(0xFFD97706) : const Color(0xFFDC6B6B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Consumer<LeaveProvider>(
              builder: (context, provider, child) {
                return _buildStatusSummary(provider.statusCounts);
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<LeaveProvider>().loadAdminData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPendingRequestsSection(),
                      const SizedBox(height: 24),
                      _buildRecentHistorySection(),
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

  Widget _buildHeader() {
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
          const SizedBox(width: 36),
          const Expanded(
            child: Text(
              'Leave Requests',
              style: TextStyle(
                color: textMain,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () => context.read<LeaveProvider>().loadAdminData(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardBg,
                border: Border.all(color: borderColor),
              ),
              child: const Icon(Icons.refresh, color: textSub, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(Map<String, int> counts) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
            icon: Icons.pending_actions_outlined,
            iconColor: const Color(0xFFD97706),
            label: 'Pending',
            count: '${counts['pending'] ?? 0}',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF10B981),
            label: 'Approved',
            count: '${counts['approved'] ?? 0}',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFDC6B6B),
            label: 'Rejected',
            count: '${counts['rejected'] ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: textMeta,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsSection() {
    return Consumer<LeaveProvider>(
      builder: (context, provider, child) {
        final pendingLeaves = provider.pendingLeaves;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Pending Requests',
                style: TextStyle(
                  color: textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (pendingLeaves.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: const Center(
                  child: Text(
                    'No pending requests',
                    style: TextStyle(color: textMeta, fontSize: 14),
                  ),
                ),
              )
            else
              ...pendingLeaves.map((leave) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPendingRequestCard(leave),
              )),
          ],
        );
      },
    );
  }

  Widget _buildPendingRequestCard(LeaveModel leave) {
    final days = _calculateDays(leave.fromDate, leave.toDate);
    final dateRange = '${_formatDate(leave.fromDate)} - ${_formatDate(leave.toDate)} • $days Day${days > 1 ? 's' : ''}';

    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    leave.employeeName.isNotEmpty
                        ? leave.employeeName[0].toUpperCase()
                        : 'E',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          leave.employeeName,
                          style: const TextStyle(
                            color: textMain,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildStatusBadge('Pending', const Color(0xFFD97706)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.leaveType,
                      style: const TextStyle(
                        color: textSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        color: textMeta,
                        fontSize: 12,
                      ),
                    ),
                    if (leave.reason != null && leave.reason!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${leave.reason}',
                        style: const TextStyle(
                          color: textMeta,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: borderColor.withOpacity(0.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleReject(leave.id!),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5D0D0)),
                      color: const Color(0xFFFDF7F7),
                    ),
                    child: const Center(
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          color: Color(0xFFB85C5C),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleApprove(leave.id!),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Approve',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecentHistorySection() {
    return Consumer<LeaveProvider>(
      builder: (context, provider, child) {
        final processedLeaves = provider.processedLeaves;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Recent History',
                style: TextStyle(
                  color: textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (processedLeaves.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: const Center(
                  child: Text(
                    'No processed requests yet',
                    style: TextStyle(color: textMeta, fontSize: 14),
                  ),
                ),
              )
            else
              ...processedLeaves.map((leave) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildHistoryItem(leave),
              )),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(LeaveModel leave) {
    final isApproved = leave.status == LeaveModel.statusApproved;
    
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                leave.employeeName.isNotEmpty
                    ? leave.employeeName[0].toUpperCase()
                    : 'E',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                  leave.employeeName,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${leave.leaveType} • ${_formatDate(leave.fromDate)}',
                  style: const TextStyle(
                    color: textMeta,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildHistoryStatusBadge(isApproved),
        ],
      ),
    );
  }

  Widget _buildHistoryStatusBadge(bool isApproved) {
    final Color color = isApproved ? const Color(0xFF10B981) : const Color(0xFFDC6B6B);
    final String text = isApproved ? 'Approved' : 'Rejected';
    final IconData icon = isApproved ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
