import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// Request models
@freezed
class RequestCodeRequest with _$RequestCodeRequest {
  const factory RequestCodeRequest({
    required String email,
  }) = _RequestCodeRequest;

  factory RequestCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestCodeRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    required String code,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class ApplyReferralRequest with _$ApplyReferralRequest {
  const factory ApplyReferralRequest({
    required String code,
  }) = _ApplyReferralRequest;

  factory ApplyReferralRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyReferralRequestFromJson(json);
}

// Response models
@freezed
class ApiError with _$ApiError {
  const factory ApiError({
    required String error,
    required String message,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

@freezed
class RequestCodeResponse with _$RequestCodeResponse {
  const factory RequestCodeResponse({
    required bool ok,
  }) = _RequestCodeResponse;

  factory RequestCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestCodeResponseFromJson(json);
}

@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
class Referral with _$Referral {
  const factory Referral({
    required String code,
    @JsonKey(name: 'share_link') required String shareLink,
    @JsonKey(name: 'can_apply') required bool canApply,
    @JsonKey(name: 'invited_count') required int invitedCount,
    @JsonKey(name: 'bonus_percent') required int bonusPercent,
  }) = _Referral;

  factory Referral.fromJson(Map<String, dynamic> json) =>
      _$ReferralFromJson(json);
}

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String code, // "free", "trial", "comfort", "pro"
    required String name,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required SubscriptionPlan plan,
    required String status, // "active", "expired", etc.
    @JsonKey(name: 'expires_at') DateTime? expiresAt, // null for free tier
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
class Server with _$Server {
  const factory Server({
    required String id,
    required String name,
    required String country,
    required bool available,
    required bool locked,
    @JsonKey(name: 'lock_reason') String? lockReason, // "paid_required"
    @JsonKey(name: 'lock_message') String? lockMessage,
  }) = _Server;

  factory Server.fromJson(Map<String, dynamic> json) =>
      _$ServerFromJson(json);
}

@freezed
class UserSession with _$UserSession {
  const factory UserSession({
    required String email,
    Referral? referral,
    Subscription? subscription,
    List<Server>? servers,
  }) = _UserSession;

  factory UserSession.fromJson(Map<String, dynamic> json) =>
      _$UserSessionFromJson(json);
}

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    @JsonKey(name: 'support_url') required String supportUrl,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}

@freezed
class ApplyReferralResponse with _$ApplyReferralResponse {
  const factory ApplyReferralResponse({
    required bool ok,
  }) = _ApplyReferralResponse;

  factory ApplyReferralResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplyReferralResponseFromJson(json);
}
