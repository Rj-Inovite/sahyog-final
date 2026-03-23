import 'package:json_annotation/json_annotation.dart';

part 'attendance_response.g.dart';

@JsonSerializable()
class AttendanceResponse {
  final bool success;
  
  @JsonKey(name: 'hostel_id')
  final int? hostelId;
  
  final AttendanceSummary? summary;
  
  @JsonKey(defaultValue: [])
  final List<AttendanceData> data;

  AttendanceResponse({
    required this.success,
    this.hostelId,
    this.summary,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) => 
      _$AttendanceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceResponseToJson(this);
}

@JsonSerializable()
class AttendanceSummary {
  @JsonKey(name: 'total_records', defaultValue: 0)
  final int totalRecords;
  
  @JsonKey(defaultValue: 0)
  final int present;
  
  @JsonKey(defaultValue: 0)
  final int absent;

  AttendanceSummary({
    required this.totalRecords, 
    required this.present, 
    required this.absent
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) => 
      _$AttendanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);
}

@JsonSerializable()
class AttendanceData {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(name: 'student_id', defaultValue: 0)
  final int studentId;

  @JsonKey(defaultValue: 'absent')
  final String status;

  @JsonKey(name: 'attendance_date')
  final String? attendanceDate;

  @JsonKey(name: 'attendance_session')
  final String? attendanceSession;

  @JsonKey(name: 'student_first_name', defaultValue: '')
  final String firstName;

  @JsonKey(name: 'student_last_name', defaultValue: '')
  final String lastName;

  @JsonKey(name: 'student_code', defaultValue: '')
  final String studentCode;

  AttendanceData({
    required this.id,
    required this.studentId,
    required this.status,
    this.attendanceDate,
    this.attendanceSession,
    required this.firstName,
    required this.lastName,
    required this.studentCode,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => 
      _$AttendanceDataFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceDataToJson(this);
}