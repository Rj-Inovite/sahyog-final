import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rest_api_client.dart';

// 1. The "Automatic Postman" - This handles your Token and User ID
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve the token and ID you saved during login
    String? token = prefs.getString('auth_token');
    String? userId = prefs.getString('user_id');

    // Automatically attach Bearer Token to headers
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    // If your backend needs the User ID in a specific header, add it here
    if (userId != null) {
      options.headers["X-User-Id"] = userId;
    }

    options.headers["Accept"] = "application/json";
    options.headers["Content-Type"] = "application/json";

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the server says "Unauthorized" (401), you can trigger a logout here
    if (err.response?.statusCode == 401) {
      print("Token expired or invalid. Redirecting to login...");
    }
    return handler.next(err);
  }
}

// 2. The Main Service Engine
class ApiService {
  late RestAPIClient client;

  ApiService() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://devsahyog.myakola.com/api/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // ✅ ADDED: The AuthInterceptor (This is the most important part)
    dio.interceptors.add(AuthInterceptor());

    // Helpful for debugging - shows your API logs in the console
    dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true,
      requestHeader: true,
    ));

    client = RestAPIClient(dio);
  }
}

// Create a global instance so you can use it anywhere: apiService.client...
final apiService = ApiService();