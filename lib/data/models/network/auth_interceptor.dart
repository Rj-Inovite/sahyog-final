// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// --- STORAGE ---
import 'auth_local_storage.dart';

/// This Interceptor automatically adds the Bearer Token to every outgoing request.
/// It ensures the Web Panel and App stay synced by identifying the user via Token.
class AuthInterceptor extends Interceptor {
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Retrieve the token from Local Storage
    // Dio waits for this 'await' before moving to the next step.
    final String? token = await AuthLocalStorage.getToken();

    // 2. Standardize Headers for Laravel/PHP Backends
    // This ensures the server always communicates via JSON, even on errors.
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // 3. Inject Bearer Token if available
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      // debugPrint("--- AUTH: Token Injected for ${options.path} ---");
    } else {
      debugPrint("--- AUTH: No Token Found for ${options.path} ---");
    }

    // 4. Continue with the request
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful status codes for debugging high-frequency syncs
    if (response.statusCode == 200 || response.statusCode == 201) {
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
      
      // PRO TIP: You can use a global stream or event bus here to 
      // trigger the UI to pop back to the Login Screen.
    }

    // 6. Specific Logging for the 404 Errors you are seeing
    if (err.response?.statusCode == 404) {
      debugPrint("--- ROUTE ERROR: 404 Not Found at ${err.requestOptions.path} ---");
      debugPrint("Check if 'manager/warden-list' is correctly defined in api.php");
    }

    // 7. Handle Connection Issues
    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.receiveTimeout) {
      debugPrint("--- NETWORK ERROR: Timeout. Sahyog Server might be down or slow. ---");
    }

    // Continue passing the error so the ApiService can handle the UI state
    return handler.next(err);
  }
}