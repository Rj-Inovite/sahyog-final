import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Model imports - ensure these paths match your project exactly
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/leave_response.dart';
import 'package:my_app/data/models/network/conversation_model.dart';
import 'package:my_app/data/models/network/password_update_model.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  // ================= BIOMETRIC REGISTRATION APIS =================

  /// Fetches students awaiting enrollment from the public endpoint
  @GET("public/pending-enrollment")
  Future<dynamic> getPendingEnrollments();

  /// Submits the 192-dimension face vector to the server
  /// Body: {"student_id": int, "face_vector": List<double>}
  @POST("attendance-enrollment")
  Future<dynamic> submitEnrollment(@Body() Map<String, dynamic> body);

  // ================= AUTH & PROFILE =================
  
  @POST("auth/login")
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST("logout")
  Future<void> logout();

  @GET("user/profile")
  Future<dynamic> getProfile();

  // ✅ ADDED: Fetch detailed student view from Web Dashboard
  @GET("student/view/{id}")
  Future<dynamic> getStudentView(@Path("id") int id);

  @POST("update-password")
  Future<PasswordUpdateResponse> updatePassword(@Body() PasswordUpdateRequest request);

  // ================= LEAVE APIS =================
  
  @GET("leaves")
  Future<dynamic> getLeaves();

  @POST("leaves/apply")
  Future<LeaveResponse> applyLeave(@Body() Map<String, dynamic> body);

  @DELETE("leaves/{id}")
  Future<void> cancelLeave(@Path("id") int id);

  // ================= CHAT APIS =================
  
  /// Setup/Join a conversation room
  @POST("chat/setup")
  Future<dynamic> setupConversation(@Body() Map<String, dynamic> body);

  /// Sends a message to a conversation
  @POST("chat/send")
  Future<dynamic> sendWardenMessage(@Body() Map<String, dynamic> body);

  /// Fetches history for a specific conversation ID
  @GET("chat/messages/{id}")
  Future<dynamic> getChatHistory(@Path("id") int id);
}