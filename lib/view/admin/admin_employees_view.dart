import 'package:flutter/material.dart';

class AdminEmployeesView extends StatelessWidget {
  const AdminEmployeesView({super.key});

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color textMain = Color(0xFF1A1F36);
  static const Color textSub = Color(0xFF697386);
  static const Color textMeta = Color(0xFF8792A2);
  static const Color borderColor = Color(0xFFE3E8EE);
  static const Color cardBg = Color(0xFFFFFFFF);

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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    child: Column(
                      children: [
                        _buildEmployeeCard(
                          name: 'Sarah Jenkins',
                          role: 'Senior Developer',
                          phone: '+1 555-0123',
                          isActive: true,
                          avatarColor: const Color(0xFFD4A574),
                        ),
                        const SizedBox(height: 12),
                        _buildEmployeeCard(
                          name: 'David Kim',
                          role: 'Product Manager',
                          phone: '+1 555-0145',
                          isActive: true,
                          avatarColor: const Color(0xFF8B7355),
                        ),
                        const SizedBox(height: 12),
                        _buildEmployeeCard(
                          name: 'Michael Ross',
                          role: 'Intern',
                          phone: '+1 555-0199',
                          isActive: false,
                          avatarColor: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 12),
                        _buildEmployeeCard(
                          name: 'Elena Rodriguez',
                          role: 'HR Specialist',
                          phone: '+1 555-0222',
                          isActive: true,
                          avatarColor: const Color(0xFFC49A6C),
                        ),
                        const SizedBox(height: 12),
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
            Positioned(
              bottom: 24,
              right: 16,
              child: _buildFAB(),
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
                  child: useInitials
                      ? Center(
                          child: Text(
                            initials ?? '',
                            style: TextStyle(
                              color: isActive ? textMain : textSub,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
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
                          name,
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
                    role,
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
                        Icons.call_outlined,
                        size: 12,
                        color: textMeta,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        phone,
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
            _buildToggleSwitch(isActive),
          ],
        ),
      ),
    );
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

  Widget _buildToggleSwitch(bool isOn) {
    return Container(
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
    );
  }

  Widget _buildFAB() {
    return Container(
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
    );
  }
}
