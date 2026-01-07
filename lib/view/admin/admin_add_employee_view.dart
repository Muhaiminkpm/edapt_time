import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminAddEmployeeView extends StatefulWidget {
  const AdminAddEmployeeView({super.key});

  @override
  State<AdminAddEmployeeView> createState() => _AdminAddEmployeeViewState();
}

class _AdminAddEmployeeViewState extends State<AdminAddEmployeeView> {
  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color textMain = Color(0xFF111827);
  static const Color textSub = Color(0xFF6B7280);
  static const Color placeholderColor = Color(0xFF9CA3AF);
  static const Color successColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFDC2626);

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  // Selected shift
  String? _selectedShift;
  final List<Map<String, String>> _shifts = [
    {'label': 'Morning (9:00 AM - 5:00 PM)', 'start': '09:00', 'end': '17:00'},
    {'label': 'Evening (2:00 PM - 10:00 PM)', 'start': '14:00', 'end': '22:00'},
    {'label': 'Night (10:00 PM - 6:00 AM)', 'start': '22:00', 'end': '06:00'},
  ];

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter employee name', isError: true);
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter email address', isError: true);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter password', isError: true);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }
    if (_selectedShift == null) {
      _showSnackBar('Please select shift timing', isError: true);
      return;
    }

    // Show dialog to confirm admin credentials for session restoration
    final adminEmail = await _promptAdminCredentials();
    if (adminEmail == null) return; // User cancelled

    setState(() => _isLoading = true);

    // Create employee via AuthProvider (Firebase Auth + Firestore)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.createEmployee(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      adminEmail: adminEmail,
      adminPassword: _adminPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      _showSnackBar(result.message, isError: false);
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _adminPasswordController.clear();
      setState(() => _selectedShift = null);
      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.of(context).pop();
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  /// Prompt admin to enter their credentials for session restoration
  Future<String?> _promptAdminCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminEmail = authProvider.currentUser?.email ?? '';
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Admin Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your password to create employee account:',
              style: TextStyle(fontSize: 14, color: textSub),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Admin Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_adminPasswordController.text.isNotEmpty) {
                Navigator.pop(context, adminEmail);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
                // Header
                _buildHeader(),
                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Upload
                        _buildAvatarUpload(),
                        const SizedBox(height: 24),
                        // Full Name
                        _buildInputField(
                          label: 'Full Name',
                          placeholder: 'ex. John Doe',
                          icon: Icons.badge_outlined,
                          controller: _nameController,
                        ),

                        const SizedBox(height: 20),
                        // Email ID
                        _buildInputField(
                          label: 'Email ID',
                          placeholder: 'ex. john.doe@company.com',
                          icon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        // Password
                        _buildInputField(
                          label: 'Password',
                          placeholder: 'Set initial password',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        // Shift Timing Dropdown
                        _buildShiftDropdown(),
                        const SizedBox(height: 24),
                        // Working Days
                        _buildWorkingDays(),
                        const SizedBox(height: 20),
                        // Active Employee Toggle
                        _buildActiveToggle(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Sticky Footer Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: primaryColor,
                size: 22,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          // Title
          const Expanded(
            child: Text(
              'Add Employee',
              style: TextStyle(
                color: textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer for balance
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatarUpload() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Avatar with camera button
          Stack(
            children: [
              // Avatar Circle
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surfaceLight,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3F4F6),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              // Camera Button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                    border: Border.all(color: backgroundLight, width: 4),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Upload Photo Text
          const Text(
            'Upload Photo',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String placeholder,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(icon, color: placeholderColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      color: placeholderColor,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Shift Timing',
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.schedule_outlined, color: placeholderColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedShift,
                    hint: const Text(
                      'Select Shift',
                      style: TextStyle(
                        color: placeholderColor,
                        fontSize: 15,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: placeholderColor,
                      size: 24,
                    ),
                    items: _shifts.map((shift) {
                      return DropdownMenuItem<String>(
                        value: shift['label'],
                        child: Text(
                          shift['label']!,
                          style: const TextStyle(
                            color: textMain,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedShift = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingDays() {
    final List<Map<String, dynamic>> days = [
      {'label': 'M', 'selected': true},
      {'label': 'T', 'selected': true},
      {'label': 'W', 'selected': true},
      {'label': 'T', 'selected': true},
      {'label': 'F', 'selected': true},
      {'label': 'S', 'selected': false},
      {'label': 'S', 'selected': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Working Days',
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final bool isSelected = day['selected'] as bool;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primaryColor : surfaceLight,
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    day['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFDCFCE7),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF22C55E),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Employee',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Allow access to system',
                  style: TextStyle(
                    color: textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Toggle Switch
          _buildToggleSwitch(isOn: true),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch({required bool isOn}) {
    return Container(
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: isOn ? primaryColor : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
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

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundLight.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: borderLight),
        ),
      ),
      child: GestureDetector(
        onTap: _isLoading ? null : _handleSave,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _isLoading ? primaryColor.withOpacity(0.7) : primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Saving...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                const Icon(Icons.save_outlined, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Save Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
