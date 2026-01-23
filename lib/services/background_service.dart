// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;



@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'Tracking Aktif',
      content: 'Menunggu lokasi...',
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
}


@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
