import 'package:flutter/material.dart';
import '../employee/employee_login_view.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  static const Color primaryColor = Color(0xFF0D6CF2);
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color errorColor = Color(0xFFDC6B6B);
  static const Color successColor = Color(0xFF22C55E);

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView>
    with SingleTickerProviderStateMixin {
  // Login state enum
  LoginState _loginState = LoginState.idle;
  String? _errorMessage;

  // Animation controller for error fade-in
  late AnimationController _errorAnimationController;
  late Animation<double> _errorFadeAnimation;

  @override
  void initState() {
    super.initState();
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _errorFadeAnimation = CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _errorAnimationController.dispose();
    super.dispose();
  }

  // Simulate login process
  Future<void> _handleLogin() async {
    if (_loginState == LoginState.loading) return; // Prevent double-tap

    setState(() {
      _loginState = LoginState.loading;
      _errorMessage = null;
    });
    _errorAnimationController.reset();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulate validation (for demo, always succeed)
    // In real app, replace with actual authentication logic
    final bool isSuccess = true; // Change to false to test error state

    if (!mounted) return;

    if (isSuccess) {
      // Show success state
      setState(() {
        _loginState = LoginState.success;
      });

      // Hold success state for 400ms then navigate
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/admin-home');
    } else {
      // Show error state with animation
      setState(() {
        _loginState = LoginState.error;
        _errorMessage = 'Invalid email or password';
      });
      _errorAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminLoginView.backgroundLight,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Hero Section with Background
            _buildHeroSection(),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Login Card
                    _buildLoginCard(context),
                    // Role Switcher
                    _buildRoleSwitcher(context),
                    // Footer Links
                    _buildFooter(),
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

  Widget _buildHeroSection() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD6E8FF),
            Color(0xFFE8F1FC),
            AdminLoginView.backgroundLight,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle geometric pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: GeometricPatternPainter(),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AdminLoginView.primaryColor.withOpacity(0.1),
                    AdminLoginView.backgroundLight,
                  ],
                ),
              ),
            ),
          ),
          // Logo and Title
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // App Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AdminLoginView.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AdminLoginView.primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                // App Name
                const Text(
                  'Edapt',
                  style: TextStyle(
                    color: AdminLoginView.textMain,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminLoginView.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Admin Portal Badge
                _buildAdminBadge(),
                const SizedBox(height: 16),
                // Welcome Title
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: AdminLoginView.textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Please sign in to access administrative controls.',
                  style: TextStyle(
                    color: AdminLoginView.textSub,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Email Field
                _buildEmailField(),
                const SizedBox(height: 20),
                // Password Field
                _buildPasswordField(),
                // Inline Error Message
                _buildErrorMessage(),
                const SizedBox(height: 8),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AdminLoginView.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Secure Login Button
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AdminLoginView.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminLoginView.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: AdminLoginView.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Admin Portal',
            style: TextStyle(
              color: AdminLoginView.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            color: AdminLoginView.textMain,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AdminLoginView.inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminLoginView.borderColor),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.mail_outline,
                  color: AdminLoginView.textSub,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'admin@edapt.com',
                  style: TextStyle(
                    color: AdminLoginView.textSub.withOpacity(0.7),
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
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
        const Text(
          'Password',
          style: TextStyle(
            color: AdminLoginView.textMain,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AdminLoginView.inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminLoginView.borderColor),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.lock_outline,
                  color: AdminLoginView.textSub,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '••••••••••••',
                  style: TextStyle(
                    color: AdminLoginView.textSub.withOpacity(0.7),
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: AdminLoginView.textSub,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Inline error message with fade-in animation
  Widget _buildErrorMessage() {
    if (_loginState != LoginState.error || _errorMessage == null) {
      return const SizedBox.shrink();
    }
    return FadeTransition(
      opacity: _errorFadeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AdminLoginView.errorColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AdminLoginView.errorColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final bool isLoading = _loginState == LoginState.loading;
    final bool isSuccess = _loginState == LoginState.success;
    final bool isDisabled = isLoading || isSuccess;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isSuccess
                ? AdminLoginView.successColor.withOpacity(0.25)
                : AdminLoginView.primaryColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 0.85 : 1.0,
        child: ElevatedButton(
          onPressed: isDisabled ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSuccess
                ? AdminLoginView.successColor
                : AdminLoginView.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: isSuccess
                ? AdminLoginView.successColor
                : AdminLoginView.primaryColor.withOpacity(0.85),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildButtonContent(isLoading, isSuccess),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isLoading, bool isSuccess) {
    if (isSuccess) {
      return Row(
        key: const ValueKey('success'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_outline, size: 18),
          SizedBox(width: 8),
          Text(
            'Login successful',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return Row(
        key: const ValueKey('loading'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Signing in…',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Sign In to Portal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward, size: 18),
      ],
    );
  }

  Widget _buildRoleSwitcher(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Not an Admin?',
            style: TextStyle(
              color: AdminLoginView.textSub,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const EmployeeLoginView()),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Switch to Employee Login',
              style: TextStyle(
                color: AdminLoginView.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '•',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            'Help Center',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Login state enum
enum LoginState { idle, loading, success, error }

// Custom Painter for Geometric Pattern Background
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D6CF2).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Draw diagonal lines for geometric effect
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i + size.height, 0),
        Offset(i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
