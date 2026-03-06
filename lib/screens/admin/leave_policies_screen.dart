import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/leave_type_model.dart';
import '../../providers/leave_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';

class LeavePoliciesScreen extends StatelessWidget {
  const LeavePoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaveTypes = context.watch<LeaveProvider>().getActiveLeaveTypes();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave Policies'),
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Policy'),
        onPressed: () => _showPolicyForm(context, null),
      ),
      body: leaveTypes.isEmpty
          ? const Center(
              child: Text('No leave types configured.',
                  style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              itemCount: leaveTypes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PolicyCard(
                leaveType: leaveTypes[i],
                onEdit: () => _showPolicyForm(context, leaveTypes[i]),
                onDelete: () => _confirmDelete(context, leaveTypes[i]),
              ),
            ),
    );
  }

  void _showPolicyForm(BuildContext context, LeaveTypeModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PolicyFormSheet(existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, LeaveTypeModel type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Delete Policy",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Are you sure you want to delete "${type.name}"?\nThis cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// YES BUTTON
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rejected,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<LeaveProvider>().deleteLeaveType(type.id);
                        },
                        child: const Text("Yes"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PolicyCard extends StatelessWidget {
  final LeaveTypeModel leaveType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PolicyCard({
    required this.leaveType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.leaveTypeColor(leaveType.code);

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
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leaveType.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (a) =>
                      a == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: AppColors.rejected))),
                  ],
                ),
              ],
            ),
            const Divider(height: 14),
            Text(leaveType.description,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag('${leaveType.maxDaysPerYear} days/year', color),
                if (leaveType.carryForward)
                  _Tag('Carry Forward', AppColors.approved),
                if (leaveType.requiresDocumentation)
                  _Tag('Docs Required', AppColors.pending),
                _Tag(
                  leaveType.isActive ? 'Active' : 'Inactive',
                  leaveType.isActive
                      ? AppColors.approved
                      : AppColors.rejected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PolicyFormSheet extends StatefulWidget {
  final LeaveTypeModel? existing;

  const _PolicyFormSheet({this.existing});

  @override
  State<_PolicyFormSheet> createState() => _PolicyFormSheetState();
}

class _PolicyFormSheetState extends State<_PolicyFormSheet> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _maxDaysCtrl;
  bool _carryForward = false;
  bool _requiresDocs = false;
  bool _isActive = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _codeCtrl = TextEditingController(text: t?.code ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _maxDaysCtrl =
        TextEditingController(text: t?.maxDaysPerYear.toString() ?? '');
    _carryForward = t?.carryForward ?? false;
    _requiresDocs = t?.requiresDocumentation ?? false;
    _isActive = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _maxDaysCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final type = LeaveTypeModel(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim().toLowerCase(),
      description: _descCtrl.text.trim(),
      maxDaysPerYear: int.parse(_maxDaysCtrl.text.trim()),
      carryForward: _carryForward,
      requiresDocumentation: _requiresDocs,
      isActive: _isActive,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await context.read<LeaveProvider>().saveLeaveType(type);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Policy updated.' : 'Policy created.'),
        backgroundColor: AppColors.approved,
      ),
    );
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEdit ? 'Edit Leave Policy' : 'New Leave Policy',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Leave Type Name',
                controller: _nameCtrl,
                prefixIcon: Icons.label_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Code (e.g. sick, casual, vacation)',
                controller: _codeCtrl,
                prefixIcon: Icons.code,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 2,
                prefixIcon: Icons.notes,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Max Days Per Year',
                controller: _maxDaysCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Carry Forward'),
                subtitle: const Text('Unused days roll over to next year'),
                value: _carryForward,
                onChanged: (v) => setState(() => _carryForward = v),
                activeThumbColor: AppColors.adminColor,
              ),
              SwitchListTile(
                title: const Text('Requires Documentation'),
                subtitle: const Text('Employee must attach supporting docs'),
                value: _requiresDocs,
                onChanged: (v) => setState(() => _requiresDocs = v),
                activeThumbColor: AppColors.adminColor,
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeThumbColor: AppColors.adminColor,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      color: AppColors.adminColor,
                      onPressed: _handleCancel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _isEdit ? 'Save Changes' : 'Create Policy',
                      color: AppColors.adminColor,
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
