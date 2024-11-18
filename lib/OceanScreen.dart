import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'WaterScreen.dart';

class OceanScreen extends StatefulWidget {
  final String beachName;

  const OceanScreen({super.key, required this.beachName});

  @override
  _OceanScreenState createState() => _OceanScreenState();
}

class _OceanScreenState extends State<OceanScreen> {
  double EWA = 0.0;
  double SSH = 0.0;
  double SWH = 0.0;
  double swellPeriod = 0.0;
  double surgeHeight = 0.0;
  double oceanCurrent = 0.0;

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchOceanData();
  }

  Future<void> fetchOceanData() async {
    final tsunamiUrl = Uri.parse('https://gemini.incois.gov.in/incoisapi/rest/tsunami');
    final stormSurgeUrl = Uri.parse('https://gemini.incois.gov.in/incoisapi/rest/stormsurgelatest');
    final highWaveUrl = Uri.parse('https://gemini.incois.gov.in/incoisapi/rest/stormsurgelatest');
    final swellSurgeUrl = Uri.parse('https://gemini.incois.gov.in/incoisapi/rest/ssalatestgeo');
    final oceanCurrentUrl = Uri.parse('https://gemini.incois.gov.in/incoisapi/rest/currentslatestgeo');

    try {
      final responses = await Future.wait([
        http.get(tsunamiUrl, headers: {'Authorization': '446d183e64e64e8eb4bca1407ab02a89'}),
        http.get(stormSurgeUrl, headers: {'Authorization': '446d183e64e64e8eb4bca1407ab02a89'}),
        http.get(highWaveUrl, headers: {'Authorization': '446d183e64e64e8eb4bca1407ab02a89'}),
        http.get(swellSurgeUrl, headers: {'Authorization': '446d183e64e64e8eb4bca1407ab02a89'}),
        http.get(oceanCurrentUrl, headers: {'Authorization': '446d183e64e64e8eb4bca1407ab02a89'}),
      ]);

      if (responses.every((response) => response.statusCode == 200)) {
        final tsunamiData = json.decode(responses[0].body);
        final stormSurgeData = json.decode(responses[1].body);
        final highWaveData = json.decode(responses[2].body);
        final swellSurgeData = json.decode(responses[3].body);
        final oceanCurrentData = json.decode(responses[4].body);

        setState(() {
          EWA = tsunamiData['ewa'];
          SSH = stormSurgeData['ssh'];
          SWH = highWaveData['swh'];
          swellPeriod = swellSurgeData['swell_period'];
          surgeHeight = swellSurgeData['surge_height'];
          oceanCurrent = oceanCurrentData['ocean_current'];
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception('One or more API calls failed.');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Color coding for each parameter based on thresholds
  Color getParameterColor(String parameter) {
    switch (parameter) {
      case 'EWA':
        return EWA > 2.0 ? Colors.red : Colors.green;
      case 'SSH':
        return SSH > 2.0 ? Colors.red : Colors.green;
      case 'SWH':
        return SWH > 3.5 ? Colors.red : Colors.green;
      case 'Swell Surge':
        return (swellPeriod > 18 && surgeHeight > 2.5) ? Colors.red : Colors.green;
      case 'Ocean Current':
        return oceanCurrent > 2.0 ? Colors.red : Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Safety check function
  String checkBeachSafety() {
    if (EWA > 2.0) return "Unsafe: Tsunami Warning";
    if (SSH > 2.0) return "Unsafe: Storm Surge Alert";
    if (SWH > 3.5) return "Unsafe: High Wave Alert";
    if (swellPeriod > 18 && surgeHeight > 2.5) return "Unsafe: Swell Surge Warning";
    if (oceanCurrent > 2.0) return "Unsafe: Strong Ocean Currents";
    return "Safe: No Immediate Danger Detected";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beach Safety Status'), backgroundColor: Colors.teal),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beach Safety Status'), backgroundColor: Colors.teal),
        body: const Center(
          child: Text(
            'Failed to load data. Please try again later.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    String safetyStatus = checkBeachSafety();
    Color statusColor = safetyStatus.contains("Unsafe") ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Safety Status'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.beachName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                safetyStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            buildParameterRow("Tsunami Warning (EWA)", EWA.toString(), getParameterColor("EWA")),
            buildParameterRow("Storm Surge (SSH)", SSH.toString(), getParameterColor("SSH")),
            buildParameterRow("High Wave Alert (SWH)", SWH.toString(), getParameterColor("SWH")),
            buildParameterRow("Swell Surge", "$swellPeriod s / $surgeHeight m", getParameterColor("Swell Surge")),
            buildParameterRow("Ocean Current", oceanCurrent.toString(), getParameterColor("Ocean Current")),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WaterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Check Water Quality",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build color-coded rows for each parameter
  Widget buildParameterRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
