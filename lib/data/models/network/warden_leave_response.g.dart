// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warden_leave_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WardenLeaveResponse _$WardenLeaveResponseFromJson(Map<String, dynamic> json) =>
    WardenLeaveResponse(
      success: json['success'] as bool?,
      hostelId: (json['hostel_id'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WardenLeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WardenLeaveResponseToJson(
        WardenLeaveResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'hostel_id': instance.hostelId,
      'data': instance.data,
    };

WardenLeaveRecord _$WardenLeaveRecordFromJson(Map<String, dynamic> json) =>
    WardenLeaveRecord(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['student_id'] as num?)?.toInt(),
      leaveType: json['leave_type'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String?,
      parentApprovedAt: json['parent_approved_at'] as String?,
      managerApprovedAt: json['manager_approved_at'] as String?,
      student: json['student'] == null
          ? null
          : WardenStudentDetail.fromJson(
              json['student'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WardenLeaveRecordToJson(WardenLeaveRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'leave_type': instance.leaveType,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'reason': instance.reason,
      'status': instance.status,
      'parent_approved_at': instance.parentApprovedAt,
      'manager_approved_at': instance.managerApprovedAt,
      'student': instance.student,
    };

WardenStudentDetail _$WardenStudentDetailFromJson(Map<String, dynamic> json) =>
    WardenStudentDetail(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String?,
      name: json['name'] as String?,
      hostelId: (json['hostel_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WardenStudentDetailToJson(
        WardenStudentDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'hostel_id': instance.hostelId,
    };
