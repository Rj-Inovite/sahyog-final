import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Model imports - ensuring these match your project structure
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/leave_response.dart';
import 'package:my_app/data/models/network/conversation_model.dart';
import 'package:my_app/data/models/network/password_update_model.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  // ================= BIOMETRIC REGISTRATION APIS =================

  @GET("public/pending-enrollment")
  Future<dynamic> getPendingEnrollments();

  @POST("attendance-enrollment")
  Future<dynamic> submitEnrollment(@Body() Map<String, dynamic> body);

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
  
  @GET("leaves")
  Future<dynamic> getLeaves();

  @POST("leaves/apply")
  Future<LeaveResponse> applyLeave(@Body() Map<String, dynamic> body);

  @DELETE("leaves/{id}")
  Future<void> cancelLeave(@Path("id") int id);

  // ================= CHAT APIS (REFINED FOR TOKEN SYNC) =================
  
  /// This endpoint uses your Bearer Token to identify 'Ruchi' (ID 62).
  /// It creates or joins the "General Chat Room" for the web panel.
  @POST("chat/setup")
  Future<dynamic> setupConversation(@Body() Map<String, dynamic> body);

  /// Sends your message to the Web Panel using the Conversation ID.
  /// Body: {"conversation_id": X, "message": "..."}
  @POST("chat/send")
  Future<dynamic> sendWardenMessage(@Body() Map<String, dynamic> body);

  /// Fetches the message history for the specific room.
  /// Path: chat/messages/4 (as seen in your Postman)
  @GET("chat/messages/{id}")
  Future<dynamic> getChatHistory(@Path("id") int id);
}