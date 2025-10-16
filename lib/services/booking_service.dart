import 'dart:convert';
import 'package:auth_user/utils/session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

class BookingService {
  static const String baseUrl = "http://10.0.2.2:8080"; 

  static Future<Booking?> getUserBooking() async {
    final sessionManager = SessionManager();
    final token = await sessionManager.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/bookings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isEmpty) return null;
      return Booking.fromJson(data.first); 
    }
    return null;
  }

  static Future<bool> updateBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl/api/booking/${booking.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(booking.toJson()),
    );
    
    return response.statusCode == 200;
  }

  
}
