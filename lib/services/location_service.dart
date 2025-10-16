import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
}
