import 'package:dio/dio.dart';
import '../rest_api_client.dart';

class ApiService {
  late RestAPIClient client;

  ApiService() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "application/json",
        },
      ),
    );

    client = RestAPIClient(dio);
  }
}