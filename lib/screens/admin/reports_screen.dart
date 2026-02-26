import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leave_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/leave_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';
import '../../widgets/status_badge_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _statusFilter = 'all';
  UserModel? _selectedEmployee;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final leaveProvider = context.watch<LeaveProvider>();
    final employees = leaveProvider.getEmployees();
    final allRequests = leaveProvider.getAllRequests(
      status: _statusFilter == 'all' ? null : _statusFilter,
      employeeId: _selectedEmployee?.id,
      from: _fromDate,
      to: _toDate,
    );

    // Summary counts
    final totalApproved =
        allRequests.where((r) => r.isApproved).length;
    final totalPending =
        allRequests.where((r) => r.isPending).length;
    final totalRejected =
        allRequests.where((r) => r.isRejected).length;
    final totalDays = allRequests
        .where((r) => r.isApproved)
        .fold<int>(0, (sum, r) => sum + r.totalDays);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave Reports'),
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Filters ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Status chips
                SingleChildScrollView(
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
                const SizedBox(height: 8),

                // Employee + date filters row
                Row(
                  children: [
                    // Employee filter
                    Expanded(
                      child: DropdownButtonFormField<UserModel?>(
                        key: ValueKey(_selectedEmployee?.id ?? 'all'),
                        initialValue: _selectedEmployee,
                        decoration: InputDecoration(
                          hintText: 'All employees',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem<UserModel?>(
                              value: null, child: Text('All Employees')),
                          ...employees.map((e) => DropdownMenuItem(
                              value: e, child: Text(e.name))),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedEmployee = v),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Date range
                    _DateButton(
                      label: _fromDate != null
                          ? DateHelper.formatShort(_fromDate!)
                          : 'From',
                      onTap: () => _pickDate(isFrom: true),
                    ),
                    const SizedBox(width: 4),
                    _DateButton(
                      label: _toDate != null
                          ? DateHelper.formatShort(_toDate!)
                          : 'To',
                      onTap: () => _pickDate(isFrom: false),
                    ),

                    if (_fromDate != null || _toDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _fromDate = null;
                          _toDate = null;
                        }),
                        tooltip: 'Clear dates',
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Summary cards ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _SummaryCard(
                    'Approved', totalApproved, AppColors.approved),
                const SizedBox(width: 8),
                _SummaryCard('Pending', totalPending, AppColors.pending),
                const SizedBox(width: 8),
                _SummaryCard(
                    'Rejected', totalRejected, AppColors.rejected),
                const SizedBox(width: 8),
                _SummaryCard('Days Off', totalDays, AppColors.primary),
              ],
            ),
          ),

          // ── Table header ───────────────────────────────────────────────
          Container(
            color: Colors.grey.shade200,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Employee',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Dates',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),

          // ── Request rows ───────────────────────────────────────────────
          Expanded(
            child: allRequests.isEmpty
                ? const Center(
                    child: Text('No records found.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    itemCount: allRequests.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (_, i) =>
                        _ReportRow(request: allRequests[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String status, Color color) {
    final selected = _statusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = status),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReportRow extends StatelessWidget {
  final LeaveRequestModel request;

  const _ReportRow({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.employeeName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(request.leaveTypeName,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${DateHelper.formatShort(request.startDate)}\n${request.totalDays}d',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(status: request.status, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
