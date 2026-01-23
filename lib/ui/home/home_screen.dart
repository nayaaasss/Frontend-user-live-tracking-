import 'dart:convert';
import 'package:auth_user/bloc/login_bloc.dart';
import 'package:auth_user/models/booking_model.dart';
import 'package:auth_user/routes.dart';
import 'package:auth_user/ui/home/components/model/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _nama;
  Booking? booking;
  bool loadingBooking = true;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _nama = prefs.getString('email')?.split('@')[0] ?? 'Pengguna';
    });
  }

  Future<void> _fetchBookingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse("http://10.133.148.144:8080/api/bookings"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        booking = data.isNotEmpty ? Booking.fromJson(data.first) : null;
      }

      loadingBooking = false;
      setState(() {});
    } catch (_) {
      loadingBooking = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile.jpeg'),
            ),
            const SizedBox(width: 12),
            Text(
              "Hi, ${_nama ?? 'User'}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyRoute.login.name,
                  (_) => false,
                );
              }
            },
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () =>
                    context.read<LoginBloc>().add(Logout()),
              );
            },
          ),
        ],
      ),
      body: loadingBooking
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? const Center(child: Text("Belum ada booking"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: BookingCard(
                    containerType: booking!.containerType,
                    portName: booking!.portName,
                    terminalName: booking!.terminalName,
                    isoCode: booking!.isoCode,
                    gateInPlan: booking!.gateInPlan,
                    shiftInPlan: booking!.shiftInPlan,
                    containerNo: booking!.containerNo,
                    containerStatus: booking!.containerStatus,
                    stid: booking!.stid,
                  ),
                ),
    );
  }
}
