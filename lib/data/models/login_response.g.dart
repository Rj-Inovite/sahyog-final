// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      role: json['role'] as String,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'token': instance.token,
      'user': instance.user,
      'role': instance.role,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String?,
  profile: json['profile'] as String?,
  mobile: json['mobile'] as String,
  email: json['email'] as String,
  hostelId: (json['hostel_id'] as num).toInt(),
  admissionDate: json['admission_date'] as String?,
  status: json['status'] as String,
  userType: json['user_type'] as String,
  appUserType: json['app_user_type'] as String?,
  address: json['address'] as String?,
  deletedAt: json['deleted_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  roles: (json['roles'] as List<dynamic>)
      .map((e) => Role.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'profile': instance.profile,
  'mobile': instance.mobile,
  'email': instance.email,
  'hostel_id': instance.hostelId,
  'admission_date': instance.admissionDate,
  'status': instance.status,
  'user_type': instance.userType,
  'app_user_type': instance.appUserType,
  'address': instance.address,
  'deleted_at': instance.deletedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'roles': instance.roles,
};

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  guardName: json['guard_name'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  pivot: Pivot.fromJson(json['pivot'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'guard_name': instance.guardName,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'pivot': instance.pivot,
};

Pivot _$PivotFromJson(Map<String, dynamic> json) => Pivot(
  modelType: json['model_type'] as String,
  modelId: (json['model_id'] as num).toInt(),
  roleId: (json['role_id'] as num).toInt(),
);

Map<String, dynamic> _$PivotToJson(Pivot instance) => <String, dynamic>{
  'model_type': instance.modelType,
  'model_id': instance.modelId,
  'role_id': instance.roleId,
};
