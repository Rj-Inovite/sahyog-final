import 'package:json_annotation/json_annotation.dart';

part 'student_chat_send_response.g.dart';

@JsonSerializable()
class StudentChatSendResponse {
  final bool? success;
  final String? message;
  @JsonKey(name: 'chat_details')
  final StudentChatDetails? chatDetails;

  StudentChatSendResponse({this.success, this.message, this.chatDetails});

  factory StudentChatSendResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentChatSendResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StudentChatSendResponseToJson(this);
}

@JsonSerializable()
class StudentChatDetails {
  @JsonKey(name: 'conversation_id')
  final int? conversationId;
  @JsonKey(name: 'message_id')
  final int? messageId;
  final String? content;
  final StudentChatUser? from;
  final StudentChatUser? to;

  StudentChatDetails({
    this.conversationId,
    this.messageId,
    this.content,
    this.from,
    this.to,
  });

  factory StudentChatDetails.fromJson(Map<String, dynamic> json) =>
      _$StudentChatDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$StudentChatDetailsToJson(this);
}

@JsonSerializable()
class StudentChatUser {
  final int? id;
  final String? name;

  StudentChatUser({this.id, this.name});

  factory StudentChatUser.fromJson(Map<String, dynamic> json) =>
      _$StudentChatUserFromJson(json);

  Map<String, dynamic> toJson() => _$StudentChatUserToJson(this);
}