import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> activityNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllNotifications();
  }

  Future<void> fetchAllNotifications() async {
    try {
      // Fetch beach safety alerts
      DatabaseReference alertsRef = _database.ref('alerts');
      DatabaseReference activityRef = _database.ref('activity-notification');

      // Fetch both types of notifications concurrently
      await Future.wait([
        fetchAlerts(alertsRef),
        fetchActivityNotifications(activityRef)
      ]);

      setState(() {
        // Combine and sort all notifications by timestamp
        notifications.addAll(activityNotifications);
        notifications.sort((a, b) =>
            (b['timestamp'] as int).compareTo(a['timestamp'] as int));
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAlerts(DatabaseReference ref) async {
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<String, dynamic> data = Map.from(snapshot.value as Map);
      List<Map<String, dynamic>> fetchedAlerts = data.entries.map((entry) {
        var notification = entry.value;
        return {
          'id': entry.key,
          'type': 'Beach Safety Alert',
          'objectID': notification['objectID'] ?? 'N/A',
          'name': notification['name'] ?? 'Untitled Alert',
          'message': notification['message'] ?? 'No description',
          'district': notification['district'] ?? 'Unknown',
          'state': notification['state'] ?? 'Unknown',
          'color': notification['color'] ?? Colors.blue,
          'issueDate': notification['issueDate'] ?? DateTime.now().toString(),
          'timestamp': notification['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();

      notifications.addAll(fetchedAlerts);
    }
  }

  Future<void> fetchActivityNotifications(DatabaseReference ref) async {
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<String, dynamic> data = Map.from(snapshot.value as Map);
      List<Map<String, dynamic>> fetchedActivityNotifications = data.entries.map((entry) {
        var notification = entry.value;
        return {
          'id': entry.key,
          'type': 'Activity Notification',
          'objectID': notification['objectID'] ?? 'N/A',
          'name': notification['name'] ?? 'Untitled Activity',
          'message': notification['message'] ?? 'No description',
          'location': notification['location'] ?? 'Unknown',
          'color': Colors.green, // Custom color for activity notifications
          'timestamp': notification['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();

      activityNotifications.addAll(fetchedActivityNotifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 149, 209, 244),
        ),
      )
          : notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You will see beach safety alerts and activity notifications here.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: notifications.length,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemBuilder: (context, index) {
        var notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    // Parse the color from hex string or use provided color
    Color alertColor = notification['color'] is String
        ? _parseColor(notification['color'])
        : notification['color'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications,
                      color: alertColor,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        notification['type'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alertColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${notification['objectID']}',
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification['message'],
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                // Conditional location/district display
                if (notification['type'] == 'Beach Safety Alert')
                  _buildInfoChip(
                    icon: Icons.location_on,
                    text: '${notification['district']}, ${notification['state']}',
                  )
                else if (notification['type'] == 'Activity Notification')
                  _buildInfoChip(
                    icon: Icons.location_on,
                    text: notification['location'] ?? 'Unknown',
                  ),
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  text: _formatDate(notification['timestamp']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      // Remove # if present and handle both 3 and 6 digit hex colors
      colorHex = colorHex.replaceAll('#', '');
      if (colorHex.length == 3) {
        colorHex = colorHex.split('').map((char) => char * 2).join();
      }
      return Color(int.parse('0xFF$colorHex'));
    } catch (e) {
      return Colors.blue; // Default color if parsing fails
    }
  }

  String _formatDate(int timestamp) {
    try {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown Date'; // Return fallback if parsing fails
    }
  }
}