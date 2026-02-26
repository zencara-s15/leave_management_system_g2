import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/date_helper.dart';
import 'status_badge_widget.dart';

/// Card widget that displays a summary of a [LeaveRequestModel].
/// Tapping it calls [onTap] if provided.
class LeaveCard extends StatelessWidget {
  final LeaveRequestModel request;
  final VoidCallback? onTap;

  /// Show approve/reject action buttons (manager view).
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const LeaveCard({
    super.key,
    required this.request,
    this.onTap,
    this.showActions = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.leaveTypeColor(
      // derive code from name heuristic; ideally pass the code directly
      request.leaveTypeName.toLowerCase().contains('sick')
          ? 'sick'
          : request.leaveTypeName.toLowerCase().contains('casual')
              ? 'casual'
              : request.leaveTypeName.toLowerCase().contains('vacation')
                  ? 'vacation'
                  : request.leaveTypeName.toLowerCase().contains('maternity')
                      ? 'maternity'
                      : request.leaveTypeName.toLowerCase().contains('paternity')
                          ? 'paternity'
                          : 'other',
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: leave type + status ────────────────────────────
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.leaveTypeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          request.employeeName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: request.status),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Date range + total days ──────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    DateHelper.formatRange(request.startDate, request.endDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '${request.totalDays} day${request.totalDays > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ],
              ),

              // ── Reason ───────────────────────────────────────────────────
              if (request.reason.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ── Approver note ─────────────────────────────────────────────
              if (request.approverNote != null &&
                  request.approverNote!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.statusColor(request.status)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${request.approverName ?? "Manager"}: ${request.approverNote}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Action buttons (manager view) ─────────────────────────────
              if (showActions && request.isPending) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rejected,
                          side: BorderSide(
                              color: AppColors.rejected.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.approved,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
