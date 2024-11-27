import 'package:flutter/material.dart';
import 'SurfingBook.dart'; // Make sure you import the SurfingBook page

class SurfingPage extends StatefulWidget {
  const SurfingPage(Set<String> set, {super.key});

  @override
  State<SurfingPage> createState() => _SurfingPageState();
}

class _SurfingPageState extends State<SurfingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surfing Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Surfing Adventure',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Surfing is a thrilling water sport that involves riding ocean waves using a surfboard. '
                'It’s an activity that combines adventure, skill, and connection with the ocean.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Age Criteria, Fare & Time Slots',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(
                  color: Colors.teal,
                  width: 1,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.5),
                },
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.teal),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Age Group',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Fare (INR)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Time Slots',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '10-15 years',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '1000',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '9:00 AM - 10:30 AM\n3:30 PM - 5:00 PM',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '16-30 years',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '1500',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '10:30 AM - 12:00 PM\n5:00 PM - 6:30 PM',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '31-50 years',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '1200',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '8:00 AM - 9:00 AM\n4:00 PM - 5:30 PM',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Safety Guidelines',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Wear appropriate surfwear and safety gear.\n'
                '- Follow instructions from the surfing coach carefully.\n'
                '- Check weather and water conditions before surfing.\n'
                '- Use a leash to keep the surfboard attached to you.\n'
                '- Be respectful of other surfers and avoid overcrowded zones.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              // Book Now Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to SurfingBook.dart when pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SurfingBook()),
                    );
                  },
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
