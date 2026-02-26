import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leave_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/leave_card_widget.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();
    final pending = leaveProvider.getPendingForManager(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pending Requests (${pending.length})'),
        backgroundColor: AppColors.managerColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: pending.isEmpty
          ? const _EmptyPending()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              itemCount: pending.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return LeaveCard(
                  request: pending[index],
                  showActions: true,
                  onApprove: () =>
                      _confirmAction(context, pending[index], approve: true),
                  onReject: () =>
                      _confirmAction(context, pending[index], approve: false),
                );
              },
            ),
    );
  }

  void _confirmAction(
    BuildContext context,
    LeaveRequestModel request, {
    required bool approve,
  }) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(approve ? 'Approve Leave' : 'Reject Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.employeeName} — ${request.leaveTypeName} '
              '(${request.totalDays} day${request.totalDays > 1 ? 's' : ''})',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: approve
                    ? 'Optional note to employee...'
                    : 'Reason for rejection (optional)...',
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  approve ? AppColors.approved : AppColors.rejected,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final manager = context.read<AuthProvider>().currentUser!;
              final provider = context.read<LeaveProvider>();

              if (approve) {
                await provider.approveRequest(
                  approver: manager,
                  requestId: request.id,
                  note: noteController.text.trim().isNotEmpty
                      ? noteController.text.trim()
                      : null,
                );
              } else {
                await provider.rejectRequest(
                  approver: manager,
                  requestId: request.id,
                  note: noteController.text.trim().isNotEmpty
                      ? noteController.text.trim()
                      : null,
                );
              }

              if (!context.mounted) return;
              context.read<NotificationProvider>().refresh();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(approve
                      ? 'Leave approved for ${request.employeeName}.'
                      : 'Leave rejected for ${request.employeeName}.'),
                  backgroundColor:
                      approve ? AppColors.approved : AppColors.rejected,
                ),
              );
            },
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyPending extends StatelessWidget {
  const _EmptyPending();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No pending requests',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'All caught up!',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
