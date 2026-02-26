import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/leave_balance_card_widget.dart';

class LeaveBalanceScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const LeaveBalanceScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final leaveTypes = context.watch<LeaveProvider>().getActiveLeaveTypes();
    final navigator = Navigator.of(context);
    final canPop = navigator.canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave Balance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: (canPop || onBackPressed != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (canPop) {
                    navigator.maybePop();
                    return;
                  }
                  onBackPressed?.call();
                },
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppConstants.pagePadding),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Leave Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Year ${DateTime.now().year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Balance cards ──────────────────────────────────────────────
          Expanded(
            child: leaveTypes.isEmpty
                ? const Center(
                    child: Text(
                      'No leave types configured.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePadding),
                    itemCount: leaveTypes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final type = leaveTypes[index];
                      final remaining =
                          user.leaveBalances[type.code] ?? 0;
                      final total = type.maxDaysPerYear;
                      return LeaveBalanceCard(
                        leaveTypeName: type.name,
                        leaveTypeCode: type.code,
                        remaining: remaining,
                        total: total,
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
