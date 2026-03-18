// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentListResponse _$StudentListResponseFromJson(Map<String, dynamic> json) =>
    StudentListResponse(
      success: json['success'] as bool,
      hostelId: (json['hostel_id'] as num?)?.toInt(),
      count: (json['count'] as num).toInt(),
      students: (json['students'] as List<dynamic>)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentListResponseToJson(
        StudentListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'hostel_id': instance.hostelId,
      'count': instance.count,
      'students': instance.students,
    };

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: (json['id'] as num).toInt(),
      studentCode: json['student_code'],
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String,
      address: json['address'] as String?,
      admissionDate: json['admission_date'] as String?,
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'student_code': instance.studentCode,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile': instance.mobile,
      'email': instance.email,
      'status': instance.status,
      'address': instance.address,
      'admission_date': instance.admissionDate,
    };
