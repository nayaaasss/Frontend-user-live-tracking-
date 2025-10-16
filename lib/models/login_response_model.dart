import 'package:jwt_decoder/jwt_decoder.dart';

class LoginResponseModel {
  final String token;
  final Map<String, dynamic> decodedToken;

  LoginResponseModel({
    required this.token,
    required this.decodedToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final decoded = JwtDecoder.decode(token);

    return LoginResponseModel(
      token: token,
      decodedToken: decoded,
    );
  }

  String get userId => decodedToken['user_id'].toString();
  String get role => decodedToken['role'];
  String get email => decodedToken['email'] ?? 'unknown@email.com';
}
