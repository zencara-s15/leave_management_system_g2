class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'employee', 'manager', 'admin'
  final String department;
  final String position;
  final String? managerId; // null for managers/admins
  final Map<String, int> leaveBalances; // e.g. {'sick': 10, 'casual': 7, 'vacation': 15}
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.department,
    required this.position,
    this.managerId,
    required this.leaveBalances,
    this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      managerId: json['managerId'] as String?,
      leaveBalances: Map<String, int>.from(json['leaveBalances'] as Map),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'department': department,
      'position': position,
      'managerId': managerId,
      'leaveBalances': leaveBalances,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? department,
    String? position,
    String? managerId,
    Map<String, int>? leaveBalances,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      department: department ?? this.department,
      position: position ?? this.position,
      managerId: managerId ?? this.managerId,
      leaveBalances: leaveBalances ?? Map.from(this.leaveBalances),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Equality by id so DropdownButton can match instances across rebuilds
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  bool get isEmployee => role == 'employee';
  bool get isManager => role == 'manager';
  bool get isAdmin => role == 'admin';
}
