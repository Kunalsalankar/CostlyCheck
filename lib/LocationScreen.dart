import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> beaches = [
    {
      "name": "Cherai Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(10.141595, 76.178284),
      "description": "A serene beach with shallow waters, ideal for swimming and relaxing."
    },
    {
      "name": "Fort Kochi Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(9.9637, 76.2375),
      "description": "Known for its historic charm and iconic Chinese fishing nets."
    },
    {
      "name": "Puthuvype Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(9.976944, 76.226389),
      "description": "A quiet beach with a lighthouse offering scenic views of the coast."
    },
    {
      "name": "Munambam Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(10.1772, 76.1655),
      "description": "A tranquil spot at the northern end of Vypin Island, perfect for picnics."
    },
    {
      "name": "Andhakaranazhi Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(9.747778, 76.283889),
      "description": "A less crowded beach known for its peaceful ambiance and backwater views."
    },
    {
      "name": "Kuzhupilly Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(10.109771, 76.187233),
      "description": "A hidden gem offering scenic beauty and a peaceful atmosphere."
    },
    {
      "name": "Vypin Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(9.998459, 76.218248),
      "description": "A picturesque beach ideal for evening strolls and sunset views."
    },
    {
      "name": "Kappad Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(11.383838, 75.719425),
      "description": "A historic beach where Vasco da Gama first landed in India."
    },
    {
      "name": "Marari Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(9.600644, 76.298362),
      "description": "A beautiful beach with coconut palm-lined shores, perfect for relaxation."
    },
    {
      "name": "Ramakrishna Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.714059, 83.323973),
      "description": "A popular beach promenade with stunning views of the Bay of Bengal."
    },
    {
      "name": "Rushikonda Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.78253, 83.384986),
      "description": "Known for its golden sands and water sports activities."
    },
    {
      "name": "Yarada Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.655093, 83.269158),
      "description": "A secluded beach surrounded by lush greenery and hills."
    },
    {
      "name": "Bheemili Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.890564, 83.456214),
      "description": "A peaceful beach with a historic Dutch cemetery nearby."
    },
    {
      "name": "Lawson's Bay Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.733727, 83.342459),
      "description": "A picturesque beach known for its calm waters and sunrise views."
    },
    {
      "name": "Gangavaram Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.620635, 83.233008),
      "description": "A serene beach lined with palm trees, offering stunning natural views."
    },
    {
      "name": "Sagar Nagar Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.761837, 83.360242),
      "description": "A lesser-known beach with scenic beauty and tranquility."
    },
    {
      "name": "Thotlakonda Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.822576, 83.416285),
      "description": "A serene beach near the historic Buddhist site of Thotlakonda."
    },
    {
      "name": "Appikonda Beach",
      "city": "Vizag",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.57422, 83.17388),
      "description": "A quiet beach with a historic Shiva temple nearby."
    },
    {
      "name": "Kochi Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": const LatLng(9.9356, 76.2813),
      "description": "A beautiful beach known for its stunning sunsets and Chinese fishing nets."
    },
    {
      "name": "Calangute Beach",
      "city": "Calangute",
      "state": "Goa",
      "coordinates": const LatLng(15.5494, 73.7535),
      "description": "One of the most popular beaches in Goa, known for its nightlife and water sports."
    },
    {
      "name": "Baga Beach",
      "city": "Goa",
      "state": "Goa",
      "coordinates": const LatLng(15.5524, 73.7517),
      "description": "Famous for its vibrant nightlife and water sports."
    },
    {
      "name": "Calangute Beach",
      "city": "Calangute",
      "state": "Goa",
      "coordinates": const LatLng(15.5494, 73.7535),
      "description": "One of the most popular beaches in Goa, known for its nightlife and water sports."
    },
    {
      "name": "Kovalam Beach",
      "city": "Kovalam",
      "state": "Kerala",
      "coordinates": const LatLng(8.3985, 76.9969),
      "description": "Famous for its crescent-shaped beaches and lighthouses."
    },
    {
      "name": "RK Beach",
      "city": "Visakhapatnam",
      "state": "Andhra Pradesh",
      "coordinates": const LatLng(17.6880, 83.3042),
      "description": "Known for its picturesque beach promenade and sunset views."
    },
    {
      "name": "Alibag Beach",
      "city": "Alibag",
      "state": "Maharashtra",
      "coordinates": const LatLng(18.6400, 72.8339),
      "description": "A sandy beach popular for its scenic views and water sports."
    },
    {
      "name": "Varsoli Beach",
      "city": "Alibag",
      "state": "Maharashtra",
      "coordinates": const LatLng(18.3462, 72.8252),
      "description": "Known for its calm waters and peaceful surroundings."
    },
    {
      "name": "Varkala Beach",
      "city": "Varkala",
      "state": "Kerala",
      "coordinates": const LatLng(8.7330, 76.7116),
      "description": "Known for its cliffs and stunning views."
    },
    {
      "name": "Anjuna Beach",
      "city": "Anjuna",
      "state": "Goa",
      "coordinates": const LatLng(15.5733, 73.7410),
      "description": "Famous for its flea market and vibrant atmosphere."
    },
    {
      "name": "Juhu Beach",
      "city": "Mumbai",
      "state": "Maharashtra",
      "coordinates": const LatLng(19.0974, 72.8264),
      "description": "A popular beach known for its street food and Bollywood connections."
    },
    {
      "name": "Puri Beach",
      "city": "Puri",
      "state": "Odisha",
      "coordinates": const LatLng(19.8145, 85.8312),
      "description": "Known for its golden sands and the annual Rath Yatra."
    },
    {
      "name": "Mahabalipuram Beach",
      "city": "Mahabalipuram",
      "state": "Tamil Nadu",
      "coordinates": const LatLng(12.6192, 80.2029),
      "description": "Famous for its rock-cut temples and historical significance."
    },
  ];

  List<Map<String, dynamic>> _filteredBeaches = [];
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _filteredBeaches = beaches;
  }

  void _filterResults(String query) {
    setState(() {
      _filteredBeaches = beaches
          .where((beach) =>
              beach["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<String> _getWeather(double lat, double lon) async {
    final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final weather = data['current_weather'];
      return "Current temperature: ${weather['temperature']}°C, Wind Speed: ${weather['windspeed']} m/s";
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  void _showBeachDetails(Map<String, dynamic> beach) async {
    final weatherInfo = await _getWeather(
        beach["coordinates"].latitude, beach["coordinates"].longitude);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(beach["name"]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${beach["city"]}, ${beach["state"]}"),
              const SizedBox(height: 10),
              Text(beach["description"]),
              const SizedBox(height: 10),
              Text(weatherInfo,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Color.fromARGB(255, 149, 209, 244))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Color _getMarkerColor(Map<String, dynamic> beach) {
    // Example conditions for demonstration
    if (beach["name"].toLowerCase().contains("cherai")) {
      return Colors.green; // Safe
    } else if (beach["name"].toLowerCase().contains("fort")) {
      return Colors.yellow; // Moderate
    } else if (beach["name"].toLowerCase().contains("puthuvype")) {
      return Colors.orange; // Caution
    } else {
      return Colors.red; // Unsafe
    }
  }

  List<Marker> _buildMarkers() {
    return _filteredBeaches.map((beach) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: beach["coordinates"],
        child: GestureDetector(
          onTap: () => _showBeachDetails(beach),
          child: Icon(
            Icons.location_on,
            size: 40,
            color: _getMarkerColor(beach),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map - Shore Shield"),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterResults,
              decoration: const InputDecoration(
                hintText: "Search for a beach...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(10.141595, 76.178284),
                initialZoom: 9.5,
                minZoom: 7,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
          ),
          if (_filteredBeaches.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: _filteredBeaches.length,
                itemBuilder: (context, index) {
                  final beach = _filteredBeaches[index];
                  return ListTile(
                    title: Text(beach["name"]),
                    onTap: () {
                      _mapController.move(beach["coordinates"], 10.0);
                      _showBeachDetails(beach);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
