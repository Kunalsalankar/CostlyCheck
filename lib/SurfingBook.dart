import 'package:flutter/material.dart';

class SurfingBook extends StatelessWidget {
  const SurfingBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surfing Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book Your Surfing Adventure',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Please enter your details and choose your preferred time slot for the surfing session.'),
            // Add any form or booking details here
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Add booking logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking Confirmed!')),
                );
                Navigator.pop(context); // Go back to the SurfingPage
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
