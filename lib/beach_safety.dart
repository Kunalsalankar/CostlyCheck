import 'package:flutter/material.dart';

class OceanScreen extends StatelessWidget {
  final String beachName;
  final double EWA; // Tsunami Alert
  final double SSH; // Storm Surge
  final double SWH; // High Wave Alert
  final double swellPeriod; // Swell Surge Period
  final double surgeHeight; // Swell Surge Height
  final double oceanCurrent; // Ocean Currents

  const OceanScreen({
    super.key,
    required this.beachName,
    required this.EWA,
    required this.SSH,
    required this.SWH,
    required this.swellPeriod,
    required this.surgeHeight,
    required this.oceanCurrent,
  });

  // Function to determine safety status
  String checkBeachSafety() {
    if (EWA > 2.0) {
      return "Unsafe: Tsunami Warning";
    } else if (SSH > 2.0) {
      return "Unsafe: Storm Surge Alert";
    } else if (SWH > 3.5) {
      return "Unsafe: High Wave Alert";
    } else if (swellPeriod > 18 && surgeHeight > 2.5) {
      return "Unsafe: Swell Surge Warning";
    } else if (oceanCurrent > 2.0) {
      return "Unsafe: Strong Ocean Currents";
    } else if (EWA >= 0.5 && EWA <= 2.0) {
      return "Alert: Tsunami Alert";
    } else if (SSH >= 0.5 && SSH <= 2.0) {
      return "Alert: Storm Surge Alert";
    } else if (SWH >= 3.0 && SWH <= 3.5) {
      return "Alert: High Wave Alert";
    } else if (swellPeriod >= 15 && swellPeriod <= 18 && surgeHeight > 1.5) {
      return "Alert: Swell Surge Alert";
    } else if (oceanCurrent >= 1.0 && oceanCurrent <= 2.0) {
      return "Alert: Moderate Ocean Currents";
    } else if (EWA >= 0.2 && EWA < 0.5) {
      return "Watch: Tsunami Watch";
    } else if (SSH >= 0.2 && SSH < 0.5) {
      return "Watch: Storm Surge Watch";
    } else if (SWH >= 2.0 && SWH < 3.0) {
      return "Watch: Moderate Wave Activity";
    } else if (swellPeriod >= 12 && swellPeriod < 15 && surgeHeight >= 1.0 && surgeHeight <= 1.5) {
      return "Watch: Swell Surge Watch";
    } else if (oceanCurrent >= 0.5 && oceanCurrent < 1.0) {
      return "Watch: Weak Ocean Currents";
    } else {
      return "Safe: No Immediate Danger Detected";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background color based on the safety status
    String safetyStatus = checkBeachSafety();
    Color statusColor;

    if (safetyStatus.contains("Unsafe")) {
      statusColor = Colors.red; // Unsafe - Red
    } else if (safetyStatus.contains("Alert")) {
      statusColor = Colors.orange; // Alert - Orange
    } else if (safetyStatus.contains("Watch")) {
      statusColor = Colors.yellow; // Watch - Yellow
    } else {
      statusColor = Colors.green; // Safe - Green
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Safety Status'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the Beach Name
            Text(
              beachName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Display the Safety Status with the appropriate color
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
          ],
        ),
      ),
    );
  }
}
