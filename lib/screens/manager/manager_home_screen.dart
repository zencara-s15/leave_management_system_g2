import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/shared/notifications_screen.dart';
import '../../screens/shared/profile_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/leave_card_widget.dart';
import 'pending_requests_screen.dart';
import 'team_calendar_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _ManagerDashboardTab(),
    PendingRequestsScreen(),
    TeamCalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppColors.managerColor.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.pending_actions_outlined),
            selectedIcon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manager Dashboard Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ManagerDashboardTab extends StatelessWidget {
  const _ManagerDashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final pending = leaveProvider.getPendingForManager(user.id);
    final allTeamRequests = leaveProvider.getAllRequests().where(
      (r) {
        final employees = leaveProvider.getEmployees()
            .where((e) => e.managerId == user.id)
            .map((e) => e.id)
            .toSet();
        return employees.contains(r.employeeId);
      },
    ).toList();
    final unread = notifProvider.getUnreadCount(user.id);
    final teamEmployees = leaveProvider.getEmployees()
        .where((e) => e.managerId == user.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manager Portal',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            Text(
              user.name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.managerColor,
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
                    child: Text('$unread',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          // ── Stats row ──────────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                label: 'Team Size',
                value: '${teamEmployees.length}',
                color: AppColors.managerColor,
                icon: Icons.group_outlined,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Pending',
                value: '${pending.length}',
                color: AppColors.pending,
                icon: Icons.pending_actions_outlined,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Approved',
                value: '${allTeamRequests.where((r) => r.isApproved).length}',
                color: AppColors.approved,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Pending requests preview ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Approvals',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (pending.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${pending.length} new',
                    style: const TextStyle(
                        color: AppColors.pending,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (pending.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.task_alt, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No pending requests',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pending.take(3).map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LeaveCard(request: r),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
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
                value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
