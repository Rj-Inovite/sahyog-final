import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // Optional: for debugging
import '../rest_api_client.dart';

class ApiService {
  late RestAPIClient client;

  ApiService() {
    final dio = Dio(
      BaseOptions(
        // 1. MUST point to your server's API root
        baseUrl: "https://devsahyog.myakola.com/api/", 
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json", // 2. Critical for POST requests
        },
      ),
    );

    // 3. DEBUGGING TOOL
    // This will show you exactly what is sent to the server in your console
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    client = RestAPIClient(dio);
  }
}