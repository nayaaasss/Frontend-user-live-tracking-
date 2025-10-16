import 'package:auth_user/ui/auth/regist/regist_screen.dart';
import 'package:auth_user/ui/home/home_screen.dart';

enum MyRoute {
  login('/regist'),
  home('/home');

  final String name;
  const MyRoute(this.name);
}

final routes = {
  MyRoute.login.name: (context) => RegisterScreen(),
  MyRoute.home.name: (context) => const HomeScreen(),
};
