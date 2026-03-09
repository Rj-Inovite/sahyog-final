import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Ensure these paths match your lib/data/models/ structure
import 'package:my_app/data/models/login_response.dart';
import 'package:my_app/data/models/network/password_update_model.dart';

part 'rest_api_client.g.dart';

@RestApi(baseUrl: "https://devsahyog.myakola.com/api/")
abstract class RestAPIClient {
  factory RestAPIClient(Dio dio, {String? baseUrl}) = _RestAPIClient;

  /// Role-based authentication using single login field
  @POST("/auth/login")
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );

  @POST("/logout")
  Future<void> logout(
    @Header("Authorization") String token,
  );
@POST("update-password") // ✅ Ensure this matches your server's route
Future<PasswordUpdateResponse> updatePassword(
  @Header("Authorization") String token,
  @Body() PasswordUpdateRequest request,
);}