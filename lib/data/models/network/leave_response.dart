class LeaveResponse {
  final bool? success; // Added to match your Postman screenshot
  final String message;
  final LeaveData? data;

  LeaveResponse({
    this.success,
    required this.message,
    this.data,
  });

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    return LeaveResponse(
      success: json['success'] as bool?,
      message: json['message'] ?? "",
      data: json['data'] != null ? LeaveData.fromJson(json['data']) : null,
    );
  }
}

class LeaveData {
  final int id;
  final int userId;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final int? approvedByParent; // Added for the approval flow
  final int? approvedByWarden; // Added for the full workflow
  final String createdAt;
  final String updatedAt;

  LeaveData({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedByParent,
    this.approvedByWarden,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      // We use ?? logic to handle different key names from different endpoints
      id: json['id'] ?? json['leave_id'] ?? 0,
      userId: json['user_id'] ?? json['student_user_id'] ?? 0,
      leaveType: json['leave_type'] ?? "N/A",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      reason: json['reason'] ?? "",
      status: json['status'] ?? "pending",
      approvedByParent: json['approved_by_parent'],
      approvedByWarden: json['approved_by_warden'],
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}