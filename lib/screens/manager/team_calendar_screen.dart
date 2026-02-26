import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';
import '../../widgets/leave_card_widget.dart';

/// Shows all approved / pending leave for the manager's team this month.
class TeamCalendarScreen extends StatefulWidget {
  const TeamCalendarScreen({super.key});

  @override
  State<TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends State<TeamCalendarScreen> {
  DateTime _selectedMonth = DateHelper.startOfMonth();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();

    // Get all employees under this manager
    final employees = leaveProvider.getEmployees()
        .where((e) => e.managerId == user.id)
        .toList();

    final employeeIds = employees.map((e) => e.id).toSet();

    // Filter requests for this team in the selected month
    final allRequests = leaveProvider.getAllRequests(
      from: DateHelper.startOfMonth(_selectedMonth),
      to: DateHelper.endOfMonth(_selectedMonth),
    ).where((r) => employeeIds.contains(r.employeeId)).toList();

    final filtered = _filterStatus == 'all'
        ? allRequests
        : allRequests.where((r) => r.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Team Calendar'),
        backgroundColor: AppColors.managerColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Month navigator ────────────────────────────────────────────
          Container(
            color: AppColors.managerColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  }),
                ),
                Text(
                  DateHelper.formatDisplay(_selectedMonth)
                      .replaceAll(RegExp(r'\d{2}, '), ''),
                  // e.g. "Jan, 2024"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Team members summary ───────────────────────────────────────
          if (employees.isNotEmpty)
            Container(
              height: 76,
              color: Colors.white,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: employees.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final emp = employees[i];
                  final hasLeave = filtered.any(
                    (r) =>
                        r.employeeId == emp.id &&
                        (r.isPending || r.isApproved),
                  );
                  return Tooltip(
                    message: emp.name,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: hasLeave
                          ? AppColors.pending.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      child: Text(
                        emp.name[0].toUpperCase(),
                        style: TextStyle(
                          color: hasLeave
                              ? AppColors.pending
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── Filter chips ───────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', 'all', AppColors.primary),
                  const SizedBox(width: 8),
                  _chip('Pending', AppConstants.statusPending,
                      AppColors.pending),
                  const SizedBox(width: 8),
                  _chip('Approved', AppConstants.statusApproved,
                      AppColors.approved),
                  const SizedBox(width: 8),
                  _chip('Rejected', AppConstants.statusRejected,
                      AppColors.rejected),
                ],
              ),
            ),
          ),

          // ── Leave list ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} leave${filtered.length != 1 ? 's' : ''} this month',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No leave requests this month.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.pagePadding),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => LeaveCard(request: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String status, Color color) {
    final selected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filterStatus = status),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
    );
  }
}
