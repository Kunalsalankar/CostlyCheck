import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '20704f685f43c8df9a022547c8b2d8ca';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  String cityName = 'Kochi';
  List<dynamic>? dailyForecasts;

  Future<void> fetchWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city,IN&appid=$apiKey&units=metric'),
      );
      if (response.statusCode == 200) {
        final forecastList = json.decode(response.body)['list'];

        // Filter the data for one forecast per day at 12:00 PM
        final filteredForecasts = forecastList.where((item) {
          final dateTime = DateTime.parse(item['dt_txt']);
          return dateTime.hour == 12; // Filter forecasts at 12:00 PM
        }).toList();

        setState(() {
          dailyForecasts = filteredForecasts;
        });
      } else {
        setState(() {
          dailyForecasts = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('City not found or invalid query.')),
        );
      }
    } catch (e) {
      setState(() {
        dailyForecasts = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(cityName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Day Weather Forecast'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  cityName = value;
                });
                fetchWeather(value);
              },
            ),
            const SizedBox(height: 20),
            dailyForecasts != null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: dailyForecasts!.length,
                      itemBuilder: (context, index) {
                        final item = dailyForecasts![index];
                        final dateTime = DateTime.parse(item['dt_txt']);
                        final temperature = item['main']['temp'];
                        final weatherDescription = item['weather'][0]['description'];
                        final weatherIcon = item['weather'][0]['icon'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Image.network(
                              'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
                              width: 50,
                              height: 50,
                            ),
                            title: Text(
                              '${dateTime.day}-${dateTime.month}-${dateTime.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Temp: $temperature°C'),
                                Text('Weather: $weatherDescription'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text(
                      'Enter a city to get weather details.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
