import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auth_user/bloc/login_bloc.dart';
import 'package:auth_user/routes.dart';
import 'package:auth_user/services/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await _handleLocationPermission();
  await initializeService();

  runApp(const MainApp());
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  // PENTING: Agar plugin dikenali di isolate ini
  DartPluginRegistrant.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

   Timer.periodic(const Duration(seconds: 5), (timer) {
    debugPrint("⏱️ service hidup");
  });

   print("BACKGROUND SERVICE STARTED");

  // Gunakan getPositionStream daripada Timer agar lebih stabil di background
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update setiap pindah 10 meter
    ),
  ).listen((pos) {
     FlutterBackgroundService().invoke('location', {
      "token": prefs.getString('token'),
      "user_id": prefs.getString('userId'),
      "email": prefs.getString('email'),
      "lat": pos.latitude,
      "lng": pos.longitude,
      "time": DateTime.now().toIso8601String(),
    });
    
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Lokasi Terkirim",
        content: "Lat: ${pos.latitude}, Lng: ${pos.longitude}",
      );
    }
    
    service.on('location').listen((event) async {
    if (event == null) return;

    try {
       await http.post(
        Uri.parse("http://10.133.148.144:8080/api/location/update"),
        headers: {
          'Authorization': 'Bearer ${event["token"]}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );
    } catch (e) {
      debugPrint("Send error: $e");
    }
  });
});

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}}

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

Future<void> _handleLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    
    permission = await Geolocator.requestPermission();
  }
  // Untuk background, Android butuh 'Always'
  if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
    print("Izin diberikan");
  }
}


Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'location_tracking',
      initialNotificationTitle: 'Tracking Aktif',
      initialNotificationContent: 'Mengambil lokasi...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

