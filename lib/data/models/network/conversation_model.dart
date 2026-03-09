// lib/data/models/network/conversation_model.dart

class ConversationResponse {
  final bool success;
  final String message;
  final int conversationId;
  final int creatorId;

  ConversationResponse({
    required this.success,
    required this.message,
    required this.conversationId,
    required this.creatorId,
  });

  // Factory to convert JSON from your Postman response into this object
  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      conversationId: json['conversation_id'] ?? 0,
      creatorId: json['creator_id'] ?? 0,
    );
  }
}