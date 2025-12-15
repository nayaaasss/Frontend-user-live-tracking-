import 'dart:convert';
import 'package:auth_user/bloc/login_bloc.dart';
import 'package:auth_user/models/booking_model.dart';
import 'package:auth_user/routes.dart';
import 'package:auth_user/services/location_service.dart';
import 'package:auth_user/ui/home/components/model/booking_card.dart';
import 'package:auth_user/ui/home/components/documentation.dart';
import 'package:auth_user/ui/home/components/documentation_model.dart';
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
  String? _addressShort;
  String? _city;
  String? _nama;
  Booking? booking;
  bool loadingBooking = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchBookingData();
    await _getLocation();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('email')?.split('@')[0] ?? 'Pengguna';
    });
  }

  Future<void> _getLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('userId') ?? '0';
      int userIdInt = 0;
      try {
        userIdInt = int.parse(userIdStr);
      } catch (_) {
        userIdInt = 0;
      }

      final email = prefs.getString('email') ?? 'Unknown';
      final token = prefs.getString('token');

      final pos = await LocationService.getCurrentPosition();
      final alamat = await LocationService.getAddress();

      final parts = alamat.split(',');
      String shortAddr =
          parts.isNotEmpty ? parts[0].trim() : "Alamat tidak tersedia";
      String city = parts.length > 1 ? parts[1].trim() : "";

      int bookingIdInt = booking?.id ?? 0;

      final data = {
        "booking_id": bookingIdInt,
        "user_id": userIdInt,
        "name": email.split('@')[0],
        "lat": -6.109831, 
        "lng": 106.882331,
        "container_no": booking?.containerNo ?? "",
        "iso_code": booking?.isoCode ?? "",
        "port_name": booking?.portName ?? "",
        "terminal_name": booking?.terminalName ?? "",
        "container_status": booking?.containerStatus ?? "",
        "shift_in_plan": booking?.shiftInPlan ?? "",
      };

      if (booking?.startTime != null) {
        data["start_time"] = booking!.startTime!.toUtc().toIso8601String();
      }

      if (booking?.endTime != null) {
        data["end_time"] = booking!.endTime!.toUtc().toIso8601String();
      }

      print("data dikirim $data");
      print(
        "booking_id: ${data['booking_id'].runtimeType}, user_id: ${data['user_id'].runtimeType}, lat: ${data['lat'].runtimeType}",
      );

      final res = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/location/update"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("response status: ${res.statusCode}");
      print("response body: ${res.body}");

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          print("backend error: $body");
        } catch (_) {
          print("backend response (non-json): ${res.body}");
        }
      }

      setState(() {
        _addressShort = shortAddr;
        _city = city;
      });
    } catch (e) {
      print("Error _getLocation(): $e");
    }
  }

  Future<void> _fetchBookingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/bookings"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        setState(() {
          booking = data.isNotEmpty ? Booking.fromJson(data.first) : null;
          loadingBooking = false;
        });
      } else {
        setState(() {
          booking = null;
          loadingBooking = false;
        });
        print("Failed fetch booking: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => loadingBooking = false);
      print("Error fetching booking: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                backgroundImage: const AssetImage('assets/images/profile.jpeg'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hallo, ${_nama ?? 'Pengguna'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_city ?? ''} ${_addressShort ?? ''}".trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
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
              if (state is LogoutLoading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blueAccent,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: () => context.read<LoginBloc>().add(Logout()),
                  icon: const Icon(Icons.logout, color: Colors.black, size: 20),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            loadingBooking
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Documentation(
                                  data: DocumentationModel(
                                    title: "Task Today",
                                    count: 8,
                                    unit: "Tasks",
                                    icon: Icons.task,
                                    iconColor: Colors.blue,
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      197,
                                      229,
                                      255,
                                    ),
                                  ),
                                ),
                                Documentation(
                                  data: DocumentationModel(
                                    title: "In progress",
                                    count: 8,
                                    unit: "Tasks",
                                    icon: Icons.work,
                                    iconColor: Colors.pink,
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      255,
                                      201,
                                      219,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Your Task",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      booking != null
                          ? BookingCard(
                            containerType: booking!.containerType,
                            portName: booking!.portName,
                            terminalName: booking!.terminalName,
                            isoCode: booking!.isoCode,
                            gateInPlan: booking!.gateInPlan,
                            shiftInPlan: booking!.shiftInPlan,
                            containerNo: booking!.containerNo,
                            containerStatus: booking!.containerStatus,
                            stid: '',
                          )
                          : const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                "Belum ada booking.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
      ),
    );
  }
}
