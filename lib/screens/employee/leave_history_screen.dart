import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leave_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/leave_card_widget.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  String _filterStatus = 'all'; // 'all' | 'pending' | 'approved' | 'rejected'

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();
    final allRequests = leaveProvider.getRequestsByEmployee(user.id);

    final filtered = _filterStatus == 'all'
        ? allRequests
        : allRequests
            .where((r) => r.status == _filterStatus)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Filter chips ───────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filterStatus == 'all',
                    color: AppColors.primary,
                    onTap: () => setState(() => _filterStatus = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    selected: _filterStatus == AppConstants.statusPending,
                    color: AppColors.pending,
                    onTap: () => setState(
                        () => _filterStatus = AppConstants.statusPending),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Approved',
                    selected:
                        _filterStatus == AppConstants.statusApproved,
                    color: AppColors.approved,
                    onTap: () => setState(
                        () => _filterStatus = AppConstants.statusApproved),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Rejected',
                    selected:
                        _filterStatus == AppConstants.statusRejected,
                    color: AppColors.rejected,
                    onTap: () => setState(
                        () => _filterStatus = AppConstants.statusRejected),
                  ),
                ],
              ),
            ),
          ),

          // ── Count ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} request${filtered.length != 1 ? 's' : ''}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyHistory()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePadding, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return LeaveCard(
                        request: filtered[index],
                        onTap: () =>
                            _showDetail(context, filtered[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, LeaveRequestModel request) {
    // TODO: Navigate to a full detail screen or show a modal bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LeaveDetailSheet(request: request),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textSecondary,
        fontWeight:
            selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
          color: selected ? color : Colors.grey.shade300),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No leave requests found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LeaveDetailSheet extends StatelessWidget {
  final LeaveRequestModel request;

  const _LeaveDetailSheet({required this.request});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LeaveCard(request: request),
          // TODO: Add more detail rows (timeline, attached documents, etc.)
        ],
      ),
    );
  }
}
