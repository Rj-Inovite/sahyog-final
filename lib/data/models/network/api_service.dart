import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rest_api_client.dart';

// --- 1. THE AUTH INTERCEPTOR (Handles Tokens Automatically) ---
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve the token saved during login
    String? token = prefs.getString('auth_token');

    // Automatically attach Bearer Token to headers
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    options.headers["Accept"] = "application/json";
    options.headers["Content-Type"] = "application/json";

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Logic for force logout can go here if token expires
      print("Unauthorized: Token might be expired.");
    }
    return handler.next(err);
  }
}

// --- 2. THE MAIN SERVICE ENGINE ---
class ApiService {
  late RestAPIClient client;
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://devsahyog.myakola.com/api/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Attach the Interceptor so we don't have to pass tokens manually
    _dio.interceptors.add(AuthInterceptor());

    // Logging for debugging (helps you see the JSON in console)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true,
      requestHeader: true,
    ));

    client = RestAPIClient(_dio);
  }

  // --- CHAT INTEGRATION METHODS ---
  Future<Response> setupChat(int studentId) async {
    try {
      return await _dio.post("chat/setup", data: {
        "receiver_id": studentId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendMessage(int convoId, String message) async {
    try {
      return await _dio.post("chat/send", data: {
        "conversation_id": convoId,
        "message": message,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getChatMessages(int convoId) async {
    try {
      return await _dio.get("chat/messages/$convoId");
    } catch (e) {
      rethrow;
    }
  }

  // --- STUDENT LEAVE INTEGRATION METHODS ---
  /// Apply for a leave
  Future<Response> applyLeave({
    required int userId,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      return await _dio.post("leaves/apply", data: {
        "user_id": userId,
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all leaves for a student (sync with web)
  Future<Response> getLeaves(int userId) async {
    try {
      return await _dio.get("leaves/$userId");
    } catch (e) {
      rethrow;
    }
  }

  /// Optional: Cancel or update a leave if API supports it
  Future<Response> cancelLeave(int leaveId) async {
    try {
      return await _dio.delete("leaves/$leaveId");
    } catch (e) {
      rethrow;
    }
  }
}

// Global instance to use as: apiService.applyLeave(...)
final apiService = ApiService();
