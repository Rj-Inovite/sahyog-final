// ignore_for_file: unused_import
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// --- MODELS ---
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/leave_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:my_app/data/models/network/student_list_response.dart';
import 'package:my_app/data/models/warden_list_response.dart'; 
import 'package:my_app/data/models/child_profile_response.dart'; 
import 'package:my_app/data/models/network/parent_leave_list.dart';
import 'package:my_app/data/models/network/attendance_response.dart';
// ✅ Corrected import for your new chat response model
import 'package:my_app/data/models/network/chat_response.dart'; 

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

  @GET("hostel/attendance")
  Future<AttendanceResponse> getAttendance();

  /// ✅ Integrated Warden Leave Actions
  @POST("warden/leave/approve")
  Future<dynamic> wardenApproveLeave(@Body() Map<String, dynamic> body);

  @POST("warden/leave/{id}/reject")
  Future<dynamic> wardenRejectLeave(@Path("id") int id);

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

  // ================= GUARDIAN / PARENT PORTAL APIS =================

  @GET("parent/child-profile")
  Future<ChildProfileResponse?> getChildProfile();

  @GET("parent/leave-history")
  Future<ParentLeaveResponse?> getParentLeaveHistory();

  @POST("guardian/leave/approve")
  Future<dynamic> approveLeaveByParent(@Body() Map<String, dynamic> body);

  @POST("guardian/leave/reject")
  Future<dynamic> rejectLeaveByParent(@Body() Map<String, dynamic> body);

  // ================= CHAT APIS =================
  
  @POST("chat/setup")
  Future<dynamic> setupConversation(@Body() Map<String, dynamic> body);

  /// ✅ Warden Chat Send API
  /// Uses the new ChatResponse model for proper typed data handling
  @POST("chat/send")
  Future<ChatResponse> sendWardenMessage(@Body() Map<String, dynamic> body);

  @GET("chat/messages/{id}")
  Future<dynamic> getChatHistory(@Path("id") int id);
}