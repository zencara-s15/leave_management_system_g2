/// App-wide constants.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Leave Management System';
  static const String appNameLogin = 'Welcome Back to LMS!';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys (used by StorageService)
  static const String keyUsers = 'lms_users';
  static const String keyLeaveRequests = 'lms_leave_requests';
  static const String keyLeaveTypes = 'lms_leave_types';
  static const String keyNotifications = 'lms_notifications';
  static const String keyIsSeeded = 'lms_is_seeded';
  static const String keyCurrentUserId = 'lms_current_user_id';

  // User roles
  static const String roleEmployee = 'employee';
  static const String roleManager = 'manager';
  static const String roleAdmin = 'admin';

  // Leave request statuses
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Leave type codes
  static const String leaveTypeSick = 'sick';
  static const String leaveTypeCasual = 'casual';
  static const String leaveTypeVacation = 'vacation';
  static const String leaveTypeMaternity = 'maternity';
  static const String leaveTypePaternity = 'paternity';

  // Notification types
  static const String notifNewRequest = 'new_request';
  static const String notifApproved = 'approved';
  static const String notifRejected = 'rejected';
  static const String notifGeneral = 'general';

  // Default leave balances per year (admin can override via Leave Policies)
  static const Map<String, int> defaultLeaveBalances = {
    'sick': 10,
    'casual': 7,
    'vacation': 15,
    'maternity': 90,
    'paternity': 5,
  };

  // UI
  static const double cardRadius = 12.0;
  static const double buttonRadius = 10.0;
  static const double inputRadius = 8.0;
  static const double pagePadding = 16.0;
}
