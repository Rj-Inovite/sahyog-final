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

    // Logging for debugging (helps you see the chat JSON in console)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true,
      requestHeader: true,
    ));

    client = RestAPIClient(_dio);
  }

  // --- CHAT INTEGRATION METHODS ---

  /// 1. Initialize Conversation (Used by Warden to start a chat)
  /// [studentId] is the ID of the student the warden wants to message
  Future<Response> setupChat(int studentId) async {
    try {
      return await _dio.post("chat/setup", data: {
        "receiver_id": studentId,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 2. Send Message
  /// [convoId] comes from the setupChat response
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

  /// 3. Fetch Messages (The "Sync" logic)
  /// Call this on a Timer to see messages from Web dashboard
  Future<Response> getChatMessages(int convoId) async {
    try {
      return await _dio.get("chat/messages/$convoId");
    } catch (e) {
      rethrow;
    }
  }
}

// Global instance to use as: apiService.setupChat(id)
final apiService = ApiService();