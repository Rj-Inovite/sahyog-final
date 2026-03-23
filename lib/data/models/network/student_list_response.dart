import 'package:json_annotation/json_annotation.dart';

part 'student_list_response.g.dart';

@JsonSerializable()
class StudentListResponse {
  final bool success;
  @JsonKey(name: 'hostel_id')
  final int? hostelId;
  final int count;
  final List<Student> students;

  StudentListResponse({
    required this.success,
    this.hostelId,
    required this.count,
    required this.students,
  });

  factory StudentListResponse.fromJson(Map<String, dynamic> json) => _$StudentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StudentListResponseToJson(this);
}

@JsonSerializable()
class Student {
  final int id;
  @JsonKey(name: 'student_code')
  final dynamic studentCode; // Handles both String and Int codes from backend
  
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String? lastName;
  
  final String? mobile;
  final String? email;
  final String status;
  final String? address;
  
  @JsonKey(name: 'admission_date')
  final String? admissionDate;

  @JsonKey(name: 'room_info')
  final Map<String, dynamic>? roomInfo; // Re-enabled safely as a nullable Map

  Student({
    required this.id,
    required this.studentCode,
    required this.firstName,
    this.lastName,
    this.mobile,
    this.email,
    required this.status,
    this.address,
    this.admissionDate,
    this.roomInfo, 
  });

  // --- UI HELPERS ---

  /// Returns the full name or just the first name if last name is missing
  String get fullName => "${firstName} ${lastName ?? ''}".trim();

  /// Safely extracts the room number for the Warden UI
  String get displayRoom {
    if (roomInfo == null) return "N/A";
    return roomInfo!['room_number']?.toString() ?? "N/A";
  }

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}