import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final TextEditingController _cityController = TextEditingController();
  String _cityName = '';
  String _errorMessage = '';
  List<dynamic> _forecastData = [];

  // Function to fetch current weather and 5-day forecast
  Future<void> _fetchWeather(String cityName) async {
    const apiKey = '20704f685f43c8df9a022547c8b2d8ca';
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,IN&APPID=$apiKey&units=metric';

    try {
      final forecastResponse = await http.get(Uri.parse(forecastUrl));
      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        setState(() {
          _forecastData = forecastData['list'];
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'City not found or API error!';
          _forecastData = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data. Please try again later.';
        _forecastData = [];
      });
    }
  }

  // Function to get weather icon from Lottie animations
  Widget _getAnimatedWeatherIcon(String description) {
    if (description.contains('clear')) {
      return Lottie.asset('assets/images/sunny.json');
    } else if (description.contains('rain')) {
      return Lottie.asset('assets/images/rainy.json');
    } else if (description.contains('snow')) {
      return Lottie.asset('assets/images/snowy.json');
    } else if (description.contains('cloud')) {
      return Lottie.asset('assets/images/cloudy.json');
    } else {
      return Lottie.asset('assets/images/partly_cloudy.json');
    }
  }

  Map<String, List<dynamic>> _groupForecastByDate() {
    Map<String, List<dynamic>> groupedData = {};
    for (var forecast in _forecastData) {
      String dateStr = forecast['dt_txt'].split(' ')[0];
      if (!groupedData.containsKey(dateStr)) {
        groupedData[dateStr] = [];
      }
      groupedData[dateStr]!.add(forecast);
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Forecast',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City name input field
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _cityName = _cityController.text.trim();
                    });
                    if (_cityName.isNotEmpty) {
                      _fetchWeather(_cityName);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display error message or forecast data
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            if (_forecastData.isNotEmpty) ...[
              const Text(
                '5-Day Forecast',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _groupForecastByDate().keys.length,
                  itemBuilder: (context, index) {
                    String date = _groupForecastByDate().keys.elementAt(index);
                    List<dynamic> dailyForecast =
                        _groupForecastByDate()[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        ...dailyForecast.map((forecast) {
                          final time = DateTime.parse(forecast['dt_txt']);
                          final temperature = forecast['main']['temp'];
                          final description = forecast['weather'][0]
                              ['description'];

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: _getAnimatedWeatherIcon(description),
                              ),
                              title: Text(
                                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '$temperature°C - $description',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
