import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EmployeeProfileView extends StatefulWidget {
  const EmployeeProfileView({super.key});

  @override
  State<EmployeeProfileView> createState() => _EmployeeProfileViewState();
}

class _EmployeeProfileViewState extends State<EmployeeProfileView> {
  static const Color primaryColor = Color(0xFF1A56DB);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dangerColor = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  String _userName = '';
  String _userEmail = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      if (mounted) {
        setState(() {
          _userName = currentUser.name;
          _userEmail = currentUser.email;
          _userRole = currentUser.role;
        });
      }
    } else {
      // Fallback: load from saved session
      final userName = await AuthProvider.getLoggedInUserName();
      if (mounted && userName != null) {
        setState(() {
          _userName = userName;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProfileHeader(),
              const SizedBox(height: 28),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final displayName = _userName.isNotEmpty ? _userName : 'Employee';
    final initials = _getInitials(displayName);
    final roleDisplay = _userRole == 'employee' ? 'Employee' : _userRole.isNotEmpty ? _userRole : 'Team Member';

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          style: const TextStyle(
            color: textMain,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          roleDisplay,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (_userEmail.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _userEmail,
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Present', '22')),
          Container(
            width: 1,
            height: 36,
            color: borderLight,
          ),
          Expanded(child: _buildStatItem('Leaves', '3')),
          Container(
            width: 1,
            height: 36,
            color: borderLight,
          ),
          Expanded(child: _buildStatItem('Late', '1')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textMain,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
          children: [
            _buildMenuItem(Icons.person_outline_rounded, 'Personal Information'),
            _buildDivider(),
            _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
            _buildDivider(),
            _buildMenuItem(Icons.lock_outline_rounded, 'Change Password'),
            _buildDivider(),
            _buildMenuItem(Icons.help_outline_rounded, 'Help & Support'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textMain,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: borderLight.withOpacity(0.8),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: dangerBg.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dangerBorder.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: dangerColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  color: dangerColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
