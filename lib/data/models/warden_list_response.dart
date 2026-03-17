import 'package:json_annotation/json_annotation.dart';

part 'warden_list_response.g.dart';

@JsonSerializable()
class WardenListResponse {
  final bool success;
  final String message;
  final List<Warden> data;

  WardenListResponse({required this.success, required this.message, required this.data});

  factory WardenListResponse.fromJson(Map<String, dynamic> json) => _$WardenListResponseFromJson(json);
}

@JsonSerializable()
class Warden {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String mobile;
  final String email;
  final String status;
  final String address;

  Warden({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.status,
    required this.address,
  });

  factory Warden.fromJson(Map<String, dynamic> json) => _$WardenFromJson(json);
}