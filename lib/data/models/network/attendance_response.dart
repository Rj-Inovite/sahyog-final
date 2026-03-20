class AttendanceResponse {
  final bool success;
  final int? hostelId;
  final AttendanceSummary? summary;
  final List<AttendanceData> data;

  AttendanceResponse({
    required this.success,
    this.hostelId,
    this.summary,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      hostelId: json['hostel_id'],
      summary: json['summary'] != null ? AttendanceSummary.fromJson(json['summary']) : null,
      data: (json['data'] as List? ?? []).map((e) => AttendanceData.fromJson(e)).toList(),
    );
  }
}

class AttendanceSummary {
  final int totalRecords;
  final int present;
  final int absent;

  AttendanceSummary({required this.totalRecords, required this.present, required this.absent});

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalRecords: json['total_records'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }
}

class AttendanceData {
  final int id;
  final int studentId;
  final String status;
  final String? attendanceDate;
  final String? attendanceSession;
  final String firstName;
  final String lastName;
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

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      status: json['status'] ?? 'absent',
      attendanceDate: json['attendance_date'],
      attendanceSession: json['attendance_session'],
      firstName: json['student_first_name'] ?? '',
      lastName: json['student_last_name'] ?? '',
      studentCode: json['student_code'] ?? '',
    );
  }
}