import 'package:flutter/material.dart';

class JetSkiingScreen extends StatelessWidget {
  const JetSkiingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jet Skiing Booking'),
      ),
      body: const Center(
        child: Text(
          'Booking Page for Jet Skiing',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
