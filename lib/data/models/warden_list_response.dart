import 'package:json_annotation/json_annotation.dart';

part 'warden_list_response.g.dart';

@JsonSerializable()
class WardenListResponse {
  final bool? success;

  @JsonKey(name: 'warden_list')
  final List<Warden>? wardenList;

  @JsonKey(name: 'hostel_name')
  final String? hostelName;

  @JsonKey(name: 'my_hostel_id')
  final int? myHostelId;

  // FIX: Added this field to resolve the "undefined getter" error
  @JsonKey(name: 'logged_in_warden')
  final String? loggedInWarden; 

  WardenListResponse({
    this.success, 
    this.wardenList, 
    this.hostelName,
    this.myHostelId,
    this.loggedInWarden,
  });

  // Helper to ensure .data always returns a list
  List<Warden> get data => wardenList ?? [];

  factory WardenListResponse.fromJson(Map<String, dynamic> json) => 
      _$WardenListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WardenListResponseToJson(this);
}

@JsonSerializable()
class Warden {
  final int? id;
  @JsonKey(name: 'warden_name')
  final String? wardenName;
  final String? mobile;
  final String? email;

  Warden({this.id, this.wardenName, this.mobile, this.email});

  factory Warden.fromJson(Map<String, dynamic> json) => _$WardenFromJson(json);
  Map<String, dynamic> toJson() => _$WardenToJson(this);
}