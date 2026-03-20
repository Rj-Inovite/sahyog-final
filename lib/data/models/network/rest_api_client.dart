import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// --- MODELS ---
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/leave_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:my_app/data/models/network/student_list_response.dart';
import 'package:my_app/data/models/warden_list_response.dart'; 

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  // ================= MANAGER / WARDEN APIS =================

  /// Fetches the list of students for the manager/warden
  @GET("manager/student-list")
  Future<StudentListResponse> getStudentList();

  /// Fetches the list of wardens/managers
  @GET("manager/warden-list")
  Future<WardenListResponse> getWardenList();

  /// Fetches detailed student view from Web Dashboard
  @GET("student/view/{id}")
  Future<dynamic> getStudentView(@Path("id") int id);

  // ================= BIOMETRIC REGISTRATION APIS =================

  @GET("public/pending-enrollment")
  Future<dynamic> getPendingEnrollments();

  /// Enrollment submission for face vectors
  @POST("attendance-enrollment")
  Future<dynamic> submitEnrollment(@Body() Map<String, dynamic> body);

  // ================= AUTH & PROFILE =================
  
  @POST("auth/login")
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST("logout")
  Future<void> logout();

  @GET("user/profile")
  Future<dynamic> getProfile();

  /// Updates Name, Mobile, and Address (Requires Auth Token)
  @PUT("user/update")
  Future<dynamic> updateProfile(@Body() Map<String, dynamic> body);

  /// Fetches specific student profile details for the Identity tab
  @GET("student/view/{id}")
  Future<dynamic> getStudentProfileView(@Path("id") int id);

  @POST("update-password")
  Future<PasswordUpdateResponse> updatePassword(@Body() PasswordUpdateRequest request);

  // ================= LEAVE APIS (STUDENT) =================
  
  @GET("leaves")
  Future<dynamic> getLeaves();

  /// Existing Student Apply Leave - DO NOT DISTURB
  @POST("leaves/apply")
  Future<LeaveResponse> applyLeave(@Body() Map<String, dynamic> body);

  @DELETE("leaves/{id}")
  Future<void> cancelLeave(@Path("id") int id);

  // ================= GUARDIAN / PARENT LEAVE APIS =================

  /// ✅ NEW: Approves a student's leave request by the guardian
  /// Endpoint: https://devsahyog.myakola.com/api/guardian/leave/approve
  /// Payload: {"student_id": int, "leave_id": int}
  @POST("guardian/leave/approve")
  Future<dynamic> approveLeaveByParent(@Body() Map<String, dynamic> body);

  // ================= CHAT APIS =================
  
  @POST("chat/setup")
  Future<dynamic> setupConversation(@Body() Map<String, dynamic> body);

  @POST("chat/send")
  Future<dynamic> sendWardenMessage(@Body() Map<String, dynamic> body);

  @GET("chat/messages/{id}")
  Future<dynamic> getChatHistory(@Path("id") int id);
}