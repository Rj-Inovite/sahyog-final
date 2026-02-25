import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:my_app/data/models/login_response.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  @POST("/login")
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );
}