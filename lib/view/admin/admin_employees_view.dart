import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee_model.dart';
import 'admin_add_employee_view.dart';

class AdminEmployeesView extends StatefulWidget {
  const AdminEmployeesView({super.key});

  @override
  State<AdminEmployeesView> createState() => _AdminEmployeesViewState();
}

class _AdminEmployeesViewState extends State<AdminEmployeesView> {
  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color textMain = Color(0xFF1A1F36);
  static const Color textSub = Color(0xFF697386);
  static const Color textMeta = Color(0xFF8792A2);
  static const Color borderColor = Color(0xFFE3E8EE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    // Load employees when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
    });
  }

  Future<void> _confirmDeleteAll() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Employees?'),
        content: const Text(
          'This will permanently delete all employees from the database. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      final deleteResult = await provider.deleteAllEmployees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteResult.message),
            backgroundColor: deleteResult.success ? Colors.green : errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                _buildFilterTabs(),
                Expanded(
                  child: Consumer<EmployeeProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (provider.employees.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: textMeta,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No employees yet',
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first employee',
                                style: TextStyle(
                                  color: textMeta,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => provider.loadEmployees(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: provider.employees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final employee = provider.employees[index];
                            return _buildEmployeeCard(employee: employee);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 16,
              child: _buildFAB(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Employees',
            style: TextStyle(
              color: textMain,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Row(
            children: [
              // Delete All Button
              GestureDetector(
                onTap: _confirmDeleteAll,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardBg,
                    border: Border.all(color: borderColor),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: errorColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Search Button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  border: Border.all(color: borderColor),
                ),
                child: const Icon(
                  Icons.search,
                  color: textSub,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip('All', isSelected: true),
            const SizedBox(width: 8),
            _buildFilterChip('Active', isSelected: false),
            const SizedBox(width: 8),
            _buildFilterChip('Inactive', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : textSub,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard({required EmployeeModel employee}) {
    final bool isActive = employee.isActive;
    final String initials = _getInitials(employee.name);
    final Color avatarColor = _getAvatarColor(employee.name);

    return Opacity(
      opacity: isActive ? 1.0 : 0.65,
      child: Container(
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
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor,
                    border: Border.all(
                      color: isActive ? Colors.white : borderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.name,
                          style: TextStyle(
                            color: isActive ? textMain : textSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(isActive),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.email,
                    style: TextStyle(
                      color: isActive ? primaryColor : textMeta,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 12,
                        color: textMeta,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${employee.shiftStart} - ${employee.shiftEnd}',
                        style: const TextStyle(
                          color: textMeta,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildToggleSwitch(employee),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFD4A574),
      const Color(0xFF8B7355),
      const Color(0xFFC49A6C),
      const Color(0xFF6B8E23),
      const Color(0xFF4682B4),
      const Color(0xFF9370DB),
      const Color(0xFFCD853F),
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFECFDF5)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive
              ? const Color(0xFF10B981)
              : textMeta,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(EmployeeModel employee) {
    final bool isOn = employee.isActive;
    return GestureDetector(
      onTap: () async {
        final provider = Provider.of<EmployeeProvider>(context, listen: false);
        await provider.toggleEmployeeStatus(employee.id!, !isOn);
      },
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: isOn ? primaryColor : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isOn ? 22 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AdminAddEmployeeView(),
          ),
        );
        // Refresh list when returning from add employee
        if (mounted) {
          Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
