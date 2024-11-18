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
      // Fetch 5-day forecast
      final forecastResponse = await http.get(Uri.parse(forecastUrl));
      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        setState(() {
          _forecastData = forecastData['list']; // Update forecast data
        });
      } else {
        setState(() {
          _errorMessage = 'City not found or API error!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data. Please try again later.';
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

  // Group forecast data by date
  Map<String, List<dynamic>> _groupForecastByDate() {
    Map<String, List<dynamic>> groupedData = {};
    
    for (var forecast in _forecastData) {
      String dateStr = forecast['dt_txt'].split(' ')[0]; // Extract date
      if (!groupedData.containsKey(dateStr)) {
        groupedData[dateStr] = [];
      }
      groupedData[dateStr]!.add(forecast);
    }
    return groupedData;
  }

  // Function to determine the background color based on weather conditions
  Color _getBackgroundColor(String date) {
    // Ensure the background color is light enough for text visibility
    return Color((date.hashCode * 0xFFFFFF).toInt()).withOpacity(0.8);
  }

  // Text style based on background color luminance
  TextStyle _getTextStyle(bool isDarkBackground) {
    return TextStyle(
      color: isDarkBackground ? Colors.white : Colors.black,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Day Weather Forecast'),
        backgroundColor: Colors.blue,
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
                fillColor: Colors.blue.shade50,
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
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            if (_forecastData.isNotEmpty) ...[
              const Text(
                '5-Day Forecast',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Group the forecast by date
              Expanded(
                child: ListView.builder(
                  itemCount: _groupForecastByDate().keys.length,
                  itemBuilder: (context, index) {
                    // Get the date and forecast data for that date
                    String date = _groupForecastByDate().keys.elementAt(index);
                    List<dynamic> dailyForecast = _groupForecastByDate()[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            date,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),

                        // List the forecast data for that date
                        ...dailyForecast.map((forecast) {
                          final time = DateTime.parse(forecast['dt_txt']);
                          final temperature = forecast['main']['temp'];
                          final description = forecast['weather'][0]['description'];

                          bool isDarkBackground =
                              _getBackgroundColor(date).computeLuminance() < 0.5;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 5,
                            color: _getBackgroundColor(date),
                            child: ListTile(
                              title: Text(
                                '${time.hour}:${time.minute}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  // Set a fixed size for the Lottie icon
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: _getAnimatedWeatherIcon(description),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '$temperature°C, $description',
                                      style: _getTextStyle(isDarkBackground),
                                      overflow: TextOverflow.ellipsis, // Ensure text does not overflow
                                    ),
                                  ),
                                ],
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
