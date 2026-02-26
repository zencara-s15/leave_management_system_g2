class LeaveTypeModel {
  final String id;
  final String name;
  final String code; // e.g. 'sick', 'casual', 'vacation', 'maternity', 'paternity'
  final int maxDaysPerYear;
  final String description;
  final bool carryForward; // whether unused days carry to next year
  final bool requiresDocumentation;
  final bool isActive;
  final DateTime createdAt;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.maxDaysPerYear,
    required this.description,
    this.carryForward = false,
    this.requiresDocumentation = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      maxDaysPerYear: json['maxDaysPerYear'] as int,
      description: json['description'] as String,
      carryForward: json['carryForward'] as bool? ?? false,
      requiresDocumentation: json['requiresDocumentation'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'maxDaysPerYear': maxDaysPerYear,
      'description': description,
      'carryForward': carryForward,
      'requiresDocumentation': requiresDocumentation,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Equality by id so DropdownButton can match instances across rebuilds
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  LeaveTypeModel copyWith({
    String? id,
    String? name,
    String? code,
    int? maxDaysPerYear,
    String? description,
    bool? carryForward,
    bool? requiresDocumentation,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return LeaveTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      maxDaysPerYear: maxDaysPerYear ?? this.maxDaysPerYear,
      description: description ?? this.description,
      carryForward: carryForward ?? this.carryForward,
      requiresDocumentation: requiresDocumentation ?? this.requiresDocumentation,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
