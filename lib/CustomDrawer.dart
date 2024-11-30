import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Help_Screen.dart';
import 'About_Screen.dart';
import 'WeatherForecastScreen.dart';
import 'successful.dart';

class CustomDrawer extends StatefulWidget {
  final List<Map<String, dynamic>> beaches;

  const CustomDrawer({Key? key, required this.beaches}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map<String, dynamic>? _latestBooking;

  @override
  void initState() {
    super.initState();
    _loadLatestBooking();
  }

  Future<void> _loadLatestBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingJson = prefs.getString('latestBooking');

    if (bookingJson != null) {
      setState(() {
        _latestBooking = json.decode(bookingJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with Logo
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 149, 209, 244),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add your logo here
                Image.asset(
                  'assets/images/logo.png', // Path to your logo in the assets folder
                  width: 110,         // Adjust the width as needed
                  height: 80,        // Adjust the height as needed
                ),
                const SizedBox(height: 10), // Space between logo and text
                const Text(
                  'Coasty Check App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items with Navigation
          ListTile(
            leading: const Icon(Icons.cloud, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Weather Forecast'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherForecastScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.local_activity, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Activity'),
            onTap: () {
              // Check if there's a latest booking
              if (_latestBooking != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuccessfulPage(
                      name: _latestBooking!['name'] ?? '',
                      beach: _latestBooking!['beach'] ?? '',
                      activity: _latestBooking!['activity'] ?? '',
                      numPeople: _latestBooking!['numPeople'] ?? 0,
                      peopleDetails: _latestBooking!['peopleDetails'] != null
                          ? List<Map<String, String>>.from(
                          _latestBooking!['peopleDetails'].map<Map<String, String>>(
                                  (item) => Map<String, String>.from(item)
                          )
                      )
                          : [],
                      date: _latestBooking!['date'] ?? '',
                      price: (_latestBooking!['price'] is String
                          ? double.tryParse(_latestBooking!['price']) ?? 0.0
                          : (_latestBooking!['price'] ?? 0.0).toDouble()),
                    ),
                  ),
                );
              } else {
                // Show a message if no booking exists
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No recent bookings found'))
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.help, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Help'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Help_Screen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('About us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}