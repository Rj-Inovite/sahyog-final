// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dio/dio.dart';
import 'rest_api_client.dart';
import 'auth_local_storage.dart';
import 'package:my_app/data/models/network/password_update_model.dart';
import 'package:flutter/material.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await AuthLocalStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }
}

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

  // ================= STUDENT PROFILE VIEW (NEW) =================

  /// Fetches detailed student data from the web dashboard
  /// Endpoint: GET student/view/{id}
  Future<dynamic> getStudentProfileView(int studentId) async {
    try {
      // We call the client method we defined in Step 1
      final response = await client.getStudentView(studentId);
      return response; 
    } catch (e) {
      debugPrint("Error fetching Student View: $e");
      rethrow;
    }
  }

  // ================= BIOMETRIC / REGISTRATION APIS =================

  Future<List<dynamic>> getPendingEnrollments() async {
    try {
      final response = await _dio.get("public/pending-enrollment");
      if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'] as List<dynamic>;
      } else if (response.data is List) {
        return response.data;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching pending enrollments: $e");
      return [];
    }
  }

  Future<dynamic> submitEnrollment(int studentId, List<double> faceVector) async {
    final payload = {
      "student_id": studentId,
      "face_vector": faceVector,
    };
    return await client.submitEnrollment(payload);
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

  // ================= CHAT APIS (WHATSAPP FEATURES) =================

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