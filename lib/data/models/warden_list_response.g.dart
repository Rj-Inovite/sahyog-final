// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warden_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WardenListResponse _$WardenListResponseFromJson(Map<String, dynamic> json) =>
    WardenListResponse(
      success: json['success'] as bool?,
      data: (json['warden_list'] as List<dynamic>?)
          ?.map((e) => Warden.fromJson(e as Map<String, dynamic>))
          .toList(),
      hostelName: json['hostel_name'] as String?,
      myHostelId: (json['my_hostel_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WardenListResponseToJson(WardenListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'warden_list': instance.data,
      'hostel_name': instance.hostelName,
      'my_hostel_id': instance.myHostelId,
    };

Warden _$WardenFromJson(Map<String, dynamic> json) => Warden(
      id: (json['id'] as num?)?.toInt(),
      wardenName: json['warden_name'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$WardenToJson(Warden instance) => <String, dynamic>{
      'id': instance.id,
      'warden_name': instance.wardenName,
      'mobile': instance.mobile,
      'email': instance.email,
    };
