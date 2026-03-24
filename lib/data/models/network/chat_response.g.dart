// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      chatDetails: json['chat_details'] == null
          ? null
          : ChatDetails.fromJson(json['chat_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'chat_details': instance.chatDetails,
    };

ChatDetails _$ChatDetailsFromJson(Map<String, dynamic> json) => ChatDetails(
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      messageId: (json['message_id'] as num?)?.toInt(),
      content: json['content'] as String?,
      from: json['from'] == null
          ? null
          : ChatUser.fromJson(json['from'] as Map<String, dynamic>),
      to: json['to'] == null
          ? null
          : ChatUser.fromJson(json['to'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatDetailsToJson(ChatDetails instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'message_id': instance.messageId,
      'content': instance.content,
      'from': instance.from,
      'to': instance.to,
    };

ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => ChatUser(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ChatUserToJson(ChatUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
