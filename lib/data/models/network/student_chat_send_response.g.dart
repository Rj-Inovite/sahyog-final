// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_chat_send_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentChatSendResponse _$StudentChatSendResponseFromJson(
        Map<String, dynamic> json) =>
    StudentChatSendResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      chatDetails: json['chat_details'] == null
          ? null
          : StudentChatDetails.fromJson(
              json['chat_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentChatSendResponseToJson(
        StudentChatSendResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'chat_details': instance.chatDetails,
    };

StudentChatDetails _$StudentChatDetailsFromJson(Map<String, dynamic> json) =>
    StudentChatDetails(
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      messageId: (json['message_id'] as num?)?.toInt(),
      content: json['content'] as String?,
      from: json['from'] == null
          ? null
          : StudentChatUser.fromJson(json['from'] as Map<String, dynamic>),
      to: json['to'] == null
          ? null
          : StudentChatUser.fromJson(json['to'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentChatDetailsToJson(StudentChatDetails instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'message_id': instance.messageId,
      'content': instance.content,
      'from': instance.from,
      'to': instance.to,
    };

StudentChatUser _$StudentChatUserFromJson(Map<String, dynamic> json) =>
    StudentChatUser(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$StudentChatUserToJson(StudentChatUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
