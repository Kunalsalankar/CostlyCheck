import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  // API URLs and API key
  final String url1 = 'https://gemini.incois.gov.in/incoisapi/rest/ssalatestgeo';
  final String url2 = 'https://gemini.incois.gov.in/incoisapi/rest/currentslatestgeo';
  final String apiKey = '446d183e64e64e8eb4bca1407ab02a89';

  // List to store the data
  List<Map<String, dynamic>> propertiesData = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is loaded
    fetchAlertData();
  }

  // Fetch data from both API URLs
  Future<void> fetchAlertData() async {
    try {
      final response1 = await http.get(Uri.parse(url1), headers: {'Authorization': apiKey});
      final response2 = await http.get(Uri.parse(url2), headers: {'Authorization': apiKey});

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        final Map<String, dynamic> data1 = json.decode(response1.body);
        final Map<String, dynamic> data2 = json.decode(response2.body);

        // Extracting the "properties" part from both API responses
        setState(() {
          propertiesData = [
            ...propertiesDataFromApi(data1),
            ...propertiesDataFromApi(data2),
          ];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Helper function to extract "properties" from the API response
  List<Map<String, dynamic>> propertiesDataFromApi(Map<String, dynamic> data) {
    List<Map<String, dynamic>> propertiesList = [];
    if (data['features'] != null) {
      for (var feature in data['features']) {
        propertiesList.add(feature['properties']);
      }
    }
    return propertiesList;
  }

  // Convert string color from API to Color object
  Color getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.white; // Default color if none matched
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocean Alert Data'),
      ),
      body: propertiesData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: propertiesData.length,
              itemBuilder: (context, index) {
                final property = propertiesData[index];
                final colorString = property['Color'] ?? 'white'; // Default color is white
                final backgroundColor = getColorFromString(colorString);

                return Card(
                  margin: const EdgeInsets.all(10),
                  color: backgroundColor, // Set background color dynamically
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('District: ${property['District']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('State: ${property['STATE']}'),
                        Text('Message: ${property['Message']}'),
                        Text('Alert: ${property['Alert']}'),
                        Text('Color: ${property['Color']}'),
                        Text('Issue Date: ${property['Issue Date']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AlertScreen(),
  ));
}
