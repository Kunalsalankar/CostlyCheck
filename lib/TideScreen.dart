import 'package:flutter/material.dart';

class TideScreen extends StatelessWidget {
  final dynamic predictionsData;

  // Constructor to receive the tide predictions data from the previous screen
  const TideScreen({super.key, required this.predictionsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tide Predictions'),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: predictionsData != null && predictionsData['predictions'] != null
            ? ListView.builder(
                itemCount: predictionsData['predictions'].length,
                itemBuilder: (context, index) {
                  var tide = predictionsData['predictions'][index];
                  // Determine card color and icon based on tide type
                  Color cardColor;
                  IconData tideIcon;

                  if (tide['type'] == 'H') {
                    cardColor = Colors.lightBlue.shade100;
                    tideIcon = Icons.arrow_upward;
                  } else {
                    cardColor = Colors.orange.shade100;
                    tideIcon = Icons.arrow_downward;
                  }

                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          tideIcon,
                          color: cardColor == Colors.lightBlue.shade100
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                      title: Text(
                        tide['t'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Type: ${tide['type']} - Height: ${tide['v']} meters',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
      ),
    );
  }
}
