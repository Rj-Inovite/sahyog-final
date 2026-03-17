// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warden_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WardenListResponse _$WardenListResponseFromJson(Map<String, dynamic> json) =>
    WardenListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Warden.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WardenListResponseToJson(WardenListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

Warden _$WardenFromJson(Map<String, dynamic> json) => Warden(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$WardenToJson(Warden instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile': instance.mobile,
      'email': instance.email,
      'status': instance.status,
      'address': instance.address,
    };
