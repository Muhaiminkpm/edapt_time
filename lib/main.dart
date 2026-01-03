import 'package:flutter/material.dart';
import 'view/admin/admin_login_view.dart';
import 'view/admin/admin_shell_view.dart';
import 'view/employee/employee_login_view.dart';
import 'view/employee/employee_shell_view.dart';

void main() {
  runApp(const EdaptTimeApp());
}

class EdaptTimeApp extends StatelessWidget {
  const EdaptTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: '/admin-login',
      routes: {
        '/admin-login': (context) => const AdminLoginView(),
        '/admin-home': (context) => const AdminShellView(),
        '/employee-login': (context) => const EmployeeLoginView(),
        '/employee-home': (context) => const EmployeeShellView(),
      },
    );
  }
}
