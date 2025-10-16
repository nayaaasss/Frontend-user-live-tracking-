import 'package:auth_user/constants/app_contants_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  Future<void> saveSession(String accessToken, {String? userId, String? email, String? nama}) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppConstants.tokenKey, accessToken);
    if (userId != null) await pref.setString('userId', userId);
    if (email != null) await pref.setString('email', email);
    if (nama != null) await pref.setString('nama', nama);
  }

  Future<String> getAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(AppConstants.tokenKey) ?? '';
  }

  Future<Map<String, String>> getUserData() async {
    final pref = await SharedPreferences.getInstance();
    return {
      "userId": pref.getString('userId') ?? '',
      "email": pref.getString('email') ?? '',
      "nama": pref.getString('nama') ?? '',
    };
  }

  Future<void> removeSession() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
