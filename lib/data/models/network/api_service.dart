// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// --- MODELS ---
import 'package:my_app/data/models/child_profile_response.dart';
import 'package:my_app/data/models/my_hostel_info_response.dart';
import 'package:my_app/data/models/network/auth_local_storage.dart';
import 'package:my_app/data/models/warden_list_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:my_app/data/models/network/student_list_response.dart'; 
import 'package:my_app/data/models/network/my_room_response.dart'; 
import 'package:my_app/data/models/network/leave_response.dart';

// --- CLIENTS & STORAGE ---
import 'rest_api_client.dart';

/// --- AUTH INTERCEPTOR ---
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await AuthLocalStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint("AuthInterceptor Error: $e");
    }
    
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      debugPrint("Session Expired: Redirecting to Login might be needed.");
    }
    return handler.next(err);
  }
}

/// --- MAIN API SERVICE ---
class ApiService {
  late final RestAPIClient client;
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: "https://devsahyog.myakola.com/api/",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ));

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true, 
      requestHeader: true,
      error: true,
    ));

    client = RestAPIClient(_dio);
  }

  // ================= STUDENT HOSTEL INFO API =================

  Future<MyHostelInfoResponse?> getMyHostelInfo() async {
    try {
      final response = await _dio.get("my-hostel-info");
      if (response.statusCode == 200 && response.data != null) {
        return MyHostelInfoResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching My Hostel Info: $e");
      return null;
    }
  }

  // ================= MANAGER / WARDEN APIS =================

  Future<StudentListResponse?> getStudentList() async {
    try {
      final response = await _dio.get("manager/student-list");
      if (response.statusCode == 200 && response.data != null) {
        return StudentListResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError("Student List", e);
      return null;
    }
  }

  Future<WardenListResponse?> getWardenList() async {
    try {
      final response = await _dio.get("warden/profile"); 
      if (response.statusCode == 200 && response.data != null) {
        return WardenListResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError("Warden List", e);
      return null;
    }
  }

  Future<dynamic> getWardenLeaves() async {
    try {
      final response = await _dio.get("warden/leaves");
      if (response.statusCode == 200 && response.data != null) {
        return response.data; 
      }
      return [];
    } catch (e) {
      return getWardenPendingLeaves();
    }
  }

  Future<List<dynamic>> getWardenPendingLeaves() async {
    try {
      final response = await _dio.get("warden/leaves/pending");
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data'] as List<dynamic>;
        }
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint("Warden Pending Leaves Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> wardenApproveLeave({
    required int studentId,
    required int leaveId,
    required bool isApprove,
  }) async {
    try {
      final String endpoint = isApprove ? "warden/leave/approve" : "warden/leave/$leaveId/reject";
      final response = await _dio.post(
        endpoint,
        data: isApprove ? {"student_id": studentId, "leave_id": leaveId} : null,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {"success": true, "message": "Action completed"};
    } on DioException catch (e) {
      _handleDioError("Warden Leave Action", e);
      return {"success": false, "message": e.message};
    }
  }

  // ================= ATTENDANCE APIS =================

  /// ✅ Integrated: hostel/attendance
  Future<AttendanceResponse?> getHostelAttendance() async {
    try {
      final response = await _dio.get("hostel/attendance");
      if (response.statusCode == 200 && response.data != null) {
        return AttendanceResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError("Hostel Attendance", e);
      return null;
    }
  }

  // ================= PARENT / GUARDIAN APIS =================

  Future<ChildProfileResponse?> getChildProfile() async {
    try {
      final response = await _dio.get("parent/child-profile");
      if (response.statusCode == 200 && response.data != null) {
        return ChildProfileResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError("Child Profile", e);
      return null;
    }
  }

  Future<List<dynamic>> getLeaves([int? userId]) async {
    List<String> endpoints = ["guardian/leaves/pending", "guardian/leaves", "parent/leaves", "leaves"];
    for (String path in endpoints) {
      try {
        final response = await _dio.get(path);
        if (response.statusCode == 200 && response.data != null) {
          if (response.data is Map && response.data.containsKey('data')) {
            return response.data['data'] as List<dynamic>;
          } else if (response.data is List) {
            return response.data;
          }
        }
      } catch (e) { continue; }
    }
    return [];
  }

  Future<dynamic> parentApproveLeave({required int studentId, required int leaveId}) async {
    try {
      final response = await _dio.post(
        "guardian/leave/approve", 
        data: {"student_id": studentId, "leave_id": leaveId},
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError("Parent Leave Approval", e);
      rethrow;
    }
  }

  Future<dynamic> parentRejectLeave(int leaveId) async {
    try {
      final response = await _dio.post("guardian/leave/$leaveId/reject");
      return response.data;
    } on DioException catch (e) {
      _handleDioError("Parent Leave Rejection", e);
      rethrow;
    }
  }

  // ================= STUDENT ROOM & DASHBOARD =================

  Future<MyRoomResponse?> getMyRoomDetails() async {
    try {
      final response = await _dio.get("my-room");
      if (response.data != null && response.data is Map<String, dynamic>) {
        return MyRoomResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching My Room Details: $e");
      return null;
    }
  }

  Future<dynamic> getStudentProfileView(int studentId) async {
    try {
      return await client.getStudentView(studentId);
    } catch (e) {
      debugPrint("Error fetching Student View: $e");
      rethrow;
    }
  }

  // ================= BIOMETRIC / REGISTRATION APIS =================

  Future<Map<String, dynamic>> getPendingEnrollments() async {
    try {
      final response = await _dio.get("public/pending-enrollment");
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {"success": false, "data": []};
    } catch (e) {
      debugPrint("Error fetching pending enrollments: $e");
      return {"success": false, "data": [], "error": e.toString()};
    }
  }

  Future<dynamic> submitEnrollment(int studentId, List<double> faceVector) async {
    try {
      final payload = {"student_id": studentId, "face_vector": faceVector};
      return await client.submitEnrollment(payload);
    } catch (e) {
      debugPrint("Enrollment Submission Error: $e");
      rethrow;
    }
  }

  // ================= PROFILE & AUTH APIS =================
  
  Future<dynamic> getProfile() => client.getProfile();
  Future<PasswordUpdateResponse> updatePassword(PasswordUpdateRequest request) => client.updatePassword(request);
  Future<void> logout() => client.logout();

  Future<dynamic> applyLeave({
    int? userId, 
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      final payload = {
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
        if (userId != null) "user_id": userId,
      };
      final response = await _dio.post("leaves/apply", data: payload);
      return response.data;
    } on DioException catch (e) {
      _handleDioError("Apply Leave", e);
      rethrow;
    }
  }

  // ================= CHAT APIS =================

  Future<dynamic> setupChat() async {
    try {
      return await client.setupConversation({"name": "General Chat Room", "type": "group"});
    } catch (e) {
      debugPrint("Setup Chat Error: $e");
      return null;
    }
  }
  
  Future<dynamic> sendMessage(int conversationId, String message) async {
    try {
      final payload = {"conversation_id": conversationId, "message": message};
      return await client.sendWardenMessage(payload);
    } catch (e) {
      debugPrint("Send Message Error: $e");
      rethrow;
    }
  }
      
  Future<dynamic> getChatMessages(int conversationId) async {
    try {
      return await client.getChatHistory(conversationId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return {"success": true, "messages": []};
      rethrow;
    }
  }

  Future<dynamic> deleteMessage(int messageId) async {
    try {
      return await _dio.delete("chat/messages/$messageId");
    } catch (e) { return null; }
  }

  Future<dynamic> editMessage(int messageId, String newText) async {
    try {
      return await _dio.put("chat/messages/$messageId", data: {"message": newText});
    } catch (e) { return null; }
  }

  Future<dynamic> uploadChatFile(int conversationId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "conversation_id": conversationId,
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      return await _dio.post("chat/upload", data: formData);
    } catch (e) { return null; }
  }

  // ================= UTILITIES & SHARED =================

  void _handleDioError(String apiName, DioException e) {
    if (e.response?.statusCode == 404) {
      debugPrint("Sahyog API 404: $apiName endpoint not found at ${e.requestOptions.path}");
    } else if (e.response?.statusCode == 401) {
      debugPrint("Sahyog API 401: Unauthorized access to $apiName");
    } else if (e.response?.statusCode == 500) {
      debugPrint("Sahyog API 500: Server crashed during $apiName call.");
    } else {
      debugPrint("Dio Error ($apiName): ${e.message} | Code: ${e.response?.statusCode}");
    }
  }
}

// --- ATTENDANCE MODELS ---

class AttendanceResponse {
  final bool success;
  final int? hostelId;
  final AttendanceSummary? summary;
  final List<AttendanceData> data;

  AttendanceResponse({required this.success, this.hostelId, this.summary, required this.data});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      hostelId: json['hostel_id'],
      summary: json['summary'] != null ? AttendanceSummary.fromJson(json['summary']) : null,
      data: (json['data'] as List? ?? []).map((e) => AttendanceData.fromJson(e)).toList(),
    );
  }
}

class AttendanceSummary {
  final int totalRecords;
  final int present;
  final int absent;

  AttendanceSummary({required this.totalRecords, required this.present, required this.absent});

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalRecords: json['total_records'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }
}

class AttendanceData {
  final int id;
  final String status;
  final String firstName;
  final String lastName;
  final String studentCode;

  AttendanceData({required this.id, required this.status, required this.firstName, required this.lastName, required this.studentCode});

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'absent',
      firstName: json['student_first_name'] ?? '',
      lastName: json['student_last_name'] ?? '',
      studentCode: json['student_code'] ?? '',
    );
  }
}

final apiService = ApiService();