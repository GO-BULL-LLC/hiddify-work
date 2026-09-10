import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/auth/data/auth_api_client.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
class AuthRepository extends _$AuthRepository {
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  late final AuthApiClient _apiClient;
  late final SharedPreferences _prefs;

  @override
  Future<void> build() async {
    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Initialize API client with device info
    _apiClient = AuthApiClient(
      devicePlatform: 'android',
      hwid: await _getHwid(),
      appLang: 'ru',
      appBuild: '1.0.0',
    );

    // Set token if exists
    final token = getAccessToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }
  }

  Future<String> _getHwid() async {
    // Get or generate hardware ID
    String? hwid = _prefs.getString('device_hwid');
    if (hwid == null) {
      hwid = DateTime.now().millisecondsSinceEpoch.toString();
      await _prefs.setString('device_hwid', hwid);
    }
    return hwid;
  }

  String? getAccessToken() => _prefs.getString(_accessTokenKey);
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);

  Future<void> saveTokens(AuthTokens tokens) async {
    await _prefs.setString(_accessTokenKey, tokens.accessToken);
    await _prefs.setString(_refreshTokenKey, tokens.refreshToken);
    _apiClient.setAuthToken(tokens.accessToken);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    _apiClient.setAuthToken(null);
  }

  bool get isAuthenticated => getAccessToken() != null;

  // API methods
  Future<AppConfig> getAppConfig() => _apiClient.getAppConfig();

  Future<RequestCodeResponse> requestRegistrationCode(String email) =>
      _apiClient.requestRegistrationCode(RequestCodeRequest(email: email));

  Future<AuthTokens> register({
    required String email,
    required String password,
    required String code,
  }) async {
    final tokens = await _apiClient.register(
      RegisterRequest(email: email, password: password, code: code),
    );
    await saveTokens(tokens);
    return tokens;
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _apiClient.login(
      LoginRequest(email: email, password: password),
    );
    await saveTokens(tokens);
    return tokens;
  }

  Future<UserSession> getSession() => _apiClient.getSession();

  Future<ApplyReferralResponse> applyReferral(String code) =>
      _apiClient.applyReferral(ApplyReferralRequest(code: code));

  Future<void> logout() async {
    await clearTokens();
  }
}
