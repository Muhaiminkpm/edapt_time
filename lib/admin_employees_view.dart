import 'package:flutter/material.dart';

class AdminEmployeesView extends StatelessWidget {
  const AdminEmployeesView({super.key});

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar
                _buildTopBar(),
                // Filter Tabs
                _buildFilterTabs(),
                // Employee List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Column(
                      children: [
                        // Active Employees
                        _buildEmployeeCard(
                          name: 'Sarah Jenkins',
                          role: 'Senior Developer',
                          phone: '+1 555-0123',
                          isActive: true,
                          avatarColor: const Color(0xFFD4A574),
                        ),
                        const SizedBox(height: 16),
                        _buildEmployeeCard(
                          name: 'David Kim',
                          role: 'Product Manager',
                          phone: '+1 555-0145',
                          isActive: true,
                          avatarColor: const Color(0xFF8B7355),
                        ),
                        const SizedBox(height: 16),
                        // Inactive Employee
                        _buildEmployeeCard(
                          name: 'Michael Ross',
                          role: 'Intern',
                          phone: '+1 555-0199',
                          isActive: false,
                          avatarColor: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 16),
                        _buildEmployeeCard(
                          name: 'Elena Rodriguez',
                          role: 'HR Specialist',
                          phone: '+1 555-0222',
                          isActive: true,
                          avatarColor: const Color(0xFFC49A6C),
                        ),
                        const SizedBox(height: 16),
                        // Inactive Employee with initials
                        _buildEmployeeCard(
                          name: 'James Wilson',
                          role: 'Marketing Assoc.',
                          phone: '+1 555-0333',
                          isActive: false,
                          useInitials: true,
                          initials: 'JW',
                          avatarColor: const Color(0xFFE5E7EB),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Action Button
            Positioned(
              bottom: 24,
              right: 24,
              child: _buildFAB(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Employees',
            style: TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: textMain,
              size: 26,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // All - Active
            _buildFilterChip('All', isSelected: true),
            const SizedBox(width: 12),
            // Active
            _buildFilterChip('Active', isSelected: false),
            const SizedBox(width: 12),
            // Inactive
            _buildFilterChip('Inactive', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard({
    required String name,
    required String role,
    required String phone,
    required bool isActive,
    required Color avatarColor,
    bool useInitials = false,
    String? initials,
  }) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.7,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? borderColor : borderColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with status indicator
            Stack(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor,
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: useInitials
                      ? Center(
                          child: Text(
                            initials ?? '',
                            style: TextStyle(
                              color: textSub,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                // Status dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF9CA3AF),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Employee Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: isActive ? textMain : const Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(isActive),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Role
                  Text(
                    role,
                    style: TextStyle(
                      color: isActive ? primaryColor : textSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Phone
                  Row(
                    children: [
                      Icon(
                        Icons.call_outlined,
                        size: 14,
                        color: textSub.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        phone,
                        style: TextStyle(
                          color: textSub.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Toggle Switch
            _buildToggleSwitch(isActive),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive
              ? const Color(0xFF15803D)
              : const Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isOn) {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: isOn ? primaryColor : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: isOn ? 22 : 2,
            top: 2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
