import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storage;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(StorageService storage)
      : _storage = storage,
        _authService = AuthService(storage) {
    // Restore session on startup
    _currentUser = _authService.getSessionUser();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final user = await _authService.login(email, password);

    _isLoading = false;
    if (user != null) {
      _currentUser = user;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid email or password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Refresh current user ───────────────────────────────────────────────────

  /// Call this after profile updates so the UI reflects the changes.
  void refreshCurrentUser() {
    if (_currentUser == null) return;
    _currentUser = _storage.getUserById(_currentUser!.id);
    notifyListeners();
  }

  // ── Change password ────────────────────────────────────────────────────────

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;
    final success = await _authService.changePassword(
      userId: _currentUser!.id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (success) refreshCurrentUser();
    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
