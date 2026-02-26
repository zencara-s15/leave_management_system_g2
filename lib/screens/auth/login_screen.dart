import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      final user = auth.currentUser!;
      switch (user.role) {
        case AppConstants.roleAdmin:
          Navigator.pushReplacementNamed(context, '/admin-home');
          break;
        case AppConstants.roleManager:
          Navigator.pushReplacementNamed(context, '/manager-home');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/employee-home');
      }
    }
  }

  void _fillDemo(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.pagePadding * 1.5),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo / App title ────────────────────────────────────
                  // TODO: Replace with your own logo asset image
                  const Icon(
                    Icons.work_history_outlined,
                    size: 72,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Email ───────────────────────────────────────────────
                  CustomTextField(
                    label: 'Email',
                    hint: 'you@company.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required.';
                      }
                      if (!v.contains('@')) return 'Enter a valid email.';
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // ── Password ────────────────────────────────────────────
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required.';
                      return null;
                    },
                  ),

                  const SizedBox(height: 6),

                  // ── Error message ───────────────────────────────────────
                  if (auth.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                            color: AppColors.rejected, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // ── Login button ────────────────────────────────────────
                  PrimaryButton(
                    label: 'Sign In',
                    isLoading: auth.isLoading,
                    icon: Icons.login,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 28),

                  // ── Demo credentials ────────────────────────────────────
                  // TODO: Remove this section in production
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius:
                          BorderRadius.circular(AppConstants.cardRadius),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Demo Accounts (tap to fill):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _demoTile(
                          'Admin',
                          'admin@company.com',
                          'admin123',
                          AppColors.adminColor,
                        ),
                        _demoTile(
                          'Manager',
                          'manager@company.com',
                          'manager123',
                          AppColors.managerColor,
                        ),
                        _demoTile(
                          'Employee',
                          'john@company.com',
                          'emp123',
                          AppColors.employeeColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoTile(
      String role, String email, String password, Color color) {
    return InkWell(
      onTap: () => _fillDemo(email, password),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$role: $email / $password',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
