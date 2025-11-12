import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  // Ambil posisi GPS (lat, lng)
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // cek apakah GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS belum aktif");
    }

    // cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Izin lokasi ditolak");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi permanen ditolak");
    }

    // ambil posisi sekarang
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Ambil alamat dari lat-lng
  static Future<String> getAddress() async {
    final pos = await getCurrentPosition();
    final placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.country}";
    } else {
      return "Alamat tidak ditemukan";
    }
  }

  static Future<void> sendDriverLocation(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse("http://10.0.2.2:8080/api/driver-location");

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        print("Location sent successfully");
      } else {
        print("Failed to send location: ${res.statusCode}");
        print("Response: ${res.body}");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }
}
  

