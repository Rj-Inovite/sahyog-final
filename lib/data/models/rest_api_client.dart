import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:my_app/data/models/login_response.dart';

part 'rest_api_client.g.dart';   // ✅ THIS LINE MUST EXIST

@RestApi(baseUrl: "https://devsahyog.myakola.com/api")
abstract class RestAPIClient {

  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  @POST("/auth/login")
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );

  @POST("/logout")
  Future<void> logout(
    @Header("Authorization") String token,
  );
}