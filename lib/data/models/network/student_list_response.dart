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
  final dynamic studentCode; // Handles both String and Int codes
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

  // --- ROOM INFO DISABLED FOR NOW ---
  // @JsonKey(name: 'room_info')
  // final dynamic roomInfo;

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
    // required this.roomInfo, // Commented out to prevent casting errors
  });

  /// Helper method disabled to prevent UI errors
  /*
  String getDisplayRoom() {
    if (roomInfo == null) return "Not Assigned";
    if (roomInfo is Map) {
      final room = roomInfo as Map<String, dynamic>;
      return "Room ${room['room_number'] ?? 'N/A'} (Bed ${room['bed_number'] ?? 'N/A'})";
    }
    return roomInfo.toString();
  }
  */

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}