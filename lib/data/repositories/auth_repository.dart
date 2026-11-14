import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/user_session.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResult<UserSession>> login(String username, String password) async {
    final result = await _client.post(
      ApiEndpoints.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal menghubungi server.');
    }

    try {
      final data = result.data;
      if (data is Map<String, dynamic> && data['message'] == 'Success') {
        final val = data['value'] as Map<String, dynamic>;
        final userSession = UserSession.fromMap(val, username: username);

        if (!userSession.isActive) {
          return ApiResult.failure('Akun Anda tidak aktif. Hubungi administrator.');
        }

        await saveSession(userSession);
        return ApiResult.success(userSession);
      } else {
        return ApiResult.failure('Username atau password salah.');
      }
    } catch (e) {
      return ApiResult.failure('Gagal memproses data login.');
    }
  }

  Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', session.userName);
    await prefs.setString('isLogin', 'OK');
    await prefs.setString('userIid', session.userIid);
    await prefs.setString('kodeUpb', session.kodeUpb);
    await prefs.setString('fullName', session.fullName);
    await prefs.setString('shortName', session.shortName);
    await prefs.setString('level', session.level);
    await prefs.setString('admin', session.admin);
    await prefs.setString('active', session.active);
    await prefs.setString('readonly', session.readonly);
    await prefs.setString('nmUnit', session.nmUnit);
    await prefs.setString('nmSub', session.nmSub);
    await prefs.setString('nmUpb', session.nmUpb);
  }

  Future<UserSession?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getString('isLogin') ?? '';
    if (isLogin != 'OK') return null;

    return UserSession(
      userName: prefs.getString('userName') ?? '',
      userIid: prefs.getString('userIid') ?? '',
      kodeUpb: prefs.getString('kodeUpb') ?? '',
      fullName: prefs.getString('fullName') ?? '',
      shortName: prefs.getString('shortName') ?? '',
      level: prefs.getString('level') ?? '',
      admin: prefs.getString('admin') ?? '',
      active: prefs.getString('active') ?? '',
      readonly: prefs.getString('readonly') ?? '',
      nmUnit: prefs.getString('nmUnit') ?? '',
      nmSub: prefs.getString('nmSub') ?? '',
      nmUpb: prefs.getString('nmUpb') ?? '',
    );
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('isLogin') == 'OK';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

