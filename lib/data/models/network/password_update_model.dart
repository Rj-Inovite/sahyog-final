import 'package:json_annotation/json_annotation.dart';

// ✅ Ensure this matches your filename exactly
part 'password_update_model.g.dart';

@JsonSerializable()
class PasswordUpdateRequest {
  @JsonKey(name: "user_id")
  final String userId;
  
  @JsonKey(name: "old_password")
  final String oldPassword;
  
  // This is the new password
  final String password;
  
  // ✅ CRITICAL: Laravel's 'confirmed' validation rule REQUIRES this exact key name 
  // to sync successfully with the web dashboard.
  @JsonKey(name: "password_confirmation")
  final String passwordConfirmation;

  PasswordUpdateRequest({
    required this.userId,
    required this.oldPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  // Factory methods for JSON serialization
  factory PasswordUpdateRequest.fromJson(Map<String, dynamic> json) => 
      _$PasswordUpdateRequestFromJson(json);
      
  Map<String, dynamic> toJson() => _$PasswordUpdateRequestToJson(this);
}

@JsonSerializable()
class PasswordUpdateResponse {
  final bool success;
  final String message;

  PasswordUpdateResponse({
    required this.success, 
    required this.message,
  });

  factory PasswordUpdateResponse.fromJson(Map<String, dynamic> json) => 
      _$PasswordUpdateResponseFromJson(json);
      
  Map<String, dynamic> toJson() => _$PasswordUpdateResponseToJson(this);
}