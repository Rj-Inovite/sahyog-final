import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Existing Model Imports
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';

// Ensure your ConversationResponse and any other models are defined in this file
import 'package:my_app/data/models/network/conversation_model.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  // ================= AUTH APIS =================

  @POST("auth/login")
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );

  @POST("logout")
  Future<void> logout();

  // ================= USER APIS =================

  @POST("update-password")
  Future<PasswordUpdateResponse> updatePassword(
    @Body() PasswordUpdateRequest request,
  );

  @GET("user/profile")
  Future<dynamic> getProfile();

  // ================= CHAT APIS =================

  /// 5. Setup Conversation
  /// Expected Body: {"receiver_id": int} or your specific setup keys
  @POST("chat/setup")
  Future<ConversationResponse> setupConversation(
    @Body() Map<String, dynamic> body,
  );

  /// 6. Send Message
  /// Expected Body: {"conversation_id": int, "message": "text"} 
  /// (Based on your Postman screenshot, the key is 'message')
  @POST("chat/send")
  Future<dynamic> sendWardenMessage(
    @Body() Map<String, dynamic> body,
  );

  /// 7. Fetch Chat History
  /// Retrieves messages for a specific conversation
  @GET("chat/messages/{conversation_id}")
  Future<dynamic> getChatHistory(
    @Path("conversation_id") int conversationId,
  );
}