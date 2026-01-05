import 'package:flutter/material.dart';
import '../../core/storage/auth_service.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color textMain = Color(0xFF1A1F36);
  static const Color textSub = Color(0xFF697386);
  static const Color textMeta = Color(0xFF8792A2);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE3E8EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildProfileHeader(),
              const SizedBox(height: 32),
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
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8C9A0),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Admin User',
          style: TextStyle(
            color: textMain,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'admin@edapt.com',
          style: TextStyle(
            color: textMeta,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            _buildMenuItem(Icons.settings_outlined, 'Settings'),
            _buildDivider(),
            _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
            _buildDivider(),
            _buildMenuItem(Icons.security_outlined, 'Security'),
            _buildDivider(),
            _buildMenuItem(Icons.help_outline, 'Help & Support'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: textSub, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: textMain,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: textMeta, size: 20),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: borderColor.withOpacity(0.6),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          await AuthService.logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF7F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5D0D0)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Color(0xFFB85C5C), size: 18),
              SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFB85C5C),
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
