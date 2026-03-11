class LeaveResponse {
  final String message;
  final LeaveData data;

  LeaveResponse({required this.message, required this.data});

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    return LeaveResponse(
      message: json['message'],
      data: LeaveData.fromJson(json['data']),
    );
  }
}

class LeaveData {
  final int userId;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final int createdBy;
  final String updatedAt;
  final String createdAt;
  final int id;

  LeaveData({
    required this.userId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdBy,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      userId: json['user_id'],
      leaveType: json['leave_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      reason: json['reason'],
      status: json['status'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
    );
  }
}
