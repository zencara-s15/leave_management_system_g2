import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../models/leave_type_model.dart';
import '../models/user_model.dart';
import '../services/leave_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class LeaveProvider extends ChangeNotifier {
  final LeaveService _leaveService;
  final UserService _userService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  LeaveProvider(StorageService storage)
      : _leaveService = LeaveService(
          storage,
          NotificationService(storage),
        ),
        _userService = UserService(storage);

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ── Employee: Apply for leave ──────────────────────────────────────────────

  Future<bool> applyLeave({
    required UserModel employee,
    required LeaveTypeModel leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    _setLoading(true);

    final error = await _leaveService.applyLeave(
      employee: employee,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );

    _setLoading(false);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    _successMessage = 'Leave request submitted successfully.';
    notifyListeners();
    return true;
  }

  // ── Manager: Approve ──────────────────────────────────────────────────────

  Future<bool> approveRequest({
    required UserModel approver,
    required String requestId,
    String? note,
  }) async {
    _setLoading(true);
    final error = await _leaveService.approveRequest(
      approver: approver,
      requestId: requestId,
      note: note,
    );
    _setLoading(false);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    _successMessage = 'Leave request approved.';
    notifyListeners();
    return true;
  }

  // ── Manager: Reject ───────────────────────────────────────────────────────

  Future<bool> rejectRequest({
    required UserModel approver,
    required String requestId,
    String? note,
  }) async {
    _setLoading(true);
    final error = await _leaveService.rejectRequest(
      approver: approver,
      requestId: requestId,
      note: note,
    );
    _setLoading(false);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    _successMessage = 'Leave request rejected.';
    notifyListeners();
    return true;
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  List<LeaveRequestModel> getRequestsByEmployee(String employeeId) =>
      _leaveService.getRequestsByEmployee(employeeId);

  List<LeaveRequestModel> getPendingForManager(String managerId) =>
      _leaveService.getPendingForManager(managerId);

  List<LeaveRequestModel> getAllRequests({
    String? status,
    String? employeeId,
    DateTime? from,
    DateTime? to,
  }) =>
      _leaveService.getAllRequests(
        status: status,
        employeeId: employeeId,
        from: from,
        to: to,
      );

  List<LeaveTypeModel> getActiveLeaveTypes() =>
      _leaveService.getActiveLeaveTypes();

  // ── Admin: Manage leave types ──────────────────────────────────────────────

  Future<void> saveLeaveType(LeaveTypeModel type) async {
    await _leaveService.saveLeaveType(type);
    notifyListeners();
  }

  Future<void> deleteLeaveType(String typeId) async {
    await _leaveService.deleteLeaveType(typeId);
    notifyListeners();
  }

  // ── Admin: User management ─────────────────────────────────────────────────

  List<UserModel> getAllUsers() => _userService.getAllUsers();

  List<UserModel> getEmployees() => _userService.getEmployees();

  List<UserModel> getManagers() => _userService.getManagers();

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String department,
    required String position,
    String? managerId,
  }) async {
    final error = await _userService.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
      position: position,
      managerId: managerId,
    );
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> updateUser(UserModel user) async {
    final error = await _userService.updateUser(user);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<void> deactivateUser(String userId) async {
    await _userService.deactivateUser(userId);
    notifyListeners();
  }

  Future<void> activateUser(String userId) async {
    await _userService.activateUser(userId);
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
