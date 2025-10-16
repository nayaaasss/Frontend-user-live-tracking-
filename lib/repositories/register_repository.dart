import 'package:auth_user/models/register_request_model.dart';
import 'package:auth_user/services/api_service.dart';

class RegisterRepository {
  final apiService = ApiService();

  Future<String> register(RegisterRequestModel requestBody) async {
    try {
      final result = await apiService.register(requestBody);
      return result; 
    } catch (e) {
      return "error";
    }
  }
}
