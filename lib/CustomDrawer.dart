import 'package:flutter/material.dart';
import 'Notification_Screen.dart';
import 'Help_Screen.dart';
import 'About_Screen.dart';
import 'LocationScreen.dart';
import 'WeatherForecastScreen.dart'; // Import WeatherForecastScreen
import 'TidalForecastScreen.dart';

class CustomDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> beaches;

  const CustomDrawer({super.key, required this.beaches});

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
            leading: const Icon(Icons.map, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Coastal Map'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.water, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Tidal Forecast'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TidalForecastScreen()),
              );
            },
          ),
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
            leading: const Icon(Icons.notifications, color: Color.fromARGB(255, 0, 0, 0)),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
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
