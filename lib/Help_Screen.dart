import 'package:flutter/material.dart';

class Help_Screen extends StatelessWidget {
  const Help_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
      ),
      body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Help & Support Section',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Here are some helpful tips and information about the app:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildHelpCard(
              context,
              'Weather & Beach Information',
              'This section provides real-time weather data and details about various beaches, including facilities, beach safety ratings, and weather conditions.',
            ),
            _buildHelpCard(
              context,
              'Coastal Map',
              'The coastal map section allows you to view a map of coastal regions and their safety status based on weather and ocean conditions. You can explore beaches and their amenities on the map.',
            ),
            _buildHelpCard(
              context,
              'Notifications',
              'The notifications section helps you stay updated on beach safety alerts, weather warnings, and other important information related to coastal safety.',
            ),
            _buildHelpCard(
              context,
              'Profile Management',
              'You can manage your profile and settings through the "Profile" section, where you can update your personal information and preferences.',
            ),
            _buildHelpCard(
              context,
              'Log Out',
              'To log out, simply go to the "Log Out" section in the drawer menu. This will sign you out from the app.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Need more help? Contact us at: support@coastalapp.com',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
