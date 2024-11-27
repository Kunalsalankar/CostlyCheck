import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import the activity pages (e.g., Paragliding.dart, Surfing.dart, etc.)
import 'SnorkelingPage.dart';
import 'JetSkiingPage.dart';
import 'ParasailingPage.dart'; // Added Parasailing activity page

class ExploreScreen extends StatefulWidget {
  final String beachName;

  // Beach coordinates mapping
  final Map<String, List<double>> beachCoordinates = {
    'Cherai Beach, Kochi': [10.141595, 76.178284],
    'Fort Kochi Beach, Kochi': [9.9637, 76.2375],
    'Puthuvype Beach, Kochi': [9.976944, 76.226389],
    'Munambam Beach, Kochi': [10.1772, 76.1655],
    'Andhakaranazhi Beach, Kochi': [9.747778, 76.283889],
    'Kuzhupilly Beach, Kochi': [10.109771, 76.187233],
    'Vypin Beach, Kochi': [9.998459, 76.218248],
    'Kappad Beach, Kochi': [11.383838, 75.719425],
    'Marari Beach, Kochi': [9.600644, 76.298362],
    'Ramakrishna Beach, Vizag': [17.714059, 83.323973],
    'Rushikonda Beach, Vizag': [17.78253, 83.384986],
    'Yarada Beach, Vizag': [17.655093, 83.269158],
    'Bheemili Beach, Vizag': [17.890564, 83.456214],
    'Lawson\'s Bay Beach, Vizag': [17.733727, 83.342459],
    'Gangavaram Beach, Vizag': [17.620635, 83.233008],
    'Sagar Nagar Beach, Vizag': [17.761837, 83.360242],
    'Thotlakonda Beach, Vizag': [17.822576, 83.416285],
    'Appikonda Beach, Vizag': [17.57422, 83.17388]
  };

  // Beach images mapping
  final Map<String, String> beachImages = {
    'Cherai Beach, Kochi': 'images/cherai_beach.jpg',
    'Fort Kochi Beach, Kochi': 'images/fort_kochi_beach.jpg',
    'Puthuvype Beach, Kochi': 'images/puthuvype_beach.jpg',
    'Munambam Beach, Kochi': 'images/munambam_beach.jpg',
    'Andhakaranazhi Beach, Kochi': 'images/andhakaranazhi_beach.jpg',
    'Kuzhupilly Beach, Kochi': 'images/kuzhupilly_beach.jpg',
    'Vypin Beach, Kochi': 'images/vypin_beach.jpg',
    'Kappad Beach, Kochi': 'images/kappad_beach.jpg',
    'Marari Beach, Kochi': 'images/marari_beach.jpg',
    'Ramakrishna Beach, Vizag': 'images/ramakrishna_beach.jpg',
    'Rushikonda Beach, Vizag': 'images/rushikonda_beach.jpg',
    'Yarada Beach, Vizag': 'images/yarada_beach.jpg',
    'Bheemili Beach, Vizag': 'images/bheemili_beach.jpg',
    'Lawson\'s Bay Beach, Vizag': 'images/lawsons_bay_beach.jpg',
    'Gangavaram Beach, Vizag': 'images/gangavaram_beach.jpg',
    'Sagar Nagar Beach, Vizag': 'images/sagar_nagar_beach.jpg',
    'Thotlakonda Beach, Vizag': 'images/thotlakonda_beach.jpg',
    'Appikonda Beach, Vizag': 'images/appikonda_beach.jpg'
  };

  ExploreScreen({super.key, required this.beachName});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Map<String, dynamic>? currentWeatherData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await fetchWeatherData();
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Unable to load weather data";
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchWeatherData() async {
    if (!mounted) return;

    try {
      final coordinates = widget.beachCoordinates[widget.beachName] ?? [0.0, 0.0];
      final latitude = coordinates[0];
      final longitude = coordinates[1];

      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
      final response = await http.get(Uri.parse(weatherUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentWeatherData = data['current_weather'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error loading weather data: $e";
          isLoading = false;
        });
      }
    }
  }

  Widget _buildBeachImage() {
    final imagePath = widget.beachImages[widget.beachName] ?? 'assets/images/default_beach.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (currentWeatherData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Current Weather",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thermostat, size: 30, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "Temperature: ${currentWeatherData!['temperature']}°C",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.air, size: 30, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Wind Speed: ${currentWeatherData!['windspeed']} m/s",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityButton(String activityName, Widget activityPage) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => activityPage),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 50),
        backgroundColor: const Color.fromARGB(255, 244, 186, 153),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(activityName),
    );
  }

  Widget _buildActivitySection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Check Activities at ${widget.beachName}",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            _buildActivityButton('Snorkeling', const SnorkelingPage()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActivityButton('Jet Skiing', const JetSkiingPage()),
            _buildActivityButton('Parasailing', const ParasailingPage()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.beachName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBeachImage(),
                  const SizedBox(height: 20),
                  _buildWeatherCard(),
                  const SizedBox(height: 20),
                  _buildActivitySection(),
                ],
              ),
            ),
    );
  }
}
