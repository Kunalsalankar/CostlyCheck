import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String condition;
  final double temperature;
  final String iconUrl;
  final double humidity;
  final double windSpeed;
  final double pressure;

  const WeatherCard({
    super.key,
    required this.condition,
    required this.temperature,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  iconUrl,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 10),
                Text(
                  '$temperature°C',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  condition,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Humidity: ${humidity.toStringAsFixed(1)}%'),
                    Text('Wind Speed: ${windSpeed.toStringAsFixed(1)} m/s'),
                    Text('Pressure: ${pressure.toStringAsFixed(1)} hPa'),
                  ],
                ),
                const Column(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
                    Text('Weather Icon'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
