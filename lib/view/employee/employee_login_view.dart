import 'package:flutter/material.dart';
import 'employee_shell_view.dart';

class EmployeeLoginView extends StatelessWidget {
  const EmployeeLoginView({super.key});

  static const Color primaryColor = Color(0xFF0D6CF2);
  static const Color primaryHover = Color(0xFF0B5BC9);
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color textMain = Color(0xFF0D131C);
  static const Color textSub = Color(0xFF496C9C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // Background Decoration - Dotted Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(
                painter: DottedBackgroundPainter(),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Brand Section
                        _buildBrandSection(),
                        // Step 1 - Phone Input
                        _buildStep1PhoneInput(),
                        // Divider
                        _buildDivider(),
                        // Step 2 - OTP Verification
                        _buildStep2OtpVerification(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
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
          // Help Button
          TextButton(
            onPressed: () {},
            child: const Text(
              'Help',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // App Icon Container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.fingerprint,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          // App Name
          const Text(
            'Edapt',
            style: TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1PhoneInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Title
          const Text(
            'Employee Login',
            style: TextStyle(
              color: textMain,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          const Text(
            'Welcome back! Please enter your registered phone number to verify your identity.',
            style: TextStyle(
              color: textSub,
              fontSize: 15,
              fontWeight: FontWeight.normal,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Phone Number Label
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Phone Number',
              style: TextStyle(
                color: textMain,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Phone Input Field
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Country Code
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Row(
                    children: [
                      const Text(
                        '+1',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
                // Phone Number
                const Expanded(
                  child: Text(
                    '5551239999',
                    style: TextStyle(
                      color: textMain,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Check Icon
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF22C55E),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Send OTP Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const EmployeeShellView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'STEP 2 PREVIEW',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2OtpVerification() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Title
          const Text(
            'Verify Code',
            style: TextStyle(
              color: textMain,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtitle
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                color: textSub,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              children: [
                TextSpan(text: 'We sent a code to '),
                TextSpan(
                  text: '+1 (555) 123-9999',
                  style: TextStyle(
                    color: textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Edit Number Button
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Edit number',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // OTP Input Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Box 1 - Filled
              _buildOtpBox(value: '5', isFocused: true),
              const SizedBox(width: 12),
              // Box 2 - Empty
              _buildOtpBox(value: '', isFocused: false),
              const SizedBox(width: 12),
              // Box 3 - Empty
              _buildOtpBox(value: '', isFocused: false),
              const SizedBox(width: 12),
              // Box 4 - Empty
              _buildOtpBox(value: '', isFocused: false),
            ],
          ),
          const SizedBox(height: 24),
          // Error Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Invalid Code',
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Please check the code and try again.',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Resend Timer
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: textSub,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: "Didn't receive code? "),
                TextSpan(
                  text: 'Resend in 00:24',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Disabled Verify Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Verify & Login',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox({required String value, required bool isFocused}) {
    return Container(
      width: 56,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? primaryColor : Colors.grey.shade300,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            color: textMain,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Having trouble? ',
            style: TextStyle(
              color: textSub,
              fontSize: 12,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Contact Admin',
              style: TextStyle(
                color: primaryColor,
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

// Custom Painter for Dotted Background
class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D6CF2)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const dotRadius = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
