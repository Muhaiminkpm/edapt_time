import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/auth_service.dart';
import 'providers/leave_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/attendance_provider.dart';
import 'view/login_view.dart';
import 'view/admin/admin_shell_view.dart';
import 'view/employee/employee_shell_view.dart';

void main() {
  runApp(const EdaptTimeApp());
}

class EdaptTimeApp extends StatelessWidget {
  const EdaptTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'Edapt Time',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF135BEC),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthChecker(),
        routes: {
          '/login': (context) => const LoginView(),
          '/admin-home': (context) => const AdminShellView(),
          '/employee-home': (context) => const EmployeeShellView(),
        },
      ),
    );
  }
}


/// Checks login state on startup and routes accordingly.
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final role = await AuthService.getLoggedInRole();

    if (!mounted) return;

    if (role == AuthService.roleAdmin) {
      Navigator.of(context).pushReplacementNamed('/admin-home');
    } else if (role == AuthService.roleEmployee) {
      Navigator.of(context).pushReplacementNamed('/employee-home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash/loading while checking auth
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF135BEC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Edapt Time',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF135BEC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
