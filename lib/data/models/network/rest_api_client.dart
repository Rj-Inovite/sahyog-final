// ignore_for_file: unused_import
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// --- MODELS ---
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/leave_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:my_app/data/models/network/student_list_response.dart';
import 'package:my_app/data/models/warden_list_response.dart'; 
// Ensure these match your actual file paths for the Parent Portal models
import 'package:my_app/data/models/child_profile_response.dart'; 
import 'package:my_app/data/models/network/parent_leave_list.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  // ================= MANAGER / WARDEN APIS =================

  @GET("manager/student-list")
  Future<StudentListResponse> getStudentList();

  @GET("manager/warden-list")
  Future<WardenListResponse> getWardenList();

  @GET("student/view/{id}")
  Future<dynamic> getStudentView(@Path("id") int id);

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

  @PUT("user/update")
  Future<dynamic> updateProfile(@Body() Map<String, dynamic> body);

  @GET("student/view/{id}")
  Future<dynamic> getStudentProfileView(@Path("id") int id);

  @POST("update-password")
  Future<PasswordUpdateResponse> updatePassword(@Body() PasswordUpdateRequest request);

  // ================= STUDENT LEAVE APIS =================
  
  @GET("leaves")
  Future<dynamic> getLeaves();

  @POST("leaves/apply")
  Future<LeaveResponse> applyLeave(@Body() Map<String, dynamic> body);

  @DELETE("leaves/{id}")
  Future<void> cancelLeave(@Path("id") int id);

  // ================= GUARDIAN / PARENT PORTAL APIS (NEW) =================

  /// Fetches the linked child's profile for the Parent Portal
  @GET("parent/child-profile")
  Future<ChildProfileResponse?> getChildProfile();

  /// Fetches the leave history specifically for the Parent/Guardian view
  @GET("parent/leave-history")
  Future<ParentLeaveResponse?> getParentLeaveHistory();

  /// ✅ Parent Leave Approval
  /// Payload: {"student_id": int, "leave_id": int}
  @POST("guardian/leave/approve")
  Future<dynamic> approveLeaveByParent(@Body() Map<String, dynamic> body);

  /// ✅ Parent Leave Rejection
  /// Payload: {"leave_id": int}
  @POST("guardian/leave/reject")
  Future<dynamic> rejectLeaveByParent(@Body() Map<String, dynamic> body);

  // ================= CHAT APIS =================
  
  @POST("chat/setup")
  Future<dynamic> setupConversation(@Body() Map<String, dynamic> body);

  @POST("chat/send")
  Future<dynamic> sendWardenMessage(@Body() Map<String, dynamic> body);

  @GET("chat/messages/{id}")
  Future<dynamic> getChatHistory(@Path("id") int id);
}