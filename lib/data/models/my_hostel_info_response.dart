import 'package:json_annotation/json_annotation.dart';

part 'my_hostel_info_response.g.dart';

@JsonSerializable()
class MyHostelInfoResponse {
  final String? status;
  final HostelData? data;

  MyHostelInfoResponse({this.status, this.data});

  factory MyHostelInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$MyHostelInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyHostelInfoResponseToJson(this);
}

@JsonSerializable()
class HostelData {
  @JsonKey(name: 'student_name')
  final String? studentName;
  @JsonKey(name: 'hostel_id')
  final int? hostelId;
  @JsonKey(name: 'hostel_name')
  final String? hostelName;
  @JsonKey(name: 'assigned_managers')
  final List<Manager>? assignedManagers;

  HostelData({
    this.studentName,
    this.hostelId,
    this.hostelName,
    this.assignedManagers,
  });

  factory HostelData.fromJson(Map<String, dynamic> json) =>
      _$HostelDataFromJson(json);

  Map<String, dynamic> toJson() => _$HostelDataToJson(this);
}

@JsonSerializable()
class Manager {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? mobile;
  final String? email;
  final String? profile;

  Manager({
    this.firstName,
    this.lastName,
    this.mobile,
    this.email,
    this.profile,
  });

  factory Manager.fromJson(Map<String, dynamic> json) =>
      _$ManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ManagerToJson(this);
}