import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/leave_type_model.dart';
import '../services/storage_service.dart';

/// Seeds the app with default users and leave types on first launch.
/// Credentials for demo / testing:
///   Admin    → admin@company.com   / admin123
///   Manager  → manager@company.com / manager123
///   Employee → john@company.com    / emp123
///   Employee → jane@company.com    / emp123
class InitialData {
  InitialData._();

  static const _uuid = Uuid();

  static Future<void> seedIfEmpty(StorageService storage) async {
    // Skip only when the flag is set AND the key accounts actually exist.
    // If the flag is set but users are missing (e.g. a previous partial run or
    // an app update), we fall through and re-seed.
    final bool adminExists =
        storage.getUserByEmail('admin@company.com') != null;
    if (storage.isSeeded && adminExists) return;

    // ── Leave types ──────────────────────────────────────────────────────────
    final leaveTypes = [
      LeaveTypeModel(
        id: _uuid.v4(),
        name: 'Sick Leave',
        code: 'sick',
        maxDaysPerYear: 10,
        description: 'Leave taken due to illness or medical reasons.',
        carryForward: false,
        requiresDocumentation: true,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      LeaveTypeModel(
        id: _uuid.v4(),
        name: 'Casual Leave',
        code: 'casual',
        maxDaysPerYear: 7,
        description: 'Short-notice personal or family errands.',
        carryForward: false,
        requiresDocumentation: false,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      LeaveTypeModel(
        id: _uuid.v4(),
        name: 'Vacation',
        code: 'vacation',
        maxDaysPerYear: 15,
        description: 'Annual paid vacation leave.',
        carryForward: true,
        requiresDocumentation: false,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      LeaveTypeModel(
        id: _uuid.v4(),
        name: 'Maternity Leave',
        code: 'maternity',
        maxDaysPerYear: 90,
        description: 'Paid leave for expectant mothers.',
        carryForward: false,
        requiresDocumentation: true,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      LeaveTypeModel(
        id: _uuid.v4(),
        name: 'Paternity Leave',
        code: 'paternity',
        maxDaysPerYear: 5,
        description: 'Paid leave for new fathers.',
        carryForward: false,
        requiresDocumentation: false,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
    await storage.saveLeaveTypes(leaveTypes);

    // ── Default leave balance map ─────────────────────────────────────────────
    Map<String, int> balances() => {
          'sick': 10,
          'casual': 7,
          'vacation': 15,
          'maternity': 90,
          'paternity': 5,
        };

    // ── Users ─────────────────────────────────────────────────────────────────
    final adminId = _uuid.v4();
    final managerId = _uuid.v4();
    final emp1Id = _uuid.v4();
    final emp2Id = _uuid.v4();

    final users = [
      // Admin
      UserModel(
        id: adminId,
        name: 'System Admin',
        email: 'admin@company.com',
        password: 'admin123',
        role: 'admin',
        department: 'Administration',
        position: 'System Administrator',
        managerId: null,
        leaveBalances: balances(),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      // Manager
      UserModel(
        id: managerId,
        name: 'Maria Santos',
        email: 'manager@company.com',
        password: 'manager123',
        role: 'manager',
        department: 'Engineering',
        position: 'Engineering Manager',
        managerId: null,
        leaveBalances: balances(),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      // Employee 1
      UserModel(
        id: emp1Id,
        name: 'John Dela Cruz',
        email: 'john@company.com',
        password: 'emp123',
        role: 'employee',
        department: 'Engineering',
        position: 'Software Developer',
        managerId: managerId,
        leaveBalances: balances(),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      // Employee 2
      UserModel(
        id: emp2Id,
        name: 'Jane Reyes',
        email: 'jane@company.com',
        password: 'emp123',
        role: 'employee',
        department: 'Engineering',
        position: 'QA Engineer',
        managerId: managerId,
        leaveBalances: balances(),
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
    await storage.saveUsers(users);

    await storage.markSeeded();
  }
}
