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
import 'leave_policies_screen.dart';
import 'manage_employees_screen.dart';
import 'reports_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _AdminDashboardTab(),
    ManageEmployeesScreen(),
    LeavePoliciesScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppColors.adminColor.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Employees',
          ),
          NavigationDestination(
            icon: Icon(Icons.policy_outlined),
            selectedIcon: Icon(Icons.policy),
            label: 'Policies',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
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
// Admin Dashboard Tab
// ─────────────────────────────────────────────────────────────────────────────

class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final allUsers = leaveProvider.getAllUsers();
    final allRequests = leaveProvider.getAllRequests();
    final leaveTypes = leaveProvider.getActiveLeaveTypes();
    final unread = notifProvider.getUnreadCount(user.id);

    final pendingCount =
        allRequests.where((r) => r.isPending).length;
    final approvedCount =
        allRequests.where((r) => r.isApproved).length;
    final employeeCount =
        allUsers.where((u) => u.isEmployee).length;

    // Recent leave requests (last 5)
    final recent = allRequests.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Panel',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.adminColor,
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
          // ── Stat grid ────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _DashboardCard(
                label: 'Total Employees',
                value: '$employeeCount',
                icon: Icons.people_outline,
                color: AppColors.employeeColor,
              ),
              _DashboardCard(
                label: 'Leave Types',
                value: '${leaveTypes.length}',
                icon: Icons.policy_outlined,
                color: AppColors.adminColor,
              ),
              _DashboardCard(
                label: 'Pending',
                value: '$pendingCount',
                icon: Icons.pending_actions_outlined,
                color: AppColors.pending,
              ),
              _DashboardCard(
                label: 'Approved (Total)',
                value: '$approvedCount',
                icon: Icons.check_circle_outline,
                color: AppColors.approved,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Recent requests ───────────────────────────────────────────
          const Text(
            'Recent Leave Requests',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          if (recent.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.cardRadius),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No requests yet.',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            )
          else
            ...recent.map(
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

class _DashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary),
                      maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
