// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceResponse _$AttendanceResponseFromJson(Map<String, dynamic> json) =>
    AttendanceResponse(
      success: json['success'] as bool,
      hostelId: (json['hostel_id'] as num?)?.toInt(),
      summary: json['summary'] == null
          ? null
          : AttendanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AttendanceData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AttendanceResponseToJson(AttendanceResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'hostel_id': instance.hostelId,
      'summary': instance.summary,
      'data': instance.data,
    };

AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    AttendanceSummary(
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AttendanceSummaryToJson(AttendanceSummary instance) =>
    <String, dynamic>{
      'total_records': instance.totalRecords,
      'present': instance.present,
      'absent': instance.absent,
    };

AttendanceData _$AttendanceDataFromJson(Map<String, dynamic> json) =>
    AttendanceData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'absent',
      attendanceDate: json['attendance_date'] as String?,
      attendanceSession: json['attendance_session'] as String?,
      firstName: json['student_first_name'] as String? ?? '',
      lastName: json['student_last_name'] as String? ?? '',
      studentCode: json['student_code'] as String? ?? '',
    );

Map<String, dynamic> _$AttendanceDataToJson(AttendanceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'status': instance.status,
      'attendance_date': instance.attendanceDate,
      'attendance_session': instance.attendanceSession,
      'student_first_name': instance.firstName,
      'student_last_name': instance.lastName,
      'student_code': instance.studentCode,
    };
