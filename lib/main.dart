import 'package:auth_user/bloc/login_bloc.dart';
import 'package:auth_user/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => LoginBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: MyRoute.home.name,
        routes: routes,
      ),
    );
  }
}