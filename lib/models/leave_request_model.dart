class LeaveRequestModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String leaveTypeId;
  final String leaveTypeName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? approverId;
  final String? approverName;
  final String? approverNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = 'pending',
    this.approverId,
    this.approverName,
    this.approverNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      leaveTypeId: json['leaveTypeId'] as String,
      leaveTypeName: json['leaveTypeName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: json['totalDays'] as int,
      reason: json['reason'] as String,
      status: json['status'] as String? ?? 'pending',
      approverId: json['approverId'] as String?,
      approverName: json['approverName'] as String?,
      approverNote: json['approverNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'leaveTypeId': leaveTypeId,
      'leaveTypeName': leaveTypeName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'approverId': approverId,
      'approverName': approverName,
      'approverNote': approverNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LeaveRequestModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? leaveTypeId,
    String? leaveTypeName,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? reason,
    String? status,
    String? approverId,
    String? approverName,
    String? approverNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      leaveTypeId: leaveTypeId ?? this.leaveTypeId,
      leaveTypeName: leaveTypeName ?? this.leaveTypeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      approverNote: approverNote ?? this.approverNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
