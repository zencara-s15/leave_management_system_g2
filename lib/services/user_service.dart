import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'storage_service.dart';

/// Admin-level operations for managing employee accounts.
class UserService {
  final StorageService _storage;
  static const _uuid = Uuid();

  UserService(this._storage);

  // ── CRUD ───────────────────────────────────────────────────────────────────

  List<UserModel> getAllUsers() => _storage.getUsers();

  List<UserModel> getEmployees() =>
      _storage.getUsers().where((u) => u.isEmployee).toList();

  List<UserModel> getManagers() =>
      _storage.getUsers().where((u) => u.isManager).toList();

  /// Creates a new user. Returns error string on failure, null on success.
  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String department,
    required String position,
    String? managerId,
  }) async {
    if (_storage.getUserByEmail(email) != null) {
      return 'A user with this email already exists.';
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: role,
      department: department.trim(),
      position: position.trim(),
      managerId: managerId,
      leaveBalances: Map.from(AppConstants.defaultLeaveBalances),
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _storage.upsertUser(user);
    return null;
  }

  /// Updates an existing user's profile fields.
  Future<String?> updateUser(UserModel updatedUser) async {
    final existing = _storage.getUserById(updatedUser.id);
    if (existing == null) return 'User not found.';

    // Check email uniqueness (excluding same user)
    final withSameEmail = _storage.getUserByEmail(updatedUser.email);
    if (withSameEmail != null && withSameEmail.id != updatedUser.id) {
      return 'Email is already in use by another account.';
    }

    await _storage.upsertUser(updatedUser);
    return null;
  }

  /// Soft-deletes (deactivates) a user.
  Future<void> deactivateUser(String userId) async {
    final user = _storage.getUserById(userId);
    if (user == null) return;
    await _storage.upsertUser(user.copyWith(isActive: false));
  }

  Future<void> activateUser(String userId) async {
    final user = _storage.getUserById(userId);
    if (user == null) return;
    await _storage.upsertUser(user.copyWith(isActive: true));
  }

  /// Hard-delete: use with care.
  Future<void> deleteUser(String userId) async {
    await _storage.deleteUser(userId);
  }

  // ── Leave balance management ───────────────────────────────────────────────

  /// Resets all employee leave balances to the default for the new year.
  Future<void> resetAllBalances() async {
    final users = _storage.getUsers();
    for (final user in users) {
      await _storage.upsertUser(
        user.copyWith(
          leaveBalances: Map.from(AppConstants.defaultLeaveBalances),
        ),
      );
    }
  }

  /// Updates a specific leave balance for a user.
  Future<void> updateUserLeaveBalance({
    required String userId,
    required String leaveCode,
    required int newBalance,
  }) async {
    final user = _storage.getUserById(userId);
    if (user == null) return;
    final balances = Map<String, int>.from(user.leaveBalances);
    balances[leaveCode] = newBalance;
    await _storage.upsertUser(user.copyWith(leaveBalances: balances));
  }
}
