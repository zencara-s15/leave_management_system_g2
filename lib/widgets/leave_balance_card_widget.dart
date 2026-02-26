import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

/// Displays remaining leave balance for a single leave type.
class LeaveBalanceCard extends StatelessWidget {
  final String leaveTypeName;
  final String leaveTypeCode;
  final int remaining;
  final int total;

  const LeaveBalanceCard({
    super.key,
    required this.leaveTypeName,
    required this.leaveTypeCode,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.leaveTypeColor(leaveTypeCode);
    final used = total - remaining;
    final progress = total > 0 ? remaining / total : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(_iconForType(leaveTypeCode),
                      size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    leaveTypeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '$remaining',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 6),

            // Used / Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Used: $used day${used != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  'Total: $total days',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String code) {
    switch (code.toLowerCase()) {
      case 'sick':
        return Icons.local_hospital_outlined;
      case 'casual':
        return Icons.coffee_outlined;
      case 'vacation':
        return Icons.beach_access_outlined;
      case 'maternity':
      case 'paternity':
        return Icons.child_friendly_outlined;
      default:
        return Icons.event_available_outlined;
    }
  }
}
