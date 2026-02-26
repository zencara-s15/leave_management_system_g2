import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/shared/notifications_screen.dart';
import '../../screens/shared/profile_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/leave_balance_card_widget.dart';
import '../../widgets/leave_card_widget.dart';
import 'apply_leave_screen.dart';
import 'leave_balance_screen.dart';
import 'leave_history_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _currentIndex = 0;

  // Keep tabs alive when switching
  final List<Widget> _pages = const [
    _DashboardTab(),
    ApplyLeaveScreen(),
    LeaveHistoryScreen(),
    LeaveBalanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each tab has its own AppBar defined internally, except the
      // dashboard which we override here via IndexedStack logic.
      // TODO: Optionally wrap in a custom shell with a shared top AppBar.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Apply',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Balance',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Tab
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final recentRequests =
        leaveProvider.getRequestsByEmployee(user.id).take(3).toList();
    final leaveTypes = leaveProvider.getActiveLeaveTypes();
    final unread = notifProvider.getUnreadCount(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            Text(
              user.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
              if (unread > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.notificationBadge,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<LeaveProvider>(),
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            // ── Quick stats ──────────────────────────────────────────────
            Row(
              children: [
                _QuickStat(
                  label: 'Pending',
                  count: leaveProvider
                      .getRequestsByEmployee(user.id)
                      .where((r) => r.isPending)
                      .length,
                  color: AppColors.pending,
                  icon: Icons.hourglass_empty,
                ),
                const SizedBox(width: 10),
                _QuickStat(
                  label: 'Approved',
                  count: leaveProvider
                      .getRequestsByEmployee(user.id)
                      .where((r) => r.isApproved)
                      .length,
                  color: AppColors.approved,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(width: 10),
                _QuickStat(
                  label: 'Rejected',
                  count: leaveProvider
                      .getRequestsByEmployee(user.id)
                      .where((r) => r.isRejected)
                      .length,
                  color: AppColors.rejected,
                  icon: Icons.cancel_outlined,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Leave balance preview (first 2 types) ─────────────────────
            if (leaveTypes.isNotEmpty) ...[
              const Text(
                'Leave Balance',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...leaveTypes.take(2).map((type) {
                final remaining = user.leaveBalances[type.code] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LeaveBalanceCard(
                    leaveTypeName: type.name,
                    leaveTypeCode: type.code,
                    remaining: remaining,
                    total: type.maxDaysPerYear,
                  ),
                );
              }),
              const SizedBox(height: 4),
            ],

            // ── Recent requests ────────────────────────────────────────────
            const Text(
              'Recent Requests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            if (recentRequests.isEmpty)
              const _NoRequests()
            else
              ...recentRequests.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: LeaveCard(request: r),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NoRequests extends StatelessWidget {
  const _NoRequests();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No leave requests yet.\nTap Apply to submit one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
