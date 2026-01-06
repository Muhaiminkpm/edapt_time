import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/storage/auth_service.dart';
import '../providers/employee_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputBg = Color(0xFFF9FAFB);
  static const Color iconGray = Color(0xFF9CA3AF);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF22C55E);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    // First, try admin login
    final adminRole = await AuthService.loginAsAdmin(email, password);

    if (!mounted) return;

    if (adminRole != null) {
      // Admin login successful
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/admin-home');
      return;
    }

    // If not admin, try employee login via EmployeeProvider
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final result = await employeeProvider.validateLogin(email, password);

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    // Employee login successful - save session
    final employee = result.employee!;
    await AuthService.saveEmployeeSession(
      employeeId: employee.id!,
      email: employee.email,
      name: employee.name,
    );

    // Show success state
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/employee-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginView.backgroundColor,
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildIconBlock(),
                        const SizedBox(height: 32),
                        _buildTitleSection(),
                        const SizedBox(height: 32),
                        _buildEmailField(),
                        const SizedBox(height: 20),
                        _buildPasswordField(),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          _buildErrorMessage(),
                        ],
                        const SizedBox(height: 24),
                        _buildLoginButton(context),
                        const SizedBox(height: 48),
                        _buildFooterHelp(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LoginView.primaryColor.withOpacity(0.05),
                      LoginView.primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF60A5FA).withOpacity(0.05),
                      const Color(0xFF60A5FA).withOpacity(0.0),
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

  Widget _buildIconBlock() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: LoginView.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.access_time_rounded,
          color: LoginView.primaryColor,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Edapt Time',
          style: TextStyle(
            color: LoginView.textMain,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Welcome! Please enter your credentials to access your dashboard.',
            style: TextStyle(
              color: LoginView.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            color: LoginView.textMain,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: LoginView.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginView.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(
                  Icons.mail_outline_rounded,
                  color: LoginView.iconGray,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: LoginView.textMain,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'name@edapt.com',
                    hintStyle: TextStyle(
                      color: LoginView.iconGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: LoginView.textMain,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: LoginView.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginView.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: LoginView.iconGray,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    color: LoginView.textMain,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                      color: LoginView.iconGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: LoginView.iconGray,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Forgot password?',
            style: TextStyle(
              color: LoginView.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: LoginView.errorColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _errorMessage!,
            style: TextStyle(
              color: LoginView.errorColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: (_isLoading || _isSuccess) ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isSuccess
              ? LoginView.successColor
              : _isLoading
                  ? LoginView.primaryColor.withOpacity(0.7)
                  : LoginView.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (_isSuccess ? LoginView.successColor : LoginView.primaryColor)
                  .withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSuccess) ...[
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Success!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else if (_isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Signing in...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.login_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ),
              Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterHelp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.help_outline_rounded,
          color: LoginView.textMuted,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          'Trouble logging in? Contact Admin',
          style: TextStyle(
            color: LoginView.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
