class ParentLeaveResponse {
  final bool? success;
  final String? childName;
  final String? studentCode;
  final int? leaveCount;
  final List<Leave>? leaves;

  ParentLeaveResponse({this.success, this.childName, this.studentCode, this.leaveCount, this.leaves});

  factory ParentLeaveResponse.fromJson(Map<String, dynamic> json) => ParentLeaveResponse(
    success: json['success'],
    childName: json['child_name'],
    studentCode: json['student_code'],
    leaveCount: json['leave_count'],
    leaves: (json['leaves'] as List?)?.map((e) => Leave.fromJson(e)).toList(),
  );
}

class Leave {
  final int? id;
  final String? leaveType;
  final String? startDate;
  final String? endDate;
  final String? reason;
  final String? status;

  Leave({this.id, this.leaveType, this.startDate, this.endDate, this.reason, this.status});

  factory Leave.fromJson(Map<String, dynamic> json) => Leave(
    id: json['id'],
    leaveType: json['leave_type'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    reason: json['reason'],
    status: json['status'],
  );
}