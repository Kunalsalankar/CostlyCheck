import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class HeatmapSettings {
  List<HeatmapLayer> layers;
  double maxRadius;
  double minOpacity;
  double maxOpacity;

  HeatmapSettings({
    required this.layers,
    this.maxRadius = 10000,
    this.minOpacity = 0.0, // Reduced minimum opacity
    this.maxOpacity = 0.15, // Reduced maximum opacity
  }) {
    // Ensure opacity values are valid
    minOpacity = minOpacity.clamp(0.0, 1.0);
    maxOpacity = maxOpacity.clamp(minOpacity, 1.0);
  }

  factory HeatmapSettings.defaultSettings() {
    return HeatmapSettings(
      layers: List.generate(5, (index) {
        final progress = (index + 1) / 5;
        return HeatmapLayer(
          radius: 10000 * (1 - progress * 0.4),
          opacity: 0.0 + (0.15 * progress), // Modified opacity range
        );
      }),
    );
  }
}

class HeatmapLayer {
  double radius;
  double opacity;
  HeatmapLayer({
    required this.radius,
    required this.opacity,
  });
}
class Beach {
  final String name;
  final String location;
  final List<double> coordinates;
  double? temperature;
  bool isSelected;
  Beach({
    required this.name,
    required this.location,
    required this.coordinates,
    this.temperature,
    this.isSelected = false,
  });
}
class PointOfInterest {
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String description;
  final double? rating;
  final double distance;
  final Map<String, dynamic>? additionalInfo;

  PointOfInterest({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.rating,
    required this.distance,
    this.additionalInfo,
  });
}

class MapPage extends StatefulWidget {
  final Map<String, dynamic> selectedBeach;
  final List<Map<String, dynamic>> allBeaches;
  const MapPage({
    Key? key,
    required this.selectedBeach,
    required this.allBeaches,
  }) : super(key: key);
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final double kochilat = 9.9373;
  final double kochilong = 76.2619;
  final MapController _mapController = MapController();
  bool isLoading = true;
  double? kochiTemperature;
  Beach? selectedLocation; // Track which location is selected for heatmap

  // Declare the missing variables
  List<Beach> beaches = [];
  List<dynamic> coastalCurrentAlerts = [];

  Beach? selectedBeach;
  bool showHeatmapSettings = false;

  HeatmapSettings heatmapSettings = HeatmapSettings.defaultSettings();

  Set<String> selectedFilters = {
    'beach',
    'restaurant',
    'hotel',
    'tourist_place'
  };

  List<PointOfInterest> pointsOfInterest = [];

  void _showCoordinatesDialog(Beach beach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${beach.name} Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${beach.coordinates[0]}'),
            Text('Longitude: ${beach.coordinates[1]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    beaches = widget.allBeaches.map((beachData) {
      return Beach(
        name: beachData['name'],
        location: beachData['location'],
        coordinates: List<double>.from(beachData['coordinates']),
      );
    }).toList();
    _fetchCoastalCurrentAlerts()// Fetch coastal current alerts on init
;

    // Initialize beaches with your coordinates
    beaches = [
      Beach(
        name: 'Munambam Beach',
        location: 'Munambam ',
        coordinates: [10.177251950103422, 76.16550196656354 ],
      ),
      Beach(
        name: 'Fort Kochi Beach',
        location: 'Fort Kochi',
        coordinates: [9.963959530419027, 76.2373541358738],
      ),
      Beach(
        name: 'Cherai Beach',
        location: 'Cherai',
        coordinates: [10.142459345097684, 76.1783140190165],
      ),
      Beach(
        name: 'Kuzhupilly Beach',
        location: 'Kuzhupilly',
        coordinates: [10.110531447381613, 76.18730486611027],
      ),
      Beach(
        name: 'Andhakaranazhi Beach',
        location: 'Andhakaranazhi',
        coordinates: [9.748780245066841, 76.28423445703498],
      ),
      Beach(
        name: 'Rushikonda Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.782743599368896, 83.38513003471017],
      ),
      Beach(
        name: 'Bheemili Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.890727074303157, 83.45569896851545],
      ),
      Beach(
        name: 'Lawson\'s Bay Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.741957898508407, 83.34485192635064],
      ),
      Beach(
        name: 'Sagar Nagar Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.76191354086149, 83.36042757623399],
      ),
      Beach(
        name: 'Marina Beach',
        location: 'Chennai, Tamil Nadu',
        coordinates: [13.051133780406854, 80.2824880520262],
      ),
      Beach(
        name: 'Elliot\'s Beach',
        location: 'Besant Nagar, Chennai, Tamil Nadu',
        coordinates: [12.999714796115375, 80.27221762587396],
      ),
      Beach(
        name: 'Mahabalipuram Beach',
        location: 'Mahabalipuram, Tamil Nadu',
        coordinates: [12.613145369117081, 80.19638628674777],
      ),
      Beach(
        name: 'Kanyakumari Beach',
        location: 'Kanyakumari, Tamil Nadu',
        coordinates: [8.086718507835178, 77.55441451695035],
      ),

    ];
    selectedLocation = beaches.firstWhere(
          (beach) => beach.name == widget.selectedBeach['name'],
      orElse: () => beaches.first,
    );

    // Mark the selected beach
    if (selectedLocation != null) {
      selectedLocation!.isSelected = true;
      selectedBeach = selectedLocation; // Set selectedBeach explicitly
    }
    _fetchTemperatures();
  }

  Future<void> _fetchCoastalCurrentAlerts() async {
    const String apiKey = '446d183e64e64e8eb4bca1407ab02a89';
    const String apiUrl = 'https://gemini.incois.gov.in/incoisapi/rest/currentslatestgeo';

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?apikey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          coastalCurrentAlerts = data['alerts']; // Assuming 'alerts' is the key for current alerts
        });
      } else {
        throw Exception('Failed to load coastal current alerts');
      }
    } catch (e) {
      debugPrint('Error fetching coastal current alerts: $e');
    }
  }
  Marker _buildBeachMarker(Beach beach) {
    return Marker(
      point: LatLng(beach.coordinates[0], beach.coordinates[1]),
      width: 100,
      height: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Deselect previous beach if any
            if (selectedBeach != null) {
              selectedBeach!.isSelected = false;
            }

            // Select new beach
            selectedBeach = beach;
            beach.isSelected = true;

            // Move map to selected beach
            _mapController.move(
              LatLng(beach.coordinates[0], beach.coordinates[1]),
              14,
            );

            // Fetch nearby places for selected beach
            _fetchNearbyPOIs();
          });
          _showBeachDetails(beach);
        },
        child: Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: beach.isSelected ? Colors.blue.shade700 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: beach.isSelected ? Colors.amber : Colors.blue,
                  width: beach.isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.beach_access,
                  color: beach.isSelected ? Colors.white : Colors.blue,
                  size: 32,
                ),
              ),
            ),
            if (beach.temperature != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getTemperatureColor(beach.temperature!),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${beach.temperature!.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // Heatmap building function
  List<CircleMarker> _buildHeatmapCircles() {
    if (selectedBeach?.temperature == null) return [];

    final baseColor = _getTemperatureColor(selectedBeach!.temperature!);
    final location = LatLng(
      selectedBeach!.coordinates[0],
      selectedBeach!.coordinates[1],
    );

    return heatmapSettings.layers.map((layer) {
      return CircleMarker(
        point: location,
        radius: layer.radius,
        useRadiusInMeter: true,
        color: baseColor.withOpacity(layer.opacity),
        borderColor: Colors.transparent,
        borderStrokeWidth: 0,
      );
    }).toList();
  }

  // Heatmap settings dialog
  void _showHeatmapSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Heatmap Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Maximum Radius (meters):'),
                Slider(
                  value: heatmapSettings.maxRadius,
                  min: 1000,
                  max: 10000,
                  divisions: 90,
                  label: '${heatmapSettings.maxRadius.round()}m',
                  onChanged: (value) {
                    setState(() {
                      heatmapSettings.maxRadius = value;
                      _updateHeatmapLayers();
                    });
                  },
                ),
                const Text('Opacity Range:'),
                RangeSlider(
                  values: RangeValues(
                    heatmapSettings.minOpacity.clamp(0.0, 1.0), // Add clamp
                    heatmapSettings.maxOpacity.clamp(0.0, 1.0), // Add clamp
                  ),
                  min: 0.0,  // Changed from 0.1 to 0.0
                  max: 1.0,
                  divisions: 100,  // Changed from 90 to 100 for more precise control
                  labels: RangeLabels(
                    heatmapSettings.minOpacity.toStringAsFixed(2),
                    heatmapSettings.maxOpacity.toStringAsFixed(2),
                  ),
                  onChanged: (values) {
                    setState(() {
                      // Ensure min opacity is not greater than max opacity
                      heatmapSettings.minOpacity = values.start.clamp(0.0, values.end);
                      heatmapSettings.maxOpacity = values.end;
                      _updateHeatmapLayers();
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Number of Layers:'),
                DropdownButton<int>(
                  value: heatmapSettings.layers.length,
                  items: List.generate(8, (index) => index + 2)
                      .map((count) => DropdownMenuItem(
                    value: count,
                    child: Text('$count layers'),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _updateLayerCount(value);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  heatmapSettings = HeatmapSettings.defaultSettings();
                });
              },
              child: const Text('Reset to Default'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Trigger a rebuild of the map
      this.setState(() {});
    });
  }
  void _updateHeatmapLayers() {
    final layerCount = heatmapSettings.layers.length;
    heatmapSettings.layers = List.generate(layerCount, (index) {
      final progress = (index + 1) / layerCount;
      return HeatmapLayer(
        radius: heatmapSettings.maxRadius * (1 - progress + 0.2),
        opacity: heatmapSettings.minOpacity +
            ((heatmapSettings.maxOpacity - heatmapSettings.minOpacity) *
                progress),
      );
    });
  }

  void _updateLayerCount(int count) {
    heatmapSettings.layers = List.generate(count, (index) {
      final progress = (index + 1) / count;
      return HeatmapLayer(
        radius: heatmapSettings.maxRadius * (1 - progress + 0.2),
        opacity: heatmapSettings.minOpacity +
            ((heatmapSettings.maxOpacity - heatmapSettings.minOpacity) *
                progress),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach & Nearby Places'),
        backgroundColor: Colors.blue, // Basic blue color
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showHeatmapSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchTemperatures();
              _fetchNearbyPOIs();
              _fetchCoastalCurrentAlerts(); // Refresh alerts
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      selectedLocation?.coordinates[0] ?? 9.9673, // Default to Fort Kochi
                      selectedLocation?.coordinates[1] ?? 76.2367,
                    ),
                    initialZoom: 12,
                    minZoom: 7,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      enableMultiFingerGestureRace: true,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      maxZoom: 19,
                    ),
                    CircleLayer<Object>(
                      circles: selectedFilters.contains('beach')
                          ? _buildHeatmapCircles()
                          : [],
                    ),
                    MarkerLayer(
                      markers: [
                        if (selectedFilters.contains('beach'))
                          ...beaches.map((beach) => _buildBeachMarker(beach)),
                        ...pointsOfInterest
                            .where((poi) => selectedFilters.contains(poi.type))
                            .map((poi) => _buildPoiMarker(poi)),
                      ],
                    ),
                  ],
            ),
              _buildCoastalCurrentAlerts(), // Display coastal current alerts
              if (isLoading)
        Container(
    color: Colors.black.withOpacity(0.3),
    child: const Center(
    child: CircularProgressIndicator(),
    ),
    ),

                _buildLegend(),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNearbyPlacesBottomSheet(),
        label: const Text('Show Nearby Places'),
        icon: const Icon(Icons.list),
      ),
    );
  }
  Widget _buildCoastalCurrentAlerts() {
    if (coastalCurrentAlerts.isEmpty) {
      return Container(); // Return empty if no alerts
    }

    return Positioned(
      right: 16,
      top: 80,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coastal Current Alerts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...coastalCurrentAlerts.map((alert) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(alert['description'] ?? 'No description available'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }


  // Helper methods for building markers

// Helper method for temperature color
  Color _getTemperatureColor(double temperature) {
    if (temperature >= 24 && temperature <= 30) {
      return Colors.lightGreen.shade600; // Darker green
    } else if ((temperature >= 20 && temperature < 24) ||
        (temperature > 30 && temperature <= 33)) {
      return Colors.yellow.shade600; // Darker yellow
    } else if ((temperature >= 18 && temperature < 20) ||
        (temperature > 33 && temperature <= 35)) {
      return Colors.orange.shade600; // Darker orange
    } else {
      return Colors.red.shade600; // Darker red
    }
  }

  Marker _buildPoiMarker(PointOfInterest poi) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: () => _showPoiDetails(poi),
        child: Container(
          decoration: BoxDecoration(
            color: _getPoiColor(poi.type).withOpacity(0.6), // More transparent background
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2), // Semi-transparent border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // More transparent shadow
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            _getPoiIcon(poi.type),
            color: Colors.white.withOpacity(0.9), // Slightly transparent icon
            size: 20,
          ),
        ),
      ),
    );
  }
  void _showBeachDetails(Beach beach) {
    if (beach == null) return; // Add early return if beach is null

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(beach.name ?? 'Unknown Beach'), // Add null check for name
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (beach.location != null) // Add null check for location
              Text('Location: ${beach.location}'),
            if (beach.coordinates != null &&
                beach.coordinates.length >= 2) // Add null check for coordinates
              Text(
                  'Latitude: ${beach.coordinates[0]}\nLongitude: ${beach.coordinates[1]}'),
            if (beach.temperature != null) // Add null check for temperature
              Text(
                'Temperature: ${beach.temperature!.toStringAsFixed(1)}°C',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNearbyPlacesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Places',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchNearbyPOIs();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pointsOfInterest.length,
                itemBuilder: (context, index) {
                  final poi = pointsOfInterest[index];
                  if (!selectedFilters.contains(poi.type)) {
                    return Container();
                  }
                  return _buildPoiListItem(poi, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPoiListItem(PointOfInterest poi, BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          _getPoiIcon(poi.type),
          color: _getPoiColor(poi.type),
        ),
        title: Text(poi.name),
        subtitle: Text(
          '${poi.distance.toStringAsFixed(1)} km away${poi.rating != null ? ' • ${poi.rating!.toStringAsFixed(1)} ⭐' : ''}',
        ),
        onTap: () {
          Navigator.pop(context);
          _mapController.move(
            LatLng(poi.latitude, poi.longitude),
            15,
          );
          _showPoiDetails(poi);
        },
      ),
    );
  }
  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  // Modify the POI fetching to only fetch for the selected beach
  Future<void> _fetchNearbyPOIs() async {
    if (selectedBeach == null) return;

    setState(() => isLoading = true);
    pointsOfInterest.clear();

    final types = {
      'restaurant': '[amenity=restaurant]',
      'hotel': '[tourism=hotel]',
      'tourist_place': '[tourism~"museum|attraction|viewpoint|artwork|gallery"]',
      'medical': '[amenity~"hospital|clinic|doctors|pharmacy"]',
    };

    for (var entry in types.entries) {
      if (!selectedFilters.contains(entry.key)) continue;

      try {
        final query = '''
        [out:json][timeout:25];
        (
          node${entry.value}(around:10000, ${selectedBeach!.coordinates[0]}, ${selectedBeach!.coordinates[1]});
          way${entry.value}(around:10000, ${selectedBeach!.coordinates[0]}, ${selectedBeach!.coordinates[1]});
        );
        out body;
        >;
        out skel qt;
      ''';

        final response = await http.post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          body: query,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final elements = data['elements'] as List;

          for (var element in elements) {
            if (element['type'] == 'node' || element['type'] == 'way') {
              final tags = element['tags'] ?? {};
              final lat = element['lat'] ?? element['center']?['lat'];
              final lon = element['lon'] ?? element['center']?['lon'];

              if (lat != null && lon != null) {
                final distance = _calculateDistance(
                  selectedBeach!.coordinates[0],
                  selectedBeach!.coordinates[1],
                  lat.toDouble(),
                  lon.toDouble(),
                );

                if (distance <= 10) { // Only show places within 2km
                  pointsOfInterest.add(
                    PointOfInterest(
                      name: tags['name'] ?? 'Unnamed ${entry.key}',
                      type: entry.key,
                      latitude: lat.toDouble(),
                      longitude: lon.toDouble(),
                      description: _generateDescription(tags),
                      rating: tags['rating']?.toDouble(),
                      distance: distance,
                      additionalInfo: tags,
                    ),
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching ${entry.key}s: $e');
      }
    }

    setState(() => isLoading = false);
  }
  Future<void> _fetchPOIsForBeach(Beach beach) async {
    final types = {
      'restaurant': '[amenity=restaurant]',
      'hotel': '[tourism=hotel]',
      'tourist_place': '[tourism~"museum|attraction|viewpoint|artwork|gallery"]',
      'medical': '[amenity~"hospital|clinic|doctors|pharmacy"]', // Added medical places
    };

    for (var entry in types.entries) {
      try {
        final query = '''
      [out:json][timeout:25];
      (
        node${entry.value}(around:10000, ${beach.coordinates[0]}, ${beach.coordinates[1]});
        way${entry.value}(around:10000, ${beach.coordinates[0]}, ${beach.coordinates[1]});
        relation${entry.value}(around:10000, ${beach.coordinates[0]}, ${beach.coordinates[1]});
      );
      out body;
      >;
      out skel qt;
      ''';

        final response = await http.post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          body: query,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final elements = data['elements'] as List;

          for (var element in elements) {
            if (element['type'] == 'node' || element['type'] == 'way') {
              final tags = element['tags'] ?? {};
              final lat = element['lat'] ?? element['center']['lat'];
              final lon = element['lon'] ?? element['center']['lon'];

              final distance = _calculateDistance(
                beach.coordinates[0],
                beach.coordinates[1],
                lat.toDouble(),
                lon.toDouble(),
              );

              if (distance <= 10) {
                pointsOfInterest.add(
                  PointOfInterest(
                    name: tags['name'] ?? 'Unnamed ${entry.key}',
                    type: entry.key,
                    latitude: lat.toDouble(),
                    longitude: lon.toDouble(),
                    description: _generateDescription(tags),
                    rating: tags['rating']?.toDouble(),
                    distance: distance,
                    additionalInfo: tags,
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching ${entry.key}s: $e');
      }
    }
  }
  String _generateDescription(Map<String, dynamic> tags) {
    List<String> details = [];

    if (tags['cuisine'] != null) {
      details.add('Cuisine: ${tags['cuisine']}');
    }
    if (tags['opening_hours'] != null) {
      details.add('Hours: ${tags['opening_hours']}');
    }
    if (tags['phone'] != null) {
      details.add('Phone: ${tags['phone']}');
    }
    if (tags['website'] != null) {
      details.add('Website: ${tags['website']}');
    }

    return details.isEmpty
        ? 'No additional information available'
        : details.join('\n');
  }

  Future<void> _fetchTemperatures() async {
    setState(() => isLoading = true);

    for (var beach in beaches) {
      try {
        final temperature = await _getTemperature(
          beach.coordinates[0],
          beach.coordinates[1],
        );
        setState(() {
          beach.temperature = temperature;
        });
      } catch (e) {
        debugPrint('Error fetching temperature for ${beach.name}: $e');
      }
    }

    setState(() => isLoading = false);
  }

  Future<double> _getTemperature(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['current_weather']['temperature'].toDouble();
    } else {
      throw Exception('Failed to load weather data');
    }
  }
  IconData _getPoiIcon(String type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'tourist_place':
        return Icons.photo_camera;
      case 'medical':
        return Icons.local_hospital;
      default:
        return Icons.place;
    }
  }


  Color _getPoiColor(String type) {
    switch (type) {
      case 'restaurant':
        return const Color(0xFFFF9800).withOpacity(0.4); // Transparent orange
      case 'hotel':
        return const Color(0xFF2196F3).withOpacity(0.4); // Transparent blue
      case 'tourist_place':
        return const Color(0xFF9C27B0).withOpacity(0.4); // Transparent purple
      case 'medical':
        return const Color(0xFFE53935).withOpacity(0.4); // Transparent red
      default:
        return Colors.grey.withOpacity(0.4);
    }
  }

// Update the _buildFilterChips method to include medical filter
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Restaurants'),
            selected: selectedFilters.contains('restaurant'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('restaurant');
                } else {
                  selectedFilters.remove('restaurant');
                }
              });
            },
          ),
          FilterChip(
            label: const Text('Hotels'),
            selected: selectedFilters.contains('hotel'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('hotel');
                } else {
                  selectedFilters.remove('hotel');
                }
              });
            },
          ),
          FilterChip(
            label: const Text('Tourist Places'),
            selected: selectedFilters.contains('tourist_place'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('tourist_place');
                } else {
                  selectedFilters.remove('tourist_place');
                }
              });
            },
          ),
          FilterChip(
            label: const Text('Medical Places'),
            selected: selectedFilters.contains('medical'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('medical');
                } else {
                  selectedFilters.remove('medical');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFilterChip(String label, String filter, IconData icon) {
    final isSelected = selectedFilters.contains(filter);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: Colors.grey[100],
      selectedColor: _getPoiColor(filter),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedFilters.add(filter);
          } else {
            selectedFilters.remove(filter);
          }
        });
      },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      right: 16,
      top: 80,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), // More transparent background
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
              _legendItem(Colors.green.shade400.withOpacity(0.3), 'Safe: 24-30°C'),
              _legendItem(Colors.yellow.shade700.withOpacity(0.3), 'Moderate: 20-23°C & 31-33°C'),
              _legendItem(Colors.orange.withOpacity(0.3), 'Cautious: 18-19°C & 34-35°C'),
              _legendItem(Colors.red.withOpacity(0.3), 'Unsafe: <18°C & >35°C'),
              const Divider(),
              _legendItem(Colors.orange.withOpacity(0.4), 'Restaurants'),
              _legendItem(Colors.blue.withOpacity(0.4), 'Hotels'),
              _legendItem(Colors.purple.withOpacity(0.4), 'Tourist Places'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showPoiDetails(PointOfInterest poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getPoiIcon(poi.type), color: _getPoiColor(poi.type)),
            const SizedBox(width: 8),
            Expanded(child: Text(poi.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(poi.description),
              const SizedBox(height: 8),
              if (poi.rating != null)
                Text('Rating: ${poi.rating!.toStringAsFixed(1)} ⭐'),
              Text('Distance: ${poi.distance.toStringAsFixed(1)} km'),
              if (poi.additionalInfo != null) ...[
                const Divider(),
                const Text('Additional Information:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...poi.additionalInfo!.entries
                    .where((entry) => entry.key != 'name')
                    .map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

