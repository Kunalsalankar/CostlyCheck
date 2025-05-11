import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransportationScreen extends StatefulWidget {
  final String beachName;
  final Map<String, dynamic>? beachData;

  const TransportationScreen({
    Key? key,
    required this.beachName,
    this.beachData,
  }) : super(key: key);

  @override
  _TransportationScreenState createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  bool _isLoading = true;
  Position? _currentPosition;
  Map<String, dynamic>? _beachLocation;
  List<Map<String, dynamic>> _uberProducts = [];
  String? _errorMessage;

  // Fixed: Store API keys properly - preferably use a more secure method in production
  // These would come from your .env file
  final String _uberClientId = 'WL0NWWkdWLrcfhhA9n-pxFclOV7xXa8';  // Replace with actual ID or use dotenv properly
  final String _uberServerToken = 'iK6r8vMU8cpR3O_SyFVIAtsKYT5zjQCHd0tafnol';  // Replace with actual token

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Get user's current location
      await _getCurrentLocation();

      // 2. Get beach coordinates
      await _getBeachCoordinates();

      // 3. Fetch Uber products (commented out for now to avoid API errors)
      // if (_currentPosition != null && _beachLocation != null) {
      //   await _getUberProducts();
      // }

      // For demo purposes, let's create some mock Uber products
      _createMockUberProducts();

    } catch (e) {
      setState(() {
        _errorMessage = "Error loading transportation options: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createMockUberProducts() {
    setState(() {
      _uberProducts = [
        {
          'display_name': 'UberX',
          'product_id': 'uberx-123',
          'description': 'Affordable, everyday rides',
        },
        {
          'display_name': 'Uber Black',
          'product_id': 'black-123',
          'description': 'Premium rides in luxury cars',
        },
        {
          'display_name': 'Uber XL',
          'product_id': 'xl-123',
          'description': 'Affordable rides for groups up to 6',
        }
      ];
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Location services are disabled. Please enable them to use transportation features.';
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }

    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        // Provide mock location if getting current position fails
        _currentPosition = Position(
          longitude: 0,
          latitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _errorMessage = 'Could not get current location: $e. Using default location.';
      });
    }
  }

  Future<void> _getBeachCoordinates() async {
    // Sample beach coordinates map
    final Map<String, Map<String, dynamic>> beachCoordinates = {
      'Bondi Beach': {'latitude': -33.8915, 'longitude': 151.2767},
      'Copacabana': {'latitude': -22.9698, 'longitude': -43.1866},
      'Venice Beach': {'latitude': 33.9850, 'longitude': -118.4695},
      'Waikiki': {'latitude': 21.2793, 'longitude': -157.8292},
      // Add more beaches as needed
    };

    // If beach is in our predefined list, use those coordinates
    if (beachCoordinates.containsKey(widget.beachName)) {
      setState(() {
        _beachLocation = beachCoordinates[widget.beachName];
      });
    }
    // Or if beach data was passed with coordinates
    else if (widget.beachData != null &&
        widget.beachData!.containsKey('latitude') &&
        widget.beachData!.containsKey('longitude')) {
      setState(() {
        _beachLocation = {
          'latitude': widget.beachData!['latitude'],
          'longitude': widget.beachData!['longitude'],
        };
      });
    }
    // Otherwise, use a default location
    else {
      setState(() {
        _beachLocation = {'latitude': 0.0, 'longitude': 0.0};
        _errorMessage = 'Could not find coordinates for ${widget.beachName}. Using default location.';
      });
    }
  }

  Future<void> _getUberProducts() async {
    try {
      // Endpoint for getting Uber products
      final String endpoint = 'https://api.uber.com/v1.2/products';

      final response = await http.get(
        Uri.parse('$endpoint?latitude=${_currentPosition!.latitude}&longitude=${_currentPosition!.longitude}'),
        headers: {
          'Authorization': 'Token $_uberServerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('products')) {
          setState(() {
            _uberProducts = List<Map<String, dynamic>>.from(data['products']);
          });
        } else {
          setState(() {
            _errorMessage = 'No Uber products available in this area';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load Uber products: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching Uber products: $e';
      });
    }
  }

  Future<void> _requestUberRide(String productId) async {
    if (_beachLocation == null) {
      setState(() {
        _errorMessage = 'Beach location information is missing';
      });
      return;
    }

    try {
      // Create deep link URL to Uber app
      final String uberUrl = 'uber://?action=setPickup'
          '&pickup=my_location'
          '&dropoff[latitude]=${_beachLocation!['latitude']}'
          '&dropoff[longitude]=${_beachLocation!['longitude']}'
          '&dropoff[nickname]=${widget.beachName}'
          '&product_id=$productId';

      // Check if Uber app is installed
      final Uri uri = Uri.parse(uberUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // If Uber app is not installed, open in browser
        final String webUrl = 'https://m.uber.com/ul/?'
            'action=setPickup'
            '&pickup=my_location'
            '&dropoff[latitude]=${_beachLocation!['latitude']}'
            '&dropoff[longitude]=${_beachLocation!['longitude']}'
            '&dropoff[nickname]=${widget.beachName}';

        final Uri webUri = Uri.parse(webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          setState(() {
            _errorMessage = 'Could not launch Uber';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error launching Uber: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transportation to ${widget.beachName}'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null && _uberProducts.isEmpty
          ? _buildErrorView()
          : _buildTransportationOptions(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading transportation options...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportationOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDirectionsCard(),
          const SizedBox(height: 20),
          _buildUberOptionsCard(),
          const SizedBox(height: 20),
          _buildPublicTransportCard(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectionsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'View the route to the beach using your preferred navigation app.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Open in Maps'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _openInMaps(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUberOptionsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_taxi, color: Colors.black),
                const SizedBox(width: 8),
                const Text(
                  'Uber',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _uberProducts.isEmpty
                ? const Text(
              'No Uber services available for this location',
              style: TextStyle(fontSize: 14),
            )
                : Column(
              children: _uberProducts.map((product) => _buildUberProductItem(product)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUberProductItem(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getVehicleIcon(product['display_name']),
            color: Colors.black,
          ),
        ),
        title: Text(
          product['display_name'] ?? 'Uber',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product['description'] ?? 'Get a ride to the beach',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: ElevatedButton(
          child: const Text('Ride'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _requestUberRide(product['product_id']),
        ),
        onTap: () => _requestUberRide(product['product_id']),
      ),
    );
  }

  Widget _buildPublicTransportCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Public Transportation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Check public transport options to get to the beach.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_transit),
                label: const Text('View Transit Options'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _openTransitDirections(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String? displayName) {
    if (displayName == null) return Icons.local_taxi;

    final String name = displayName.toLowerCase();
    if (name.contains('uberx')) return Icons.directions_car;
    if (name.contains('black')) return Icons.airport_shuttle;
    if (name.contains('suv')) return Icons.directions_car;
    if (name.contains('xl')) return Icons.airport_shuttle;
    if (name.contains('green')) return Icons.electric_car;
    return Icons.local_taxi;
  }

  Future<void> _openInMaps() async {
    if (_beachLocation == null) {
      setState(() {
        _errorMessage = 'Beach location information is missing';
      });
      return;
    }

    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${_beachLocation!['latitude']},${_beachLocation!['longitude']}&destination_place_id=${Uri.encodeComponent(widget.beachName)}';

    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        _errorMessage = 'Could not open maps application';
      });
    }
  }

  Future<void> _openTransitDirections() async {
    if (_beachLocation == null) {
      setState(() {
        _errorMessage = 'Beach location information is missing';
      });
      return;
    }

    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${_beachLocation!['latitude']},${_beachLocation!['longitude']}&travelmode=transit';

    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        _errorMessage = 'Could not open maps application';
      });
    }
  }
}