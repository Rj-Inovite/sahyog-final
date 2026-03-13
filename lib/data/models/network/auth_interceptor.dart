import 'package:dio/dio.dart';
import 'auth_local_storage.dart';

/// This Interceptor automatically adds the Bearer Token to every outgoing request.
/// It ensures the Web Panel and App stay synced by identifying the user via Token.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Retrieve the token from your Local Storage
    final String? token = await AuthLocalStorage.getToken();

    // 2. If token exists, inject it into the Authorization header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Set standard headers for Laravel/Web compatibility
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // 4. Continue with the request
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 5. Handle Token Expiry (401 Unauthorized)
    if (err.response?.statusCode == 401) {
      // Logic to clear local storage and redirect to login could go here
      AuthLocalStorage.clearAuthData();
      print("Token expired or invalid. User logged out.");
    }
    return handler.next(err);
  }
}