import 'package:flutter/material.dart';
import 'BeachDetailPage.dart'; // Import the BeachDetailPage
import 'AlertScreen.dart';
import 'Search_Screen.dart';
import 'CustomAppBar.dart';
import 'CustomDrawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> beaches = [
    {
      'name': 'Cherai Beach, Kochi',
      'image': 'assets/images/cherai-Beach-01.jpg',
      'facilities': ['Restrooms', 'Parking', 'Food Stalls', 'Boat Rides'],
      'coordinates': [10.0150, 76.2540], // Sample coordinates
    },
    {
      'name': 'Fort Kochi Beach, Kochi',
      'image': 'assets/images/fort_kochi_beach.jpg',
      'facilities': ['Restrooms', 'Parking', 'Food Stalls', 'Shops'],
      'coordinates': [9.9658, 76.2219], // Sample coordinates
    },
    {
      'name': 'Ramakrishna Beach, Vizag',
      'image': 'assets/images/ramkrsihna_beach.jpg',
      'facilities': ['Restrooms', 'Parking', 'Food Stalls', 'Lifeguards'],
      'coordinates': [17.7082, 83.2927], // Sample coordinates
    },
    {
      'name': 'Munambam Beach,Kochi',
      'image': 'assets/images/munambam.jpg',
      'facilities': ['Restrooms', 'Parking', 'Food Stalls', 'Lifeguards'],
      'coordinates': [10.1866, 76.1700], // Sample coordinates
    },
    {
      'name': 'Kuzhupilly Beach,Kochi',
      'image': 'assets/images/Kuzhupilly.jpg',
      'facilities': ['Restrooms', 'Parking', 'Food Stalls', 'Lifeguards'],
      'coordinates': [10.1055, 76.1849], // Sample coordinates
    },
    {
      'name': 'Puthuvype Beach,Kochi',
      'image': 'assets/images/Puthuvype.jpg',
      'facilities': ['Restrooms', 'Parking', 'Food Stalls', 'Lifeguards'],
      'coordinates': [10.0069, 76.2144], // Sample coordinates
    },
    // Add other beaches here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home Screen'),  // Use the CustomAppBar
      drawer: CustomDrawer(beaches: beaches),  // Use the CustomDrawer
      body: Container(
        color: const Color.fromARGB(255, 252, 254, 255), // Set the background color for the HomeScreen
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onTap: () {
                  // Navigate to SearchScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
              ),
            ),
            // Display the beach images and names vertically
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: beaches.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to BeachDetailPage with the selected beach data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BeachDetailPage(beach: beaches[index]),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            beaches[index]['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200.0, // Adjust height as needed
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              beaches[index]['name'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Alert Location Button at the bottom with custom color
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 149, 209, 244), // Change the color to your preferred one
                ),
                onPressed: () {
                  // Navigate to AlertScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AlertScreen()),
                  );
                },
                child: const Text(
                  'Check Alert Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Bold the font
                    fontSize: 18.0, // Increase font size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
