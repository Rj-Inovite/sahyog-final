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
  /// Creates the room: pass {"name": "Room Name", "type": "group/private"}
  @POST("/chat/setup")
  Future<ConversationResponse> setupConversation(
    @Body() Map<String, dynamic> body,
  );

  /// 6. Warden Chat API
  /// Sends actual messages to a specific conversation ID
  @POST("/chat/warden")
  Future<dynamic> sendWardenMessage(
    @Body() Map<String, dynamic> body,
  );
}