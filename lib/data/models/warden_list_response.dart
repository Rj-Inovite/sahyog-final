import 'package:json_annotation/json_annotation.dart';

part 'warden_list_response.g.dart';

@JsonSerializable()
class WardenListResponse {
  final bool? success; // Changed to nullable for safety
  
  // This maps the API's "warden_list" key. 
  // If your API sends the list inside a key named "data", change 'warden_list' to 'data'
  @JsonKey(name: 'warden_list')
  final List<Warden>? data;

  @JsonKey(name: 'hostel_name')
  final String? hostelName;

  @JsonKey(name: 'my_hostel_id')
  final int? myHostelId;

  WardenListResponse({
    this.success, 
    this.data, 
    this.hostelName,
    this.myHostelId,
  });

  factory WardenListResponse.fromJson(Map<String, dynamic> json) => 
      _$WardenListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WardenListResponseToJson(this);
}

@JsonSerializable()
class Warden {
  final int? id; // Nullable to prevent crashes on missing IDs
  
  @JsonKey(name: 'warden_name')
  final String? wardenName;
  
  final String? mobile;
  final String? email;

  Warden({
    this.id, 
    this.wardenName, 
    this.mobile, 
    this.email
  });

  factory Warden.fromJson(Map<String, dynamic> json) => 
      _$WardenFromJson(json);

  Map<String, dynamic> toJson() => _$WardenToJson(this);
}