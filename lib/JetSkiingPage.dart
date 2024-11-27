import 'package:final_project/Book.dart';
import 'package:flutter/material.dart';

class JetSkiingPage extends StatefulWidget {
  const JetSkiingPage({super.key});

  @override
  State<JetSkiingPage> createState() => _JetSkiingPageState();
}

class _JetSkiingPageState extends State<JetSkiingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jet Skiing Details'),
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView for scrollable content
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jet Skiing Adventure',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jet skiing is a thrilling water sport that involves riding high-powered water scooters over the waves. Perfect for adventure lovers seeking an adrenaline rush!',
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
                color: const Color.fromARGB(255, 149, 209, 244),
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
              },
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Color.fromARGB(255, 149, 209, 244)),
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
                        '12-17 years',
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
                        '8:00 AM - 9:00 AM\n4:00 PM - 5:00 PM',
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
                        '18-35 years',
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
                        '9:00 AM - 10:00 AM\n5:00 PM - 6:00 PM',
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
                        '36-50 years',
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
                        '10:00 AM - 11:00 AM\n6:00 PM - 7:00 PM',
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
              '- Always wear a life jacket.\n'
              '- Ensure proper briefing on handling the jet ski.\n'
              '- Avoid reckless speeding and maintain a safe distance from others.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to JetSkiingScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  const Book(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 149, 209, 244), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
