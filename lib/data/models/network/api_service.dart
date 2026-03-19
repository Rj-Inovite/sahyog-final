// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/data/models/my_hostel_info_response.dart';

// --- MODELS ---
import 'package:my_app/data/models/warden_list_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:my_app/data/models/network/student_list_response.dart'; 
import 'package:my_app/data/models/network/my_room_response.dart'; 
// ADD THIS IMPORT (Ensure the path matches where you saved Step 1 from previous message)


// --- CLIENTS & STORAGE ---
import 'rest_api_client.dart';
import 'auth_local_storage.dart';

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

  /// Fetches the hostel info, including assigned managers for the student
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

  /// Fetches the list of students for the warden/manager
  Future<StudentListResponse?> getStudentList() async {
    try {
      final response = await _dio.get("manager/student-list");
      if (response.statusCode == 200 && response.data != null) {
        return StudentListResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching Student List: $e");
      return null;
    }
  }

  /// FIXED: WARDEN LIST API
  Future<WardenListResponse?> getWardenList() async {
    try {
      final response = await _dio.get("manager/warden-list"); 
      
      if (response.statusCode == 200 && response.data != null) {
        return WardenListResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching Warden List (trying manager/warden-list): $e");
      try {
        final retryResponse = await _dio.get("wardens");
        if (retryResponse.statusCode == 200 && retryResponse.data != null) {
          return WardenListResponse.fromJson(retryResponse.data);
        }
      } catch (_) {}
      return null;
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

  // ================= STUDENT PROFILE VIEW =================

  Future<dynamic> getStudentProfileView(int studentId) async {
    try {
      final response = await client.getStudentView(studentId);
      return response; 
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
      final payload = {
        "student_id": studentId,
        "face_vector": faceVector,
      };
      return await client.submitEnrollment(payload);
    } catch (e) {
      debugPrint("Enrollment Submission Error: $e");
      rethrow;
    }
  }

  // ================= PROFILE & AUTH APIS =================
  
  Future<dynamic> getProfile() => client.getProfile();

  Future<PasswordUpdateResponse> updatePassword(PasswordUpdateRequest request) {
    return client.updatePassword(request);
  }

  Future<void> logout() => client.logout();

  // ================= LEAVE APIS =================

  Future<List<dynamic>> getLeaves([int? userId]) async {
    try {
      final dynamic response = await client.getLeaves();
      if (response is Map && response.containsKey('data')) {
        return response['data'] as List<dynamic>;
      } else if (response is List) {
        return response;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return []; 
      rethrow;
    }
  }

  Future<dynamic> applyLeave({
    int? userId, 
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final payload = {
      "leave_type": leaveType,
      "start_date": startDate,
      "end_date": endDate,
      "reason": reason,
    };
    return await client.applyLeave(payload);
  }

  // ================= CHAT APIS =================

  Future<dynamic> setupChat() async {
    try {
      return await client.setupConversation({
        "name": "General Chat Room",
        "type": "group"
      });
    } catch (e) {
      debugPrint("Setup Chat Error: $e");
      return null;
    }
  }
  
  Future<dynamic> sendMessage(int conversationId, String message) async {
    try {
      final payload = {
        "conversation_id": conversationId,
        "message": message
      };
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
      if (e.response?.statusCode == 404) {
        return {"success": true, "messages": []};
      }
      rethrow;
    }
  }

  Future<dynamic> deleteMessage(int messageId) async {
    try {
      return await _dio.delete("chat/messages/$messageId");
    } catch (e) {
      debugPrint("Delete Error: $e");
      return null;
    }
  }

  Future<dynamic> editMessage(int messageId, String newText) async {
    try {
      return await _dio.put("chat/messages/$messageId", data: {"message": newText});
    } catch (e) {
      debugPrint("Edit Error: $e");
      return null;
    }
  }

  Future<dynamic> uploadChatFile(int conversationId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "conversation_id": conversationId,
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      return await _dio.post("chat/upload", data: formData);
    } catch (e) {
      debugPrint("File Upload Error: $e");
      return null;
    }
  }
}

final apiService = ApiService();