import 'package:json_annotation/json_annotation.dart';

part 'student_list_response.g.dart';

@JsonSerializable()
class StudentListResponse {
  final bool success;
  @JsonKey(name: 'hostel_id')
  final int hostelId;
  final int count;
  final List<Student> students;

  StudentListResponse({required this.success, required this.hostelId, required this.count, required this.students});

  factory StudentListResponse.fromJson(Map<String, dynamic> json) => _$StudentListResponseFromJson(json);
}

@JsonSerializable()
class Student {
  final int id;
  @JsonKey(name: 'student_code')
  final String studentCode;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String mobile;
  final String email;
  final String status;
  final String? address;
  @JsonKey(name: 'admission_date')
  final String admissionDate;
  @JsonKey(name: 'room_info')
  final String roomInfo;

  Student({
    required this.id,
    required this.studentCode,
    required this.firstName,
    this.lastName,
    required this.mobile,
    required this.email,
    required this.status,
    this.address,
    required this.admissionDate,
    required this.roomInfo,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}