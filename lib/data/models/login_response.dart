import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final User user;
  final String role;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class User {
  final int id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'first_name')
  final String firstName;

  // ✅ FIXED: Marked as nullable because logs show this as null for some users
  @JsonKey(name: 'last_name')
  final String? lastName;

  final String? profile;
  final String mobile;
  final String email;

  @JsonKey(name: 'hostel_id')
  final int hostelId;

  @JsonKey(name: 'admission_date')
  final String? admissionDate;

  final String status;

  @JsonKey(name: 'user_type')
  final String userType;

  @JsonKey(name: 'app_user_type')
  final String? appUserType;

  final String? address;

  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  final List<Role> roles;

  User({
    required this.id,
    required this.userId,
    required this.firstName,
    this.lastName, // ✅ Now optional
    this.profile,
    required this.mobile,
    required this.email,
    required this.hostelId,
    this.admissionDate,
    required this.status,
    required this.userType,
    this.appUserType,
    this.address,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Role {
  final int id;
  final String name;

  @JsonKey(name: 'guard_name')
  final String guardName;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  final Pivot pivot;

  Role({
    required this.id,
    required this.name,
    required this.guardName,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  factory Role.fromJson(Map<String, dynamic> json) =>
      _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@JsonSerializable()
class Pivot {
  @JsonKey(name: 'model_type')
  final String modelType;

  @JsonKey(name: 'model_id')
  final int modelId;

  @JsonKey(name: 'role_id')
  final int roleId;

  Pivot({
    required this.modelType,
    required this.modelId,
    required this.roleId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) =>
      _$PivotFromJson(json);

  Map<String, dynamic> toJson() => _$PivotToJson(this);
}