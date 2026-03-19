class ChildProfileResponse {
  final bool success;
  final ChildData? data;

  ChildProfileResponse({required this.success, this.data});

  factory ChildProfileResponse.fromJson(Map<String, dynamic> json) {
    return ChildProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? ChildData.fromJson(json['data']) : null,
    );
  }
}

class ChildData {
  final String fullName;
  final String studentId;
  final String email;
  final String mobile;
  final AcademicDetails? academicDetails;
  final HostelInfo? hostelInfo;

  ChildData({
    required this.fullName,
    required this.studentId,
    required this.email,
    required this.mobile,
    this.academicDetails,
    this.hostelInfo,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      fullName: json['full_name'] ?? 'N/A',
      studentId: json['student_id'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      mobile: json['mobile'] ?? 'N/A',
      academicDetails: json['academic_details'] != null 
          ? AcademicDetails.fromJson(json['academic_details']) 
          : null,
      hostelInfo: json['hostel_info'] != null 
          ? HostelInfo.fromJson(json['hostel_info']) 
          : null,
    );
  }
}

class AcademicDetails {
  final String? institute;
  final String? course;
  final String? admissionDate;

  AcademicDetails({this.institute, this.course, this.admissionDate});

  factory AcademicDetails.fromJson(Map<String, dynamic> json) {
    return AcademicDetails(
      institute: json['institute'],
      course: json['course'],
      admissionDate: json['admission_date'],
    );
  }

  /// Helper to convert the API's ISO date string into a readable format (DD/MM/YYYY)
  String get formattedDate {
    if (admissionDate == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(admissionDate!);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (e) {
      return "N/A";
    }
  }
}

class HostelInfo {
  final int hostelId;
  final String status;

  HostelInfo({required this.hostelId, required this.status});

  factory HostelInfo.fromJson(Map<String, dynamic> json) {
    return HostelInfo(
      hostelId: json['hostel_id'] ?? 0,
      status: json['status'] ?? 'Inactive',
    );
  }

  /// Helper to get a capitalized status for UI display
  String get displayStatus {
    if (status.isEmpty) return "Unknown";
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}