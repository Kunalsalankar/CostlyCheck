import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class ActivityScreen extends StatefulWidget {
  final String? beachName;

  const ActivityScreen({super.key, this.beachName});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // State variables
  List<ActivityModel> activities = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Controllers for filtering
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch activities with improved error handling
  Future<void> _fetchActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final DatabaseReference ref = FirebaseDatabase.instance.ref('beach-activities');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? rawData = snapshot.value as Map<dynamic, dynamic>?;

        if (rawData != null) {
          setState(() {
            activities = rawData.entries.map((entry) {
              return ActivityModel.fromMap(
                id: entry.key,
                data: Map<String, dynamic>.from(entry.value),
              );
            }).toList();

            // Apply initial beach name filter if provided
            if (widget.beachName != null) {
              activities = activities
                  .where((activity) =>
              activity.beachName.toLowerCase() == widget.beachName!.toLowerCase())
                  .toList();
            }

            _isLoading = false;
          });
        } else {
          setState(() {
            activities = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          activities = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load activities: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Filter and search activities
  List<ActivityModel> _getFilteredActivities() {
    return activities
        .where((activity) =>
    _searchQuery.isEmpty ||
        activity.activityName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        activity.beachName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        activity.activityType.toLowerCase().contains(_searchQuery.toLowerCase())
    )
        .toList()
      ..sort((a, b) => a.activityDate.compareTo(b.activityDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.beachName != null
              ? '${widget.beachName} Activities'
              : 'Beach Activities',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content Area
          Expanded(
            child: _buildActivityContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    final filteredActivities = _getFilteredActivities();

    if (filteredActivities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.beach_access,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'No activities found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Try another beach or search term',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    // Determine icon based on activity type
    IconData activityIcon = Icons.beach_access;
    if (activity.activityType.toLowerCase().contains('surf')) {
      activityIcon = Icons.surfing;
    } else if (activity.activityType.toLowerCase().contains('swim')) {
      activityIcon = Icons.pool;
    } else if (activity.activityType.toLowerCase().contains('fish')) {
      activityIcon = Icons.pool;
    } else if (activity.activityType.toLowerCase().contains('boat')) {
      activityIcon = Icons.directions_boat;
    } else if (activity.activityType.toLowerCase().contains('yoga')) {
      activityIcon = Icons.self_improvement;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            activityIcon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          activity.activityName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildActivityDetail('Beach', activity.beachName),
            // Type field removed from here
            _buildActivityDetail('Date', activity.activityDate),
            _buildActivityDetail('Time', '${activity.startTime} - ${activity.endTime}'),
            _buildActivityDetail('Price', activity.price),
            if (activity.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  activity.description,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Model to represent an Activity
class ActivityModel {
  final String id;
  final String beachName;
  final String activityName;
  final String activityType;
  final String description;
  final String location;
  final String startTime;
  final String endTime;
  final String activityDate;
  final String price;
  final String contactInfo;

  ActivityModel({
    required this.id,
    required this.beachName,
    required this.activityName,
    required this.activityType,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.activityDate,
    required this.price,
    required this.contactInfo,
  });

  // Factory constructor to create ActivityModel from Map
  factory ActivityModel.fromMap({
    required String id,
    required Map<String, dynamic> data
  }) {
    return ActivityModel(
      id: id,
      beachName: data['beachName'] ?? 'Unknown Beach',
      activityName: data['activityName'] ?? 'Unnamed Activity',
      activityType: data['activityType'] ?? 'Unspecified',
      description: data['description'] ?? '',
      location: data['location'] ?? 'Unspecified Location',
      startTime: data['startTime'] ?? 'Not Set',
      endTime: data['endTime'] ?? 'Not Set',
      activityDate: data['activityDate'] ?? 'Unscheduled',
      price: data['price'] ?? 'Free',
      contactInfo: data['contactInfo'] ?? 'No Contact Info',
    );
  }

  // Convert model back to map for passing to other screens
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'beachName': beachName,
      'activityName': activityName,
      'activityType': activityType,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'activityDate': activityDate,
      'price': price,
      'contactInfo': contactInfo,
    };
  }
}