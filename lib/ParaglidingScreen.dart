import 'package:flutter/material.dart';

class ParaglidingScreen extends StatelessWidget {
  const ParaglidingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Paragliding Experience'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Date and Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Date Picker
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  // You can handle the picked date here
                  print("Selected Date: ${pickedDate.toLocal()}");
                }
              },
              child: const InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(),
                ),
                child: Text('Tap to select date'),
              ),
            ),
            const SizedBox(height: 24),
            // Time Slots Dropdown
            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Time Slot',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: '8:00 AM - 9:00 AM',
                  child: Text('8:00 AM - 9:00 AM'),
                ),
                DropdownMenuItem(
                  value: '9:30 AM - 10:30 AM',
                  child: Text('9:30 AM - 10:30 AM'),
                ),
                DropdownMenuItem(
                  value: '7:00 AM - 8:00 AM',
                  child: Text('7:00 AM - 8:00 AM'),
                ),
                // Add more time slots as needed
              ],
              onChanged: (String? value) {
                // You can handle the selected time slot here
                print("Selected Time Slot: $value");
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Your Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Name Input Field
            const TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Age Input Field
            const TextField(
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            // Book Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking Successful!')),
                  );
                  Navigator.pop(context); // Go back to the previous page
                },
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
