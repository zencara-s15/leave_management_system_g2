import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_home_screen.dart';
import '../employee/employee_home_screen.dart';
import '../manager/manager_home_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    if (auth.isLoggedIn) {
      final user = auth.currentUser!;

      if (user.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else if (user.isManager) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManagerHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.primary,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          const Text(
            "Leave Management System",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
}