// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordUpdateRequest _$PasswordUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    PasswordUpdateRequest(
      userId: json['user_id'] as String,
      oldPassword: json['old_password'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );

Map<String, dynamic> _$PasswordUpdateRequestToJson(
        PasswordUpdateRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'old_password': instance.oldPassword,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
    };

PasswordUpdateResponse _$PasswordUpdateResponseFromJson(
        Map<String, dynamic> json) =>
    PasswordUpdateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$PasswordUpdateResponseToJson(
        PasswordUpdateResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
