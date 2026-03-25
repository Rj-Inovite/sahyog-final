import 'package:json_annotation/json_annotation.dart';

part 'warden_leave_response.g.dart';

@JsonSerializable()
class WardenLeaveResponse {
  final bool? success;
  
  @JsonKey(name: 'hostel_id')
  final int? hostelId;
  
  final List<WardenLeaveRecord>? data;

  WardenLeaveResponse({
    this.success,
    this.hostelId,
    this.data,
  });

  factory WardenLeaveResponse.fromJson(Map<String, dynamic> json) =>
      _$WardenLeaveResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WardenLeaveResponseToJson(this);
}

@JsonSerializable()
class WardenLeaveRecord {
  final int? id;

  // ✅ ADDED: student_id to resolve the 'studentId' isn't defined error in your View
  @JsonKey(name: 'student_id')
  final int? studentId;

  @JsonKey(name: 'leave_type')
  final String? leaveType;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'end_date')
  final String? endDate;

  final String? reason;
  final String? status;
  
  @JsonKey(name: 'parent_approved_at')
  final String? parentApprovedAt;
  
  @JsonKey(name: 'manager_approved_at')
  final String? managerApprovedAt;

  // Nested Student object
  final WardenStudentDetail? student;

  WardenLeaveRecord({
    this.id,
    this.studentId, // ✅ Included in constructor
    this.leaveType,
    this.startDate,
    this.endDate,
    this.reason,
    this.status,
    this.parentApprovedAt,
    this.managerApprovedAt,
    this.student,
  });

  factory WardenLeaveRecord.fromJson(Map<String, dynamic> json) =>
      _$WardenLeaveRecordFromJson(json);

  Map<String, dynamic> toJson() => _$WardenLeaveRecordToJson(this);
}

@JsonSerializable()
class WardenStudentDetail {
  final int? id;
  final String? email;
  
  // ✅ ADDED: name field because your UI code uses student?.name
  final String? name;

  @JsonKey(name: 'hostel_id')
  final int? hostelId;

  WardenStudentDetail({
    this.id, 
    this.email, 
    this.name, // ✅ Added to constructor
    this.hostelId,
  });

  factory WardenStudentDetail.fromJson(Map<String, dynamic> json) =>
      _$WardenStudentDetailFromJson(json);

  Map<String, dynamic> toJson() => _$WardenStudentDetailToJson(this);
}