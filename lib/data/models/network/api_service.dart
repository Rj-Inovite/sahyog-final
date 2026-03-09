import 'package:dio/dio.dart';
// ✅ FIXED: Removed the non-existent rest_api.dart import
// ✅ FIXED: Using the correct path for your RestAPIClient
import 'rest_api_client.dart';

class ApiService {
  late RestAPIClient client;

  ApiService() {
    final dio = Dio(
      BaseOptions(
        // Connecting to your Sahyog backend
        baseUrl: "https://devsahyog.myakola.com/api/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    // Adding a logger is helpful for debugging your Sahyog API calls
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Initialize the Retrofit client with the configured Dio instance
    client = RestAPIClient(dio);
  }
}
