import 'package:flutter/material.dart';
// Import your ParaglidingScreen.dart file
import 'Book.dart';

class ParaglidingPage extends StatefulWidget {
  const ParaglidingPage($, {super.key, required String beachName});

  @override
  State<ParaglidingPage> createState() => _ParaglidingPageState();
}

class _ParaglidingPageState extends State<ParaglidingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paragliding Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paragliding Adventure',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Paragliding is a breathtaking adventure sport that allows you to soar through the sky like a bird. '
                'Experience the thrill of flight and enjoy stunning aerial views of the coastline.',
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
                  color: Colors.deepPurple,
                  width: 1,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.5),
                },
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.deepPurple),
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
                          '12-18 years',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '2500',
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
                          '19-35 years',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '3000',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '9:30 AM - 10:30 AM\n5:30 PM - 6:30 PM',
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
                          '2800',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '7:00 AM - 8:00 AM\n3:30 PM - 4:30 PM',
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
                '- Ensure you are wearing a secure harness and helmet.\n'
                '- Always fly with an experienced instructor if you are a beginner.\n'
                '- Check weather conditions to avoid high winds or rain.\n'
                '- Follow all instructions given by your instructor carefully.\n'
                '- Avoid carrying loose items while flying to prevent hazards.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the ParaglidingScreen.dart
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  const Book(), // Make sure this screen is defined
                      ),
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
