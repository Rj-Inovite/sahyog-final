// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// --- STORAGE ---
// Ensures the interceptor can pull the latest token from your local storage
import 'package:my_app/data/models/network/auth_local_storage.dart'; 

/// This Interceptor automatically adds the Bearer Token to every outgoing request.
/// It ensures the Web Panel and App stay synced by identifying the user via Token.
class AuthInterceptor extends Interceptor {
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 1. Retrieve the token from Local Storage
      final String? token = await AuthLocalStorage.getToken();

      // 2. Standardize Headers for Laravel/PHP Backends
      // Essential for 'guardian/leave/approve', 'warden', and 'parent/ward/leave-history'
      options.headers['Accept'] = 'application/json';
      options.headers['Content-Type'] = 'application/json';

      // 3. Inject Bearer Token if available
      if (token != null && token.isNotEmpty) {
        // Ensuring the format is exactly "Bearer <token>"
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint("--- AUTH: Token injected for ${options.path} ---");
      } else {
        debugPrint("--- AUTH: No Token Found for ${options.path} ---");
      }
    } catch (e) {
      debugPrint("--- AUTH_INTERCEPTOR_ERROR: $e ---");
    }

    // 4. Continue with the request
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Standard successful logging for debugging API flows
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("--- API SUCCESS: [${response.requestOptions.path}] ---");
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 5. Handle Token Expiry or Invalid Session (401 Unauthorized)
    // If the token is rejected by the Sahyog server, we must clear local data.
    if (err.response?.statusCode == 401) {
      debugPrint("--- AUTH ERROR: 401 Unauthorized for ${err.requestOptions.path} ---");
      
      // Clear local storage so the app doesn't attempt to use an invalid session
      AuthLocalStorage.clearAuthData();
      
      // Optional: Add logic here to redirect the user to the Login Screen
    }

    // 6. Specific Logging for Route Errors (404)
    if (err.response?.statusCode == 404) {
      debugPrint("--- ROUTE ERROR: 404 Not Found at ${err.requestOptions.path} ---");
    }

    // 7. Handle Connection Issues (Timeouts)
    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      debugPrint("--- NETWORK ERROR: Connection issue on ${err.requestOptions.path}. ---");
    }

    // 8. Handle Specific Backend Errors (500)
    if (err.response?.statusCode == 500) {
      debugPrint("--- SERVER ERROR: 500 Internal Server Error at ${err.requestOptions.path} ---");
    }

    // Return the error to the calling Service so it can show a SnackBar or Error UI
    return handler.next(err);
  }
}