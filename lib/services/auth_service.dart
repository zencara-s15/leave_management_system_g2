import '../models/user_model.dart';
import 'storage_service.dart';

/// Handles authentication: login, logout, session persistence.
class AuthService {
  final StorageService _storage;

  AuthService(this._storage);

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Returns the matching [UserModel] on success, or null on failure.
  Future<UserModel?> login(String email, String password) async {
    final user = _storage.getUserByEmail(email.trim());
    if (user == null) return null;
    if (user.password != password.trim()) return null;
    if (!user.isActive) return null;

    // Persist session so the user stays logged in across restarts
    await _storage.saveCurrentUserId(user.id);
    return user;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.clearCurrentUserId();
  }

  // ── Auto-login on app start ────────────────────────────────────────────────

  /// Returns the persisted user if a valid session exists, otherwise null.
  UserModel? getSessionUser() {
    final id = _storage.currentUserId;
    if (id == null) return null;
    return _storage.getUserById(id);
  }

  // ── Password change ────────────────────────────────────────────────────────

  /// Returns true on success.
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _storage.getUserById(userId);
    if (user == null) return false;
    if (user.password != currentPassword) return false;

    final updated = user.copyWith(password: newPassword);
    await _storage.upsertUser(updated);
    return true;
  }
}
