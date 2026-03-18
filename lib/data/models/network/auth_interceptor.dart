import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    // This is asynchronous, but Dio waits for this before sending the request.
    final String? token = await AuthLocalStorage.getToken();

    // 2. If token exists, inject it into the Authorization header
    // Use the standard 'Bearer ' prefix required by Laravel/Passport/Sanctum.
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint("--- AUTH: Token Injected for ${options.path} ---");
    } else {
      debugPrint("--- AUTH: No Token Found for ${options.path} ---");
    }

    // 3. Set standard headers for Web/Server compatibility
    // 'Accept: application/json' tells the server to return JSON even on errors (e.g., 422 validation).
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // 4. Continue with the request
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Optional: Log successful status codes for debugging high-frequency syncs
    if (response.statusCode == 200) {
      debugPrint("--- API SUCCESS: [${response.requestOptions.path}] ---");
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 5. Handle Token Expiry or Invalid Session (401 Unauthorized)
    if (err.response?.statusCode == 401) {
      debugPrint("--- AUTH ERROR: 401 Unauthorized. Clearing Session... ---");
      
      // Clear local storage so the app doesn't try to use the bad token again
      AuthLocalStorage.clearAuthData();
      
      // Note: In a real app, you might use a Global Navigator Key 
      // to push the user back to the Login Screen here.
    }

    // 6. Handle Server Errors (500) or Connection Issues
    if (err.type == DioExceptionType.connectionTimeout) {
      debugPrint("--- NETWORK ERROR: Connection Timeout. Check Sahyog Server. ---");
    }

    // Continue passing the error so the UI (ApiService) can catch it
    return handler.next(err);
  }
}