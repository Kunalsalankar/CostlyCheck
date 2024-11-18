import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.teal[50],  // Same background color as Home Screen
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and Edit Button
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.account_circle, size: 80, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Implement logic for changing the profile picture
                        print("Change Profile Picture");
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 16, color: Colors.teal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Name: John Doe',
              style: TextStyle(fontSize: 20, color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email: john.doe@example.com',
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            const Text(
              'Phone: +1234567890',
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            const Text(
              'Address: 123 Street Name, City, Country',
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            const Text(
              'Birthday: January 1, 1990',
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
