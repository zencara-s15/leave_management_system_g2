import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/leave_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  String _search = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final leaveProvider = context.watch<LeaveProvider>();
    final allUsers = leaveProvider.getAllUsers();

    final filtered = allUsers.where((u) {
      final matchesRole =
          _roleFilter == 'all' || u.role == _roleFilter;
      final matchesSearch = _search.isEmpty ||
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase()) ||
          u.department.toLowerCase().contains(_search.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Employees (${filtered.length})'),
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee'),
        onPressed: () => _showEmployeeForm(context, null),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, or department...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.inputRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // ── Role filter ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _roleChip('All', 'all'),
                  const SizedBox(width: 8),
                  _roleChip('Employee', AppConstants.roleEmployee),
                  const SizedBox(width: 8),
                  _roleChip('Manager', AppConstants.roleManager),
                  const SizedBox(width: 8),
                  _roleChip('Admin', AppConstants.roleAdmin),
                ],
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No users found.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _UserTile(user: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String label, String role) {
    final selected = _roleFilter == role;
    final color = role == AppConstants.roleAdmin
        ? AppColors.adminColor
        : role == AppConstants.roleManager
            ? AppColors.managerColor
            : AppColors.employeeColor;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _roleFilter = role),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
    );
  }

  void _showEmployeeForm(BuildContext context, UserModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EmployeeFormSheet(existing: existing),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final UserModel user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final roleColor = user.isAdmin
        ? AppColors.adminColor
        : user.isManager
            ? AppColors.managerColor
            : AppColors.employeeColor;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.15),
          child: Text(
            user.name[0].toUpperCase(),
            style: TextStyle(
                color: roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user.role[0].toUpperCase() + user.role.substring(1),
                style: TextStyle(
                    color: roleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text('${user.department} · ${user.position}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            if (!user.isActive)
              const Text('Inactive',
                  style: TextStyle(
                      color: AppColors.rejected, fontSize: 11)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) =>
              _handleAction(context, action, user),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: user.isActive ? 'deactivate' : 'activate',
              child: Text(user.isActive ? 'Deactivate' : 'Activate'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(
      BuildContext context, String action, UserModel user) {
    final provider = context.read<LeaveProvider>();
    switch (action) {
      case 'edit':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _EmployeeFormSheet(existing: user),
        );
        break;
      case 'deactivate':
        provider.deactivateUser(user.id);
        break;
      case 'activate':
        provider.activateUser(user.id);
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmployeeFormSheet extends StatefulWidget {
  final UserModel? existing;

  const _EmployeeFormSheet({this.existing});

  @override
  State<_EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends State<_EmployeeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _positionCtrl;
  String _role = AppConstants.roleEmployee;
  String? _managerId;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController();
    _departmentCtrl = TextEditingController(text: u?.department ?? '');
    _positionCtrl = TextEditingController(text: u?.position ?? '');
    _role = u?.role ?? AppConstants.roleEmployee;
    _managerId = u?.managerId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _departmentCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<LeaveProvider>();
    bool success;

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        role: _role,
        department: _departmentCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        managerId: _managerId,
      );
      success = await provider.updateUser(updated);
    } else {
      success = await provider.createUser(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _role,
        department: _departmentCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        managerId: _managerId,
      );
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'User updated.' : 'User created.'),
          backgroundColor: AppColors.approved,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.errorMessage ?? 'Failed to save user.'),
          backgroundColor: AppColors.rejected,
        ),
      );
      provider.clearMessages();
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final managers = context.read<LeaveProvider>().getManagers();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

              Text(
                _isEdit ? 'Edit User' : 'Add New User',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 10),
              CustomTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Valid email required' : null),
              const SizedBox(height: 10),
              if (!_isEdit)
                CustomTextField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Min 6 characters' : null),
              if (!_isEdit) const SizedBox(height: 10),
              CustomTextField(
                  label: 'Department',
                  controller: _departmentCtrl,
                  prefixIcon: Icons.business_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 10),
              CustomTextField(
                  label: 'Position',
                  controller: _positionCtrl,
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 10),

              // Role selector
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.inputRadius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                ),
                items: [
                  AppConstants.roleEmployee,
                  AppConstants.roleManager,
                  AppConstants.roleAdmin,
                ]
                    .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(
                            r[0].toUpperCase() + r.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 10),

              // Manager assignment (only for employees)
              if (_role == AppConstants.roleEmployee &&
                  managers.isNotEmpty)
                DropdownButtonFormField<String?>(
                  initialValue: _managerId,
                  decoration: InputDecoration(
                    labelText: 'Assign Manager',
                    prefixIcon: const Icon(Icons.manage_accounts_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.inputRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('No Manager')),
                    ...managers.map((m) => DropdownMenuItem(
                        value: m.id, child: Text(m.name))),
                  ],
                  onChanged: (v) => setState(() => _managerId = v),
                ),

              const SizedBox(height: 20),
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
                      label: _isEdit ? 'Save Changes' : 'Create User',
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
