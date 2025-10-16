import 'package:auth_user/models/login_request_model.dart';
import 'package:auth_user/models/login_response_model.dart';
import 'package:auth_user/repositories/login_repository.dart';
import 'package:auth_user/utils/session_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final repository = LoginRepository();
  LoginBloc() : super(LoginInitial()) {
    on<Login>((event, emit) async {
      emit(LoginLoading());

      final result = await repository.login(event.requestBody);

      await result.fold(
        (errorMessage) async {
          emit(LoginFailed(errorMessage));
        },
        (loginData) async {
          final sessionManager = SessionManager();
          await sessionManager.saveSession(loginData.token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', loginData.token);
          await prefs.setString('userId', loginData.userId);
          await prefs.setString('email', loginData.email);
          await prefs.setString('role', loginData.role);

          print(
            'Disimpan ke prefs: userId=${loginData.userId}, email=${loginData.email}, role=${loginData.role}',
          );
          emit(LoginSuccess(loginData)); 
        },
      );
    });
    on<Logout>((event, emit) async {
      emit(LogoutLoading());
      final sessionManager = SessionManager();
      await sessionManager.removeSession();
      emit(LogoutSuccess());
    });
  }
}
