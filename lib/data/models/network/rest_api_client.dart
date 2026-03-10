import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Existing imports
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
// New model import
import 'package:my_app/data/models/network/conversation_model.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  /// 1. Login
  @POST("/auth/login")
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );

  /// 2. Logout
  @POST("/logout")
  Future<void> logout();

  /// 3. Update Password
  @POST("update-password")
  Future<PasswordUpdateResponse> updatePassword(
    @Body() PasswordUpdateRequest request,
  );

  /// 4. Profile API
  @GET("/user/profile")
  Future<dynamic> getProfile();

  // ================= CHAT APIS =================

  /// 5. Add Conversation (Chat Setup)
  /// Creates the room: pass {"name": "Room Name", "type": "group", "user_id": "ID"}
  @POST("/chat/setup")
  Future<ConversationResponse> setupConversation(
    @Body() Map<String, dynamic> body,
  );

  /// 6. Send Message (FIXED ENDPOINT)
  /// Updated from /chat/warden to /chat/send to resolve 404 error
  /// Body expects: {"conversation_id": int, "type": "text", "content": "message text"}
  @POST("/chat/send")
  Future<dynamic> sendWardenMessage(
    @Body() Map<String, dynamic> body,
  );

  /// 7. Fetch Chat Messages
  /// Retrieves history for a specific conversation ID
  @GET("/chat/messages/{conversation_id}")
  Future<dynamic> getChatHistory(
    @Path("conversation_id") int conversationId,
  );
}