import 'package:dio/dio.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:hiddify/utils/custom_loggers.dart';

class AuthApiClient with InfraLogger {
  final Dio _dio;
  static const String baseUrl = 'https://up-bull.space/api/v1';

  AuthApiClient({
    required String devicePlatform,
    required String hwid,
    required String appLang,
    required String appBuild,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'X-Device-Platform': devicePlatform,
              'X-Hwid': hwid,
              'X-App-Lang': appLang,
              'X-App-Build': appBuild,
              'Content-Type': 'application/json',
            },
          ),
        );

  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // Get app config (no auth required)
  Future<AppConfig> getAppConfig() async {
    try {
      final response = await _dio.get('/app-config');
      return AppConfig.fromJson(response.data);
    } on DioException catch (e) {
      loggy.error('Failed to get app config', e);
      rethrow;
    }
  }

  // Request registration code
  Future<RequestCodeResponse> requestRegistrationCode(
    RequestCodeRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register/request-code',
        data: request.toJson(),
      );
      return RequestCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiError.fromJson(e.response!.data);
      }
      rethrow;
    }
  }

  // Register with code
  Future<AuthTokens> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthTokens.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiError.fromJson(e.response!.data);
      }
      rethrow;
    }
  }

  // Login
  Future<AuthTokens> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthTokens.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiError.fromJson(e.response!.data);
      }
      rethrow;
    }
  }

  // Get user session (requires auth)
  Future<UserSession> getSession() async {
    try {
      final response = await _dio.get('/session');
      return UserSession.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiError.fromJson(e.response!.data);
      }
      rethrow;
    }
  }

  // Apply referral code
  Future<ApplyReferralResponse> applyReferral(
    ApplyReferralRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/referral/apply',
        data: request.toJson(),
      );
      return ApplyReferralResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiError.fromJson(e.response!.data);
      }
      rethrow;
    }
  }
}
