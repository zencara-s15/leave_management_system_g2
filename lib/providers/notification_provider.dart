import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider(StorageService storage)
      : _service = NotificationService(storage);

  // ── Queries ────────────────────────────────────────────────────────────────

  List<NotificationModel> getForUser(String userId) =>
      _service.getForUser(userId);

  int getUnreadCount(String userId) => _service.getUnreadCount(userId);

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
    notifyListeners();
  }

  Future<void> markAllAsRead(String userId) async {
    await _service.markAllAsRead(userId);
    notifyListeners();
  }

  /// Call after any action that might have generated a new notification
  /// (e.g. after applying leave or approving a request) so the bell badge
  /// updates immediately.
  void refresh() => notifyListeners();
}
