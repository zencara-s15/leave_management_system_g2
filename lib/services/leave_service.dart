import 'package:uuid/uuid.dart';
import '../models/leave_request_model.dart';
import '../models/leave_type_model.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'storage_service.dart';
import 'notification_service.dart';

/// Business logic for leave requests, balances, and leave types.
class LeaveService {
  final StorageService _storage;
  final NotificationService _notificationService;
  static const _uuid = Uuid();

  LeaveService(this._storage, this._notificationService);

  // ── Apply for Leave ────────────────────────────────────────────────────────

  /// Submits a new leave request.
  /// Returns an error message string on failure, or null on success.
  Future<String?> applyLeave({
    required UserModel employee,
    required LeaveTypeModel leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    // Validate dates
    if (endDate.isBefore(startDate)) {
      return 'End date cannot be before start date.';
    }

    final totalDays = endDate.difference(startDate).inDays + 1;

    // Check balance
    final balance = employee.leaveBalances[leaveType.code] ?? 0;
    if (totalDays > balance) {
      return 'Insufficient leave balance. You have $balance day(s) remaining for ${leaveType.name}.';
    }

    final request = LeaveRequestModel(
      id: _uuid.v4(),
      employeeId: employee.id,
      employeeName: employee.name,
      leaveTypeId: leaveType.id,
      leaveTypeName: leaveType.name,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      status: AppConstants.statusPending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storage.upsertLeaveRequest(request);

    // Notify the employee's manager (if assigned)
    if (employee.managerId != null) {
      await _notificationService.notifyNewRequest(
        managerId: employee.managerId!,
        request: request,
      );
    }

    return null; // success
  }

  // ── Approve / Reject ───────────────────────────────────────────────────────

  Future<String?> approveRequest({
    required UserModel approver,
    required String requestId,
    String? note,
  }) async {
    return _updateRequestStatus(
      approver: approver,
      requestId: requestId,
      newStatus: AppConstants.statusApproved,
      note: note,
    );
  }

  Future<String?> rejectRequest({
    required UserModel approver,
    required String requestId,
    String? note,
  }) async {
    return _updateRequestStatus(
      approver: approver,
      requestId: requestId,
      newStatus: AppConstants.statusRejected,
      note: note,
    );
  }

  Future<String?> _updateRequestStatus({
    required UserModel approver,
    required String requestId,
    required String newStatus,
    String? note,
  }) async {
    final request = _storage.getLeaveRequestById(requestId);
    if (request == null) return 'Leave request not found.';
    if (!request.isPending) return 'Request has already been processed.';

    final updated = request.copyWith(
      status: newStatus,
      approverId: approver.id,
      approverName: approver.name,
      approverNote: note,
      updatedAt: DateTime.now(),
    );
    await _storage.upsertLeaveRequest(updated);

    // Deduct balance if approved
    if (newStatus == AppConstants.statusApproved) {
      await _deductLeaveBalance(
        employeeId: request.employeeId,
        leaveTypeId: request.leaveTypeId,
        days: request.totalDays,
      );
    }

    // Notify employee
    await _notificationService.notifyRequestDecision(request: updated);

    return null; // success
  }

  Future<void> _deductLeaveBalance({
    required String employeeId,
    required String leaveTypeId,
    required int days,
  }) async {
    final employee = _storage.getUserById(employeeId);
    if (employee == null) return;

    // Find the leave type code from the stored leave types
    final leaveType = _storage
        .getLeaveTypes()
        .where((t) => t.id == leaveTypeId)
        .firstOrNull;
    if (leaveType == null) return;

    final balances = Map<String, int>.from(employee.leaveBalances);
    final current = balances[leaveType.code] ?? 0;
    balances[leaveType.code] = (current - days).clamp(0, 9999);

    await _storage.upsertUser(employee.copyWith(leaveBalances: balances));
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  List<LeaveRequestModel> getRequestsByEmployee(String employeeId) {
    return _storage
        .getLeaveRequestsByEmployee(employeeId)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<LeaveRequestModel> getPendingForManager(String managerId) {
    return _storage.getPendingRequestsForManager(managerId)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// All requests for admin reports (optionally filtered).
  List<LeaveRequestModel> getAllRequests({
    String? status,
    String? employeeId,
    DateTime? from,
    DateTime? to,
  }) {
    var requests = _storage.getLeaveRequests();

    if (status != null) {
      requests = requests.where((r) => r.status == status).toList();
    }
    if (employeeId != null) {
      requests = requests.where((r) => r.employeeId == employeeId).toList();
    }
    if (from != null) {
      requests = requests.where((r) => !r.startDate.isBefore(from)).toList();
    }
    if (to != null) {
      requests = requests.where((r) => !r.startDate.isAfter(to)).toList();
    }

    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  // ── Leave Types ────────────────────────────────────────────────────────────

  List<LeaveTypeModel> getActiveLeaveTypes() {
    return _storage.getLeaveTypes().where((t) => t.isActive).toList();
  }

  Future<void> saveLeaveType(LeaveTypeModel type) async {
    await _storage.upsertLeaveType(type);
  }

  Future<void> deleteLeaveType(String typeId) async {
    await _storage.deleteLeaveType(typeId);
  }

  LeaveTypeModel? getLeaveTypeById(String id) {
    try {
      return _storage.getLeaveTypes().firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
