// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// --- STORAGE ---
// Pulls the latest token from your centralized local storage
import 'package:my_app/data/models/network/auth_local_storage.dart'; 

/// This Interceptor automatically adds the Bearer Token to every outgoing request.
/// It ensures all modules (Warden, Parent, Student) stay authenticated.
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
      // Required for all Sahyog endpoints like 'guardian/leave/approve'
      options.headers['Accept'] = 'application/json';
      options.headers['Content-Type'] = 'application/json';

      // 3. Inject Bearer Token if available
      if (token != null && token.trim().isNotEmpty) {
        // Ensuring the format is exactly "Bearer <token>"
        options.headers['Authorization'] = 'Bearer ${token.trim()}';
        debugPrint("--- [API REQ]: ${options.method} ${options.path} (Token Injected) ---");
      } else {
        debugPrint("--- [API REQ]: ${options.method} ${options.path} (No Token Found) ---");
      }
    } catch (e) {
      debugPrint("--- AUTH_INTERCEPTOR_ERROR: $e ---");
    }

    // 4. Continue with the request
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Logging for successful API flows
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("--- [API SUCCESS]: ${response.requestOptions.path} ---");
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 5. Handle Token Expiry or Invalid Session (401 Unauthorized)
    // If the token is rejected, we must clear local data to prevent loop errors.
    if (err.response?.statusCode == 401) {
      debugPrint("--- [AUTH ERROR]: 401 Unauthorized at ${err.requestOptions.path} ---");
      
      // Clear local storage so the user is forced to log in again
      await AuthLocalStorage.clearAuthData();
      
      // OPTIONAL: If you have a global navigator key, you can navigate to login here:
      // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }

    // 6. Specific Logging for Route Errors (404)
    if (err.response?.statusCode == 404) {
      debugPrint("--- [ROUTE ERROR]: 404 Not Found at ${err.requestOptions.path} ---");
    }

    // 7. Handle Connection Issues (Timeouts/No Internet)
    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      debugPrint("--- [NETWORK ERROR]: Connection issue on ${err.requestOptions.path} ---");
    }

    // 8. Handle Specific Backend Errors (500)
    if (err.response?.statusCode == 500) {
      debugPrint("--- [SERVER ERROR]: 500 Internal Error at ${err.requestOptions.path} ---");
    }

    // Return the error so the UI (like a SnackBar) can handle it
    return handler.next(err);
  }
}