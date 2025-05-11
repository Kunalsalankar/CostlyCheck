import 'dart:ffi';

import 'package:final_project/UserReviewsPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'ActivityScreen.dart';
import 'transportation.dart';
import 'Map.dart';

class BeachDetailPage extends StatefulWidget {
  final Map<String, dynamic> beach;
  final double? distance;
  final double? latitude;
  final double? longitude;

  const BeachDetailPage(
      {super.key,
      required this.beach,
      this.distance,
      this.latitude,
      this.longitude});

  @override
  _BeachDetailPageState createState() => _BeachDetailPageState();
}

class _BeachDetailPageState extends State<BeachDetailPage> {
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? hourlyWeatherData;
  Map<String, dynamic>? openWeatherData;
  List<Map<String, dynamic>>? dailyForecast;
  bool isLoading = true;
  String? errorMessage;
  final String openWeatherApiKey = '380f110a19b8728fdc159ab69547cbc0';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        fetchWeatherData(),
        fetchOpenWeatherData(),
      ]);
      _processDailyForecast();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error initializing data: $e");
      if (mounted) {
        setState(() {
          errorMessage = "Unable to load weather data";
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchOpenWeatherData() async {
    if (!mounted) return;

    try {
      final coordinates = widget.beach['coordinates'] as List;
      final latitude = coordinates[0];
      final longitude = coordinates[1];

      final openWeatherUrl =
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$openWeatherApiKey';

      final response = await http.get(Uri.parse(openWeatherUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          openWeatherData = json.decode(response.body);
          isLoading = false;
          errorMessage = null;
        });
      } else {
        throw Exception('Failed to load OpenWeather data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error loading OpenWeather data: ${e.toString()}";
          isLoading = false;
        });
      }
      print("Error fetching OpenWeather data: $e");
    }
  }

  void _processDailyForecast() {
    if (openWeatherData == null || !mounted) return;

    try {
      final List<dynamic> hourlyList = openWeatherData!['list'];
      Map<String, Map<String, dynamic>> dailyMap = {};

      for (var hourlyData in hourlyList) {
        final DateTime date = DateTime.parse(hourlyData['dt_txt']);
        final String dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!dailyMap.containsKey(dateKey)) {
          dailyMap[dateKey] = {
            'date': date,
            'minTemp': double.infinity,
            'maxTemp': double.negativeInfinity,
            'weatherId': hourlyData['weather'][0]['id'],
            'description': hourlyData['weather'][0]['description'],
            'icon': hourlyData['weather'][0]['icon'],
            'humidity': hourlyData['main']['humidity'],
            'windSpeed': hourlyData['wind']['speed'],
          };
        }

        // Safely convert temperature to double
        final dynamic tempValue = hourlyData['main']['temp'];
        final double temp =
            tempValue is int ? tempValue.toDouble() : tempValue as double;

        dailyMap[dateKey]!['minTemp'] = math.min(
          dailyMap[dateKey]!['minTemp'] as double,
          temp,
        );
        dailyMap[dateKey]!['maxTemp'] = math.max(
          dailyMap[dateKey]!['maxTemp'] as double,
          temp,
        );
      }

      setState(() {
        dailyForecast = dailyMap.values.toList();
      });
    } catch (e) {
      print("Error processing daily forecast: $e");
    }
  }

  Future<void> fetchWeatherData() async {
    if (!mounted) return;

    try {
      final coordinates = widget.beach['coordinates'] as List;
      final latitude = coordinates[0];
      final longitude = coordinates[1];

      final currentWeatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
      final hourlyWeatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,precipitation,windspeed_10m,relative_humidity_2m';

      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));
      final hourlyResponse = await http.get(Uri.parse(hourlyWeatherUrl));

      if (!mounted) return;

      if (currentResponse.statusCode == 200 &&
          hourlyResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final hourlyData = json.decode(hourlyResponse.body);

        if (currentData['current_weather'] == null) {
          throw Exception('Invalid current weather data structure');
        }

        setState(() {
          currentWeatherData = currentData['current_weather'];
          hourlyWeatherData = hourlyData['hourly'];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error loading weather data: ${e.toString()}";
          isLoading = false;
        });
      }
      print("Error fetching weather data: $e");
    }
  }

  Map<String, dynamic> getBeachSafetyStatus() {
    if (currentWeatherData == null || openWeatherData == null) {
      return {
        'status': 'Unknown',
        'message': 'Weather data unavailable',
        'color': Colors.grey,
        'icon': Icons.question_mark
      };
    }

    // Extract weather parameters
    final temperature = currentWeatherData!['temperature'] as double;
    final windSpeed = currentWeatherData!['windspeed'] as double;
    final precipitation =
        hourlyWeatherData?['precipitation'][0] as double? ?? 0.0;
    final openWeatherMain = openWeatherData!['list'][0]['main'];
    final humidity = openWeatherMain['humidity'] as int;

    // Safety evaluation based on each parameter
    // Temperature safety
    String tempSafety = 'safe';
    if ((temperature >= 24 && temperature <= 30)) {
      tempSafety = 'safe';
    } else if ((temperature >= 20 && temperature <= 23) ||
        (temperature >= 31 && temperature <= 33)) {
      tempSafety = 'moderate';
    } else if ((temperature >= 18 && temperature <= 19) ||
        (temperature >= 34 && temperature <= 35)) {
      tempSafety = 'cautious';
    } else if (temperature < 18 || temperature > 35) {
      tempSafety = 'unsafe';
    }

    // Wind speed safety
    String windSafety = 'safe';
    if (windSpeed <= 15) {
      windSafety = 'safe';
    } else if (windSpeed > 15 && windSpeed <= 30) {
      windSafety = 'moderate';
    } else if (windSpeed > 30 && windSpeed <= 50) {
      windSafety = 'cautious';
    } else if (windSpeed > 50) {
      windSafety = 'unsafe';
    }

    // Precipitation safety
    String precipSafety = 'safe';
    if (precipitation <= 1.0) {
      precipSafety = 'safe';
    } else if (precipitation > 1.0 && precipitation <= 2.5) {
      precipSafety = 'moderate';
    } else if (precipitation > 2.5 && precipitation <= 5.0) {
      precipSafety = 'cautious';
    } else if (precipitation > 5.0) {
      precipSafety = 'unsafe';
    }

    // Humidity safety
    String humiditySafety = 'safe';
    if (humidity >= 40 && humidity <= 60) {
      humiditySafety = 'safe';
    } else if (humidity > 60 && humidity <= 75) {
      humiditySafety = 'moderate';
    } else if (humidity > 75 && humidity <= 85) {
      humiditySafety = 'cautious';
    } else if (humidity > 85 || humidity < 40) {
      humiditySafety = 'unsafe';
    }

    // Determine overall safety rating (using the worst rating)
    List<String> allSafetyRatings = [
      tempSafety,
      windSafety,
      precipSafety,
      humiditySafety
    ];
    String overallSafety = 'safe';

    if (allSafetyRatings.contains('unsafe')) {
      overallSafety = 'unsafe';
    } else if (allSafetyRatings.contains('cautious')) {
      overallSafety = 'cautious';
    } else if (allSafetyRatings.contains('moderate')) {
      overallSafety = 'moderate';
    }

    // Create safety messages based on which parameters are problematic
    List<String> issues = [];
    if (tempSafety != 'safe')
      issues.add('temperature (${temperature.toStringAsFixed(1)}°C)');
    if (windSafety != 'safe')
      issues.add('wind speed (${windSpeed.toStringAsFixed(1)} km/h)');
    if (precipSafety != 'safe')
      issues.add('precipitation (${precipitation.toStringAsFixed(1)} mm/hr)');
    if (humiditySafety != 'safe') issues.add('humidity ($humidity%)');

    String message = '';
    if (overallSafety == 'safe') {
      message = 'Beach conditions are ideal for visiting';
    } else {
      message = 'Exercise caution due to: ${issues.join(", ")}';
    }

    // Map safety status to colors and icons
    Map<String, dynamic> statusMap = {
      'safe': {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'status': 'Safe',
      },
      'moderate': {
        'color': Colors.yellow.shade700,
        'icon': Icons.info_outline,
        'status': 'Moderately Safe',
      },
      'cautious': {
        'color': Colors.orange,
        'icon': Icons.warning_amber,
        'status': 'Cautious',
      },
      'unsafe': {
        'color': Colors.red,
        'icon': Icons.warning,
        'status': 'Unsafe',
      }
    };

    return {
      'status': statusMap[overallSafety]['status'],
      'message': message,
      'color': statusMap[overallSafety]['color'],
      'icon': statusMap[overallSafety]['icon'],
      'details': {
        'temperature': {
          'value': temperature,
          'safety': tempSafety,
        },
        'windSpeed': {
          'value': windSpeed,
          'safety': windSafety,
        },
        'precipitation': {
          'value': precipitation,
          'safety': precipSafety,
        },
        'humidity': {
          'value': humidity,
          'safety': humiditySafety,
        }
      }
    };
  }

  Widget _buildWeatherCard() {
    if (currentWeatherData == null || openWeatherData == null) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text("Weather data unavailable"),
          ),
        ),
      );
    }

    final temperature = currentWeatherData!['temperature'] as double;
    final windSpeed = currentWeatherData!['windspeed'] as double;
    final precipitation =
        hourlyWeatherData?['precipitation'][0] as double? ?? 0.0;

    final openWeatherMain = openWeatherData!['list'][0]['main'];
    final humidity = openWeatherMain['humidity'] as int;
    // Not using this variable anymore, so you can comment or remove it
    // final weatherDescription = openWeatherData!['list'][0]['weather'][0]['description'];
    final weatherIcon = openWeatherData!['list'][0]['weather'][0]['icon'];

    final safetyStatus = getBeachSafetyStatus();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modified this Row to remove the weather description Container
            const Text(
              "Current Weather",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${temperature.toStringAsFixed(1)}°C ",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.air, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${windSpeed.toStringAsFixed(1)} km/h",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.water_drop,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${precipitation.toStringAsFixed(1)} mm/hr",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.opacity, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Humidity: $humidity%",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: safetyStatus['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: safetyStatus['color'],
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    safetyStatus['icon'],
                    color: safetyStatus['color'],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    safetyStatus['status'],
                    style: TextStyle(
                      color: safetyStatus['color'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    safetyStatus['message'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: safetyStatus['color'],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (openWeatherData == null) {
      return const SizedBox.shrink();
    }

    final hourlyForecasts = openWeatherData!['list'] as List;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hourly Forecast",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: math.min(8, hourlyForecasts.length),
                itemBuilder: (context, index) {
                  final forecast = hourlyForecasts[index];
                  final temp = forecast['main']['temp'];
                  final double tempDouble =
                      temp is int ? temp.toDouble() : temp as double;
                  final weather = forecast['weather'][0];
                  final icon = weather['icon'];
                  final description = weather['description'];
                  final time = DateTime.parse(forecast['dt_txt']);

                  // Format time as 15:00 instead of 15:00
                  final String formattedTime =
                      '${time.hour.toString().padLeft(2, '0')}:00';

                  // Generate a color based on the time of day
                  final Color timeColor = _getTimeBasedColor(time.hour);
                  final Color tempColor = _getTemperatureColor(tempDouble);

                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            timeColor.withOpacity(0.15),
                            timeColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: timeColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: timeColor.withOpacity(0.8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: timeColor.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]),
                          child: Image.network(
                            "https://openweathermap.org/img/wn/$icon@2x.png",
                            width: 38,
                            height: 38,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _getWeatherIcon(description),
                                size: 38,
                                color: _getWeatherIconBackground(description),
                              );
                            },
                          ),
                        ),
                        Text(
                          '${tempDouble.round()}°',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: tempColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimeBasedColor(int hour) {
    if (hour >= 5 && hour < 10) {
      return Colors.orange.shade700; // Morning
    } else if (hour >= 10 && hour < 16) {
      return Colors.blue.shade500; // Day
    } else if (hour >= 16 && hour < 20) {
      return Colors.amber.shade600; // Evening
    } else {
      return Colors.indigo.shade600; // Night
    }
  }

  Color _getTemperatureColor(double temp) {
    if (temp >= 30) {
      return Colors.deepOrange.shade700;
    } else if (temp >= 25) {
      return Colors.orange.shade600;
    } else if (temp >= 20) {
      return Colors.amber.shade600;
    } else if (temp >= 15) {
      return Colors.green.shade600;
    } else if (temp >= 10) {
      return Colors.cyan.shade600;
    } else {
      return Colors.blue.shade600;
    }
  }

  Color _getWeatherIconBackground(String description) {
    description = description.toLowerCase();
    if (description.contains('cloud')) {
      return Colors.blueGrey.shade400;
    } else if (description.contains('rain') ||
        description.contains('drizzle')) {
      return Colors.lightBlue.shade400;
    } else if (description.contains('thunder')) {
      return Colors.deepPurple.shade400;
    } else if (description.contains('snow')) {
      return Colors.cyan.shade400;
    } else if (description.contains('clear')) {
      return Colors.amber.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }

  IconData _getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('cloud')) {
      return Icons.cloud;
    } else if (description.contains('rain') ||
        description.contains('drizzle')) {
      return Icons.grain;
    } else if (description.contains('thunder')) {
      return Icons.flash_on;
    } else if (description.contains('snow')) {
      return Icons.ac_unit;
    } else if (description.contains('clear')) {
      return Icons.wb_sunny;
    } else {
      return Icons.cloud;
    }
  }

  Widget _build5DayForecast() {
    if (dailyForecast == null || dailyForecast!.isEmpty) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "5-Day Forecast",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...dailyForecast!.take(5).map((day) {
              final date = day['date'] as DateTime;
              final minTemp = day['minTemp'] as double;
              final maxTemp = day['maxTemp'] as double;
              final description = day['description'] as String;
              final iconCode = day['icon'] as String;
              final backgroundColor = _getWeatherIconBackground(description);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Colors.blue.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        DateFormat('E, MMM d').format(date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: backgroundColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: backgroundColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Image.network(
                        "https://openweathermap.org/img/wn/$iconCode.png",
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.cloud,
                            size: 40,
                            color: backgroundColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: TextStyle(
                              color: backgroundColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${minTemp.round()}°',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${maxTemp.round()}°',
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          "User Activity",
          Icons.local_activity_sharp,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityScreen(
                beachName: widget.beach['name'],
              ),
            ),
          ),
        ),
        _buildActionButton(
          "User Feedback",
          Icons.read_more,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserReviewsPage(beach: widget.beach),
            ),
          ),
        ),
        _buildActionButton(
          "View on Map",
          Icons.map,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                selectedBeach: widget.beach,
                allBeaches: [],
              ),
            ),
          ),
        ),
        _buildActionButton(
          "Transportation Services",
          Icons.directions_car,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransportationScreen(
                beachName: widget.beach['name'],
                beachData: widget.beach,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeachImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: Image.asset(
          widget.beach['image'] ?? 'assets/files/placeholder.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBeachInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.beach['name'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.beach['location'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.beach['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeachContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBeachImage(),
          _buildBeachInfo(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeatherCard(),
                const SizedBox(height: 16),
                _buildHourlyForecast(),
                const SizedBox(height: 16),
                _build5DayForecast(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _initializeData();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : _buildBeachContent(),
    );
  }
}
