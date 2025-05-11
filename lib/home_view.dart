import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:final_project/Notification_Screen.dart';

import 'kochi.dart';
import 'WeatherForecastScreen.dart';
import 'profile_screen.dart';
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<Map<String, dynamic>> beaches = [
    {
      'name': 'Kochi',
      'location': 'Kochi, Kerala',
      'image': 'assets/images/kochi.png',
      'description': 'A serene beach known for its pristine waters and fishing activities.',
      'coordinates': [9.9672, 76.2444],
      'activities': ['Fishing', 'Sunset viewing', 'Photography'],
      'routeName': 'kochi'
    },
  ];

  List<Map<String, dynamic>> filteredBeaches = [];
  String searchQuery = '';

  // Weather and Location Variables
  double temperature = 0.0;
  bool _isLocationLoading = true;
  String? _locationError;

  // Bottom Navigation
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    filteredBeaches = beaches;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions permanently denied.';
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      fetchWeatherData(currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void fetchWeatherData(double lat, double lon) async {
    const apiKey = '22c04e1c06f9c21c365e704b6ce8fec5';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['main']['temp'];
        });
      } else {
        setState(() {
          temperature = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        temperature = 0.0;
      });
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredBeaches = beaches.where((beach) {
        final name = beach['name']?.toString().toLowerCase() ?? '';
        final location = beach['location']?.toString().toLowerCase() ?? '';
        return name.contains(searchQuery) || location.contains(searchQuery);
      }).toList();
    });
  }

  void navigateToBeachPage(BuildContext context, Map<String, dynamic> beach) {
    final routeName = beach['routeName']?.toString().toLowerCase() ?? '';

    switch (routeName) {
      case 'kochi':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KochiBeachesPage()),
        );

    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Home - already here
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WeatherForecastScreen()),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/img_32.png',
                            fit: BoxFit.cover,
                          ),
                        ),

                        Center(
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              double logoSize = 100; // Default logo size

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        height: 60,
                                        width: logoSize,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Slider(
                                    value: logoSize,
                                    min: 50,
                                    max: 200,
                                    onChanged: (value) {
                                      setState(() {
                                        logoSize = value;
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        Positioned(
                          top: 20,
                          left: 16,
                          child: _isLocationLoading
                              ? CircularProgressIndicator()
                              : _locationError != null
                              ? Text(_locationError!, style: TextStyle(color: Colors.white))
                              : Text(
                            '${temperature.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for a city...',
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              onChanged: updateSearchQuery,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: filteredBeaches.isEmpty
                  ? SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No beaches found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final beach = filteredBeaches[index];
                    return BeachCard(
                      beach: beach,
                      onTap: () => navigateToBeachPage(context, beach),
                    );
                  },
                  childCount: filteredBeaches.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'City Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class BeachCard extends StatelessWidget {
  final Map<String, dynamic> beach;
  final VoidCallback onTap;

  const BeachCard({super.key, required this.beach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.asset(
                beach['image'] ?? 'assets/images/logo.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beach['name'] ?? 'Unnamed Beach',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        beach['location'] ?? 'Unknown Location',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    beach['description'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}