import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080"; 

  // Register
  Future<bool> register(String email, String password, String role) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
        "role": role,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print("Register gagal: ${response.body}");
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      final me = await getMe();
      if (me != null) {
        await prefs.setString("userId", me["user_id"].toString() [token]);
        await prefs.setString("role", me["role"]);
        await prefs.setString("email", email);
      }

      return true;
    } else {
      print("Login gagal: ${response.body}");
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, dynamic>?> getMe() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/api/token");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error fetching /token: ${response.body}");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
