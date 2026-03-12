import 'package:dio/dio.dart';
import 'rest_api_client.dart';
import 'auth_local_storage.dart';
import 'package:my_app/data/models/network/password_update_model.dart';

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
      requestHeader: true
    ));

    client = RestAPIClient(_dio);
  }

  // ================= PROFILE & AUTH APIS (DO NOT REMOVE) =================
  
  Future<dynamic> getProfile() => client.getProfile();

  Future<PasswordUpdateResponse> updatePassword(PasswordUpdateRequest request) {
    return client.updatePassword(request);
  }

  Future<void> logout() => client.logout();

  // ================= LEAVE APIS =================

  Future<List<dynamic>> getLeaves([int? userId]) async {
    try {
      // We use 'dynamic' because the response is a Map: {"message": "...", "data": []}
      final dynamic response = await client.getLeaves();
      
      // Extract the 'data' list from the response object
      if (response is Map && response.containsKey('data')) {
        return response['data'] as List<dynamic>;
      } else if (response is List) {
        return response;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print("Warning: The leaves endpoint was not found on the server.");
        return []; 
      }
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

  Future<dynamic> setupChat(int id) => client.setupConversation({"receiver_id": id});
  
  Future<dynamic> sendMessage(int cId, String msg) => 
      client.sendWardenMessage({"conversation_id": cId, "message": msg});
      
  Future<dynamic> getChatMessages(int cId) => client.getChatHistory(cId);
}

final apiService = ApiService();