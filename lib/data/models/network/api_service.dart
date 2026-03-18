// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// --- MODELS ---
import 'package:my_app/data/models/warden_list_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:my_app/data/models/network/student_list_response.dart'; 
// ADD THIS IMPORT:
import 'package:my_app/data/models/network/my_room_response.dart'; 

// --- CLIENTS & STORAGE ---
import 'rest_api_client.dart';
import 'auth_local_storage.dart';

/// --- AUTH INTERCEPTOR ---
/// Automatically attaches the Bearer token to every request
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
    
    // Standard Sahyog API Headers
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

    // Adding Interceptors for Auth and Logging
    _dio.interceptors.add(AuthInterceptor());
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true, 
      requestHeader: true,
      error: true,
    ));

    client = RestAPIClient(_dio);
  }

  // ================= MANAGER / WARDEN APIS =================

  /// Fetches the list of students for the warden/manager
  Future<StudentListResponse?> getStudentList() async {
    try {
      final response = await client.getStudentList();
      return response;
    } catch (e) {
      debugPrint("Error fetching Student List from Client: $e");
      return null;
    }
  }

  /// NEW: WARDEN LIST API (Staff Management)
  Future<WardenListResponse?> getWardenList() async {
    try {
      final response = await _dio.get("wardens");
      if (response.data != null && response.data is Map<String, dynamic>) {
        return WardenListResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching Warden List: $e");
      return null;
    }
  }

  // ================= STUDENT ROOM & DASHBOARD =================

  /// NEW: Fetches the room allotment details for the logged-in student.
  /// Used in student.dart to show room details or "No Room Assigned" message.
  Future<MyRoomResponse?> getMyRoomDetails() async {
    try {
      // Direct call to my-room endpoint. AuthInterceptor handles the token.
      final response = await _dio.get("my-room");
      
      if (response.data != null && response.data is Map<String, dynamic>) {
        return MyRoomResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching My Room Details: $e");
      // We return null so the UI can handle the error state gracefully
      return null;
    }
  }

  // ================= STUDENT PROFILE VIEW =================

  /// Fetches detailed student data from the web dashboard
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

  /// Fetches students who are pending face enrollment
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

  /// Submits the generated Face Vector to the Sahyog server
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

  // ================= CHAT APIS (ELABORATED) =================

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

// Global instance to be used across the app
final apiService = ApiService();