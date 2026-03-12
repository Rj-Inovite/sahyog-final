import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/leave_response.dart';
import 'package:my_app/data/models/network/conversation_model.dart';
import 'package:my_app/data/models/network/password_update_model.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  // ================= AUTH & PROFILE =================
  @POST("auth/login")
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST("logout")
  Future<void> logout();

  @GET("user/profile")
  Future<dynamic> getProfile();

  @POST("update-password")
  Future<PasswordUpdateResponse> updatePassword(@Body() PasswordUpdateRequest request);

  // ================= LEAVE APIS =================
  
  // Note: Ensure this matches your Postman GET request path (e.g., "leaves" or "leaves/list")
  @GET("leaves")
  Future<dynamic> getLeaves();

  // FIX: Added "/apply" to match your Postman screenshot successfully
  @POST("leaves/apply")
  Future<LeaveResponse> applyLeave(@Body() Map<String, dynamic> body);

  @DELETE("leaves/{id}")
  Future<void> cancelLeave(@Path("id") int id);

  // ================= CHAT APIS =================
  @POST("chat/setup")
  Future<ConversationResponse> setupConversation(@Body() Map<String, dynamic> body);

  @POST("chat/send")
  Future<dynamic> sendWardenMessage(@Body() Map<String, dynamic> body);

  @GET("chat/messages/{id}")
  Future<dynamic> getChatHistory(@Path("id") int id);
}