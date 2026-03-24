class ChildProfileResponse {
  final bool success;
  final List<ChildData>? data; // CHANGED: Now handles a List as seen in your API response
  final String? message;

  ChildProfileResponse({required this.success, this.data, this.message});

  factory ChildProfileResponse.fromJson(Map<String, dynamic> json) {
    return ChildProfileResponse(
      // Handles both bool (true/false) and string ("success") statuses
      success: json['success'] == true || json['status'] == 'success', 
      message: json['message']?.toString(),
      // Check if 'data' exists and is a List []
      data: (json['data'] != null && json['data'] is List)
          ? (json['data'] as List).map((i) => ChildData.fromJson(i)).toList()
          : null,
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
      // Flexible mapping for 'full_name' or 'name'
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? 'No Name Provided',
      
      // Safety for studentId: checks multiple possible keys and converts to String
      studentId: (json['student_id'] ?? json['student_code'] ?? json['id'] ?? '0').toString(),
      
      email: json['email']?.toString() ?? 'N/A',
      mobile: json['mobile']?.toString() ?? 'N/A',
      
      academicDetails: (json['academic_details'] != null && json['academic_details'] is Map)
          ? AcademicDetails.fromJson(json['academic_details'])
          : null,
          
      hostelInfo: (json['hostel_info'] != null && json['hostel_info'] is Map)
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
      institute: json['institute']?.toString(),
      course: json['course']?.toString(),
      admissionDate: json['admission_date']?.toString(),
    );
  }

  // Helper to display formatted date in UI
  String get formattedDate {
    if (admissionDate == null || admissionDate!.isEmpty) return "N/A";
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
      // Safely parses hostel_id even if it comes as a String
      hostelId: int.tryParse(json['hostel_id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'inactive',
    );
  }

  // Capitalizes status for better UI display (e.g., "Active")
  String get displayStatus {
    if (status.isEmpty) return "Unknown";
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}