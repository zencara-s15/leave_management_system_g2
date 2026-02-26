import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leave_type_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  LeaveTypeModel? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Refresh the user so leave balances reflect any recent approvals
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().refreshCurrentUser();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before the new start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLeaveType == null) {
      _showError('Please select a leave type.');
      return;
    }
    if (_startDate == null || _endDate == null) {
      _showError('Please select the leave dates.');
      return;
    }

    final user = context.read<AuthProvider>().currentUser!;
    final success = await context.read<LeaveProvider>().applyLeave(
          employee: user,
          leaveType: _selectedLeaveType!,
          startDate: _startDate!,
          endDate: _endDate!,
          reason: _reasonController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.read<NotificationProvider>().refresh();
      // Reset the form
      setState(() {
        _selectedLeaveType = null;
        _startDate = null;
        _endDate = null;
        _reasonController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully!'),
          backgroundColor: AppColors.approved,
        ),
      );
    } else {
      final error = context.read<LeaveProvider>().errorMessage;
      _showError(error ?? 'Failed to submit leave request.');
      context.read<LeaveProvider>().clearMessages();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.rejected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final leaveProvider = context.watch<LeaveProvider>();
    final leaveTypes = leaveProvider.getActiveLeaveTypes();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply for Leave'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Leave Type Dropdown ────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leave Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<LeaveTypeModel>(
                        // ValueKey forces a full rebuild of the FormField
                        // when the selection changes, keeping initialValue
                        // in sync with _selectedLeaveType (including reset
                        // to null after a successful submit).
                        key: ValueKey(_selectedLeaveType?.id ?? 'none'),
                        initialValue: _selectedLeaveType,
                        hint: const Text('Select leave type'),
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.inputRadius),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        items: leaveTypes.map((type) {
                          final color =
                              AppColors.leaveTypeColor(type.code);
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(type.name)),
                                Text(
                                  '${user.leaveBalances[type.code] ?? 0} days left',
                                  style: TextStyle(
                                      fontSize: 12, color: color),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLeaveType = v),
                        validator: (v) =>
                            v == null ? 'Please select a leave type' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Date Selection ─────────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leave Dates',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DatePickerField(
                              label: 'Start Date',
                              value: _startDate,
                              onTap: _pickStartDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DatePickerField(
                              label: 'End Date',
                              value: _endDate,
                              onTap: _pickEndDate,
                            ),
                          ),
                        ],
                      ),
                      if (_startDate != null && _endDate != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event, size: 16,
                                  color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Total: $_totalDays day${_totalDays != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Reason ─────────────────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reason',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Reason for leave',
                        hint: 'Brief description of why you need leave...',
                        controller: _reasonController,
                        maxLines: 3,
                        prefixIcon: Icons.notes,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please provide a reason.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Submit ─────────────────────────────────────────────────
              PrimaryButton(
                label: 'Submit Leave Request',
                icon: Icons.send_outlined,
                isLoading: leaveProvider.isLoading,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  value != null
                      ? DateHelper.formatDisplay(value!)
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 13,
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
