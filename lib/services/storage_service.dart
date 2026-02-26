import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/leave_request_model.dart';
import '../models/leave_type_model.dart';
import '../models/notification_model.dart';
import '../utils/app_constants.dart';

/// Handles all local JSON persistence using SharedPreferences.
/// Every write operation immediately saves to disk.
class StorageService {
  late SharedPreferences _prefs;

  /// Must be called once at app startup before using any other method.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─────────────────────────────────────────────
  // Seeding flag
  // ─────────────────────────────────────────────

  bool get isSeeded => _prefs.getBool(AppConstants.keyIsSeeded) ?? false;

  Future<void> markSeeded() async {
    await _prefs.setBool(AppConstants.keyIsSeeded, true);
  }

  // ─────────────────────────────────────────────
  // Session (current logged-in user)
  // ─────────────────────────────────────────────

  String? get currentUserId => _prefs.getString(AppConstants.keyCurrentUserId);

  Future<void> saveCurrentUserId(String userId) async {
    await _prefs.setString(AppConstants.keyCurrentUserId, userId);
  }

  Future<void> clearCurrentUserId() async {
    await _prefs.remove(AppConstants.keyCurrentUserId);
  }

  // ─────────────────────────────────────────────
  // Users
  // ─────────────────────────────────────────────

  List<UserModel> getUsers() {
    final raw = _prefs.getString(AppConstants.keyUsers);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUsers(List<UserModel> users) async {
    await _prefs.setString(
      AppConstants.keyUsers,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<void> upsertUser(UserModel user) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await saveUsers(users);
  }

  Future<void> deleteUser(String userId) async {
    final users = getUsers()..removeWhere((u) => u.id == userId);
    await saveUsers(users);
  }

  UserModel? getUserById(String id) {
    try {
      return getUsers().firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  UserModel? getUserByEmail(String email) {
    try {
      return getUsers()
          .firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Leave Requests
  // ─────────────────────────────────────────────

  List<LeaveRequestModel> getLeaveRequests() {
    final raw = _prefs.getString(AppConstants.keyLeaveRequests);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LeaveRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLeaveRequests(List<LeaveRequestModel> requests) async {
    await _prefs.setString(
      AppConstants.keyLeaveRequests,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> upsertLeaveRequest(LeaveRequestModel request) async {
    final requests = getLeaveRequests();
    final index = requests.indexWhere((r) => r.id == request.id);
    if (index >= 0) {
      requests[index] = request;
    } else {
      requests.add(request);
    }
    await saveLeaveRequests(requests);
  }

  Future<void> deleteLeaveRequest(String requestId) async {
    final requests = getLeaveRequests()
      ..removeWhere((r) => r.id == requestId);
    await saveLeaveRequests(requests);
  }

  LeaveRequestModel? getLeaveRequestById(String id) {
    try {
      return getLeaveRequests().firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<LeaveRequestModel> getLeaveRequestsByEmployee(String employeeId) {
    return getLeaveRequests()
        .where((r) => r.employeeId == employeeId)
        .toList();
  }

  List<LeaveRequestModel> getPendingRequestsForManager(String managerId) {
    // Returns pending requests from all employees whose managerId matches.
    final employees = getUsers()
        .where((u) => u.isEmployee && u.managerId == managerId)
        .map((u) => u.id)
        .toSet();
    return getLeaveRequests()
        .where((r) => r.isPending && employees.contains(r.employeeId))
        .toList();
  }

  // ─────────────────────────────────────────────
  // Leave Types
  // ─────────────────────────────────────────────

  List<LeaveTypeModel> getLeaveTypes() {
    final raw = _prefs.getString(AppConstants.keyLeaveTypes);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LeaveTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLeaveTypes(List<LeaveTypeModel> types) async {
    await _prefs.setString(
      AppConstants.keyLeaveTypes,
      jsonEncode(types.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> upsertLeaveType(LeaveTypeModel type) async {
    final types = getLeaveTypes();
    final index = types.indexWhere((t) => t.id == type.id);
    if (index >= 0) {
      types[index] = type;
    } else {
      types.add(type);
    }
    await saveLeaveTypes(types);
  }

  Future<void> deleteLeaveType(String typeId) async {
    final types = getLeaveTypes()..removeWhere((t) => t.id == typeId);
    await saveLeaveTypes(types);
  }

  // ─────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────

  List<NotificationModel> getNotifications() {
    final raw = _prefs.getString(AppConstants.keyNotifications);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    await _prefs.setString(
      AppConstants.keyNotifications,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> upsertNotification(NotificationModel notification) async {
    final notifications = getNotifications();
    final index =
        notifications.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      notifications[index] = notification;
    } else {
      notifications.add(notification);
    }
    await saveNotifications(notifications);
  }

  List<NotificationModel> getNotificationsForUser(String userId) {
    return getNotifications()
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int getUnreadCount(String userId) {
    return getNotificationsForUser(userId).where((n) => !n.isRead).length;
  }

  // ─────────────────────────────────────────────
  // Full reset (for testing / admin use)
  // ─────────────────────────────────────────────

  Future<void> clearAll() async {
    await _prefs.remove(AppConstants.keyUsers);
    await _prefs.remove(AppConstants.keyLeaveRequests);
    await _prefs.remove(AppConstants.keyLeaveTypes);
    await _prefs.remove(AppConstants.keyNotifications);
    await _prefs.remove(AppConstants.keyIsSeeded);
    await _prefs.remove(AppConstants.keyCurrentUserId);
  }
}
