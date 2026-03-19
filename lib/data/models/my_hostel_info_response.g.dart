// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_hostel_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyHostelInfoResponse _$MyHostelInfoResponseFromJson(
        Map<String, dynamic> json) =>
    MyHostelInfoResponse(
      status: json['status'] as String?,
      data: json['data'] == null
          ? null
          : HostelData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MyHostelInfoResponseToJson(
        MyHostelInfoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

HostelData _$HostelDataFromJson(Map<String, dynamic> json) => HostelData(
      studentName: json['student_name'] as String?,
      hostelId: (json['hostel_id'] as num?)?.toInt(),
      hostelName: json['hostel_name'] as String?,
      assignedManagers: (json['assigned_managers'] as List<dynamic>?)
          ?.map((e) => Manager.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HostelDataToJson(HostelData instance) =>
    <String, dynamic>{
      'student_name': instance.studentName,
      'hostel_id': instance.hostelId,
      'hostel_name': instance.hostelName,
      'assigned_managers': instance.assignedManagers,
    };

Manager _$ManagerFromJson(Map<String, dynamic> json) => Manager(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      profile: json['profile'] as String?,
    );

Map<String, dynamic> _$ManagerToJson(Manager instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile': instance.mobile,
      'email': instance.email,
      'profile': instance.profile,
    };
