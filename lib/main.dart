import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/initial_data.dart';
import 'providers/auth_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/employee/employee_home_screen.dart';
import 'screens/manager/manager_home_screen.dart';
import 'services/storage_service.dart';
import 'utils/app_colors.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local JSON storage (SharedPreferences)
  final storageService = StorageService();
  await storageService.initialize();

  // Seed default users and leave types on first launch
  await InitialData.seedIfEmpty(storageService);

  runApp(
    MultiProvider(
      providers: [
        // Auth — login, logout, session
        ChangeNotifierProvider(
          create: (_) => AuthProvider(storageService),
        ),
        // Leave requests, balances, types, user management
        ChangeNotifierProvider(
          create: (_) => LeaveProvider(storageService),
        ),
        // In-app notifications
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(storageService),
        ),
      ],
      child: const LeaveManagementApp(),
    ),
  );
}

class LeaveManagementApp extends StatelessWidget {
  const LeaveManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check whether a user session already exists (auto-login)
    final auth = context.read<AuthProvider>();
    final Widget home;
    if (auth.isLoggedIn) {
      final user = auth.currentUser!;
      if (user.isAdmin) {
        home = const AdminHomeScreen();
      } else if (user.isManager) {
        home = const ManagerHomeScreen();
      } else {
        home = const EmployeeHomeScreen();
      }
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────
      // TODO: Customize the theme to match your brand colors and typography
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),

      // ── Routing ──────────────────────────────────────────────────────────
      home: home,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/employee-home': (_) => const EmployeeHomeScreen(),
        '/manager-home': (_) => const ManagerHomeScreen(),
        '/admin-home': (_) => const AdminHomeScreen(),
      },
    );
  }
}
