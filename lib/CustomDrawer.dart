// CustomDrawer.dart
import 'package:final_project/Current_location.dart';
import 'package:flutter/material.dart';
import 'Profile_Screen.dart';
import 'Notification_Screen.dart';
import 'Help_Screen.dart';
import 'About_Screen.dart';
import 'WeatherForecastScreen.dart'; // Import WeatherForecastScreen

class CustomDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> beaches;

  const CustomDrawer({super.key, required this.beaches});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'User Name',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'user@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Drawer Items with Navigation
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.teal),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.teal),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.teal),
            title: const Text('Coastal Map'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrentLocationScreen(
                    // selectedBeach: beaches[0], // Default to the first beach
                    // allBeaches: beaches,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.teal),
            title: const Text('Weather Forecast'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const WeatherForecastScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.teal),
            title: const Text('Help'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Help_Screen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.teal),
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
