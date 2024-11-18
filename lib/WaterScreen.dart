import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaterParameter {
  final String name;
  final double min;
  final double max;
  final String unit;

  WaterParameter(this.name, this.min, this.max, this.unit);

  bool isSafe(double value) {
    return value >= min && value <= max;
  }
}

class WaterScreen extends StatefulWidget {
  final String beachName;

  const WaterScreen({super.key, required this.beachName});

  @override
  _WaterScreenState createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final List<WaterParameter> parameters = [
    WaterParameter('currentspeed', 0, 1.5, 'm/s'),
    WaterParameter('pH', 7.4, 8.3, ''),
    WaterParameter('salinity', 25, 38, 'psu'),
    WaterParameter('temperature', 23, 32, '°C'),
    WaterParameter('dissolvedoxygen', 1.5, 5, 'mg/l'),
    WaterParameter('dissolvedmethane', 0.0001, 3, 'µg/l'),
    WaterParameter('pCO2 air', 350, 450, 'µatm'),
    WaterParameter('pCO2 water', 200, 700, 'µatm'),
    WaterParameter('chlorophyll', 0.0001, 10, 'µg/l'),
    WaterParameter('phycocyanin', 0.0001, 50, 'µg/l'),
    WaterParameter('phycoerythrin', 0.0001, 50, 'µg/l'),
    WaterParameter('turbidity', 0.0001, 50, 'NTU'),
    WaterParameter('scattering', 0.0001, 10, 'NTU'),
    WaterParameter('cdom', 0.0001, 2, 'mg/l'),
  ];

  Map<String, double> currentValues = {};
  Map<String, String> observationTimes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWaterData();
  }

  Future<void> fetchWaterData() async {
    setState(() {
      isLoading = true;
    });

    final stationName = widget.beachName.split(',').last.trim().toLowerCase();

    try {
      final fetchedValues = <String, double>{};
      final fetchedTimes = <String, String>{};

      for (var parameter in parameters) {
        final url = Uri.parse(
            'https://gemini.incois.gov.in/OceanDataAPI/api/wqns/$stationName/${parameter.name}');
        final response = await http.get(url, headers: {
          'Authorization': '446d183e64e64e8eb4bca1407ab02a89', // Replace with actual API key
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['observationTime'] != null &&
              data[parameter.name] != null &&
              data['observationTime'] is List &&
              data[parameter.name] is List &&
              data['observationTime'].isNotEmpty &&
              data[parameter.name].isNotEmpty) {
            fetchedTimes[parameter.name] = data['observationTime'][0];

            final rawValue = data[parameter.name][0];
            if (rawValue is String) {
              fetchedValues[parameter.name] = double.parse(rawValue);
            } else if (rawValue is num) {
              fetchedValues[parameter.name] = rawValue.toDouble();
            }
          }
        }
      }

      setState(() {
        currentValues = fetchedValues;
        observationTimes = fetchedTimes;
        isLoading = false;
      });
    } catch (e) {
      if(mounted){
        setState(() {
        isLoading = false;
      });}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Water Quality: ${widget.beachName}'),
          backgroundColor: Colors.teal,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Critical parameters
    final criticalParameters = ['temperature', 'salinity', 'pH', 'currentspeed', 'dissolvedoxygen'];
    bool isAnyCriticalUnsafe = criticalParameters.any((param) {
      final value = currentValues[param];
      final parameter = parameters.firstWhere((p) => p.name == param);
      return value != null && !parameter.isSafe(value);
    });

    // Count safe parameters
    int safeCount = parameters.where((param) {
      final value = currentValues[param.name];
      return value != null && param.isSafe(value);
    }).length;

    String statusMessage;
    Color statusColor;

    if (isAnyCriticalUnsafe) {
      statusMessage = "Unsafe to Visit the Beach";
      statusColor = Colors.red;
    } else if (safeCount >= parameters.length / 2) {
      statusMessage = "You can visit the beach";
      statusColor = Colors.green;
    } else {
      statusMessage = "Unsafe to Visit the Beach";
      statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Water Quality: ${widget.beachName}'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: parameters.length,
              itemBuilder: (context, index) {
                final parameter = parameters[index];
                final value = currentValues[parameter.name];
                final time = observationTimes[parameter.name];
                final isSafe = value != null && parameter.isSafe(value);
                final color = isSafe ? Colors.green : Colors.red;
                final icon = isSafe ? Icons.check_circle : Icons.warning;

                return Card(
                  color: color.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(icon, color: color, size: 30),
                    title: Text(
                      parameter.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (value != null)
                          Text('Value: ${value.toStringAsFixed(2)} ${parameter.unit}'),
                        if (time != null) Text('Observation Time: $time'),
                      ],
                    ),
                    trailing: Text(
                      isSafe ? 'Safe' : 'Unsafe',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: statusColor.withOpacity(0.1),
            child: Text(
              statusMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
