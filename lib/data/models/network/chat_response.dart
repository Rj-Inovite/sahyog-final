import 'package:json_annotation/json_annotation.dart';

part 'chat_response.g.dart';

@JsonSerializable()
class ChatResponse {
  final bool? success;
  final String? message;
  @JsonKey(name: 'chat_details')
  final ChatDetails? chatDetails;

  ChatResponse({this.success, this.message, this.chatDetails});

  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}

@JsonSerializable()
class ChatDetails {
  @JsonKey(name: 'conversation_id')
  final int? conversationId;
  @JsonKey(name: 'message_id')
  final int? messageId;
  final String? content;
  final ChatUser? from;
  final ChatUser? to;

  ChatDetails({this.conversationId, this.messageId, this.content, this.from, this.to});

  factory ChatDetails.fromJson(Map<String, dynamic> json) => _$ChatDetailsFromJson(json);
}

@JsonSerializable()
class ChatUser {
  final int? id;
  final String? name;

  ChatUser({this.id, this.name});

  factory ChatUser.fromJson(Map<String, dynamic> json) => _$ChatUserFromJson(json);
}