import 'package:uuid/uuid.dart';
import '../models/leave_request_model.dart';
import '../models/notification_model.dart';
import '../utils/app_constants.dart';
import 'storage_service.dart';

/// Creates and manages in-app notifications stored locally.
class NotificationService {
  final StorageService _storage;
  static const _uuid = Uuid();

  NotificationService(this._storage);

  // ── Notify manager of a new leave request ─────────────────────────────────

  Future<void> notifyNewRequest({
    required String managerId,
    required LeaveRequestModel request,
  }) async {
    final notification = NotificationModel(
      id: _uuid.v4(),
      userId: managerId,
      title: 'New Leave Request',
      message:
          '${request.employeeName} has applied for ${request.leaveTypeName} '
          '(${request.totalDays} day(s)).',
      type: AppConstants.notifNewRequest,
      isRead: false,
      createdAt: DateTime.now(),
      relatedRequestId: request.id,
    );
    await _storage.upsertNotification(notification);
  }

  // ── Notify employee of approval / rejection ────────────────────────────────

  Future<void> notifyRequestDecision({
    required LeaveRequestModel request,
  }) async {
    final isApproved = request.status == AppConstants.statusApproved;
    final notification = NotificationModel(
      id: _uuid.v4(),
      userId: request.employeeId,
      title: isApproved ? 'Leave Approved' : 'Leave Rejected',
      message: isApproved
          ? 'Your ${request.leaveTypeName} request has been approved by ${request.approverName ?? "your manager"}.'
          : 'Your ${request.leaveTypeName} request has been rejected. '
              '${request.approverNote?.isNotEmpty == true ? 'Reason: ${request.approverNote}' : ''}',
      type: isApproved ? AppConstants.notifApproved : AppConstants.notifRejected,
      isRead: false,
      createdAt: DateTime.now(),
      relatedRequestId: request.id,
    );
    await _storage.upsertNotification(notification);
  }

  // ── General broadcast (admin use) ─────────────────────────────────────────

  Future<void> broadcastToAll({
    required String title,
    required String message,
  }) async {
    final users = _storage.getUsers();
    for (final user in users) {
      final notification = NotificationModel(
        id: _uuid.v4(),
        userId: user.id,
        title: title,
        message: message,
        type: AppConstants.notifGeneral,
        isRead: false,
        createdAt: DateTime.now(),
      );
      await _storage.upsertNotification(notification);
    }
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  List<NotificationModel> getForUser(String userId) {
    return _storage.getNotificationsForUser(userId);
  }

  int getUnreadCount(String userId) {
    return _storage.getUnreadCount(userId);
  }

  // ── Mark as read ──────────────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    final all = _storage.getNotifications();
    final index = all.indexWhere((n) => n.id == notificationId);
    if (index < 0) return;
    await _storage.upsertNotification(all[index].copyWith(isRead: true));
  }

  Future<void> markAllAsRead(String userId) async {
    final all = _storage.getNotifications();
    final updated = all.map((n) {
      if (n.userId == userId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    await _storage.saveNotifications(updated);
  }
}
