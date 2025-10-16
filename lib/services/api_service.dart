import 'package:auth_user/constants/app_contants_app.dart';
import 'package:auth_user/models/login_request_model.dart';
import 'package:auth_user/models/login_response_model.dart';
import 'package:auth_user/models/register_request_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  final baseUrl = AppConstants.baseUrl;
  final dio = Dio();

  Future<LoginResponseModel> login(LoginRequestModel requestBody) async {
    final response = await dio.post(
      '$baseUrl/login', 
      data: requestBody.toJson(),
    );
      return LoginResponseModel.fromJson(response.data);
  }

   Future<String> register(RegisterRequestModel requestBody) async {
  final response = await dio.post(
    '$baseUrl/register',
    data: requestBody.toJson(),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return "success";
  } else if (response.statusCode == 500 && 
             response.data.toString().contains("duplicate key")) {
    return "already_exists";
  } else {
    return "error";
  }
  }

}
