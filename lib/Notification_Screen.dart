import 'dart:math';
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
  List<Map<String, dynamic>> generalNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllNotifications();
  }

  Future<void> fetchAllNotifications() async {
    try {
      // Fetch all types of notifications
      DatabaseReference alertsRef = _database.ref('alerts');
      DatabaseReference activityRef = _database.ref('activity-notification');
      DatabaseReference generalRef = _database.ref('notifications');

      // Fetch all types of notifications concurrently
      await Future.wait([
        fetchAlerts(alertsRef),
        fetchActivityNotifications(activityRef),
        fetchGeneralNotifications(generalRef)
      ]);

      setState(() {
        // Combine and sort all notifications by timestamp
        notifications.addAll(activityNotifications);
        notifications.addAll(generalNotifications);
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
    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        // Handle case when the data is an actual Map
        if (snapshot.value is Map) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> fetchedAlerts = [];

          data.forEach((key, value) {
            if (value is Map) {
              Map<dynamic, dynamic> notification = value;
              fetchedAlerts.add({
                'id': key.toString(),
                'type': 'Beach Safety Alert',
                'objectID': notification['objectID']?.toString() ?? 'N/A',
                'name': notification['name']?.toString() ?? 'Untitled Alert',
                'message': notification['message']?.toString() ?? 'No description',
                'district': notification['district']?.toString() ?? 'Unknown',
                'state': notification['state']?.toString() ?? 'Unknown',
                'color': notification['color'] ?? Colors.blue,
                'issueDate': notification['issueDate']?.toString() ?? DateTime.now().toString(),
                'timestamp': notification['timestamp'] is int
                    ? notification['timestamp']
                    : DateTime.now().millisecondsSinceEpoch,
              });
            }
          });

          if (fetchedAlerts.isNotEmpty) {
            notifications.addAll(fetchedAlerts);
            print("Added ${fetchedAlerts.length} alerts from 'alerts' path");
          } else {
            print("No alerts found in valid format");
          }
        } else {
          print("Data at 'alerts' is not a Map: ${snapshot.value.runtimeType}");
        }
      } else {
        print("No data exists at 'alerts' path");
      }
    } catch (e) {
      print("Error fetching alerts: $e");
    }
  }

  Future<void> fetchActivityNotifications(DatabaseReference ref) async {
    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        // Handle case when the data is an actual Map
        if (snapshot.value is Map) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> fetchedActivityNotifications = [];

          data.forEach((key, value) {
            if (value is Map) {
              Map<dynamic, dynamic> notification = value;
              fetchedActivityNotifications.add({
                'id': key.toString(),
                'type': 'Activity Notification',
                'objectID': notification['objectID']?.toString() ?? 'N/A',
                'name': notification['name']?.toString() ?? 'Untitled Activity',
                'message': notification['message']?.toString() ?? 'No description',
                'location': notification['location']?.toString() ?? 'Unknown',
                'color': Colors.green, // Custom color for activity notifications
                'timestamp': notification['timestamp'] is int
                    ? notification['timestamp']
                    : DateTime.now().millisecondsSinceEpoch,
              });
            }
          });

          if (fetchedActivityNotifications.isNotEmpty) {
            activityNotifications.addAll(fetchedActivityNotifications);
            print("Added ${fetchedActivityNotifications.length} activities from 'activity-notification' path");
          } else {
            print("No activity notifications found in valid format");
          }
        } else {
          print("Data at 'activity-notification' is not a Map: ${snapshot.value.runtimeType}");
        }
      } else {
        print("No data exists at 'activity-notification' path");
      }
    } catch (e) {
      print("Error fetching activity notifications: $e");
    }
  }

  // New method to fetch general notifications from the 'notifications' path
  Future<void> fetchGeneralNotifications(DatabaseReference ref) async {
    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        // Debug output to see data structure
        print("Notifications data structure: ${snapshot.value.runtimeType}");

        // Handle case when the data is an actual Map
        if (snapshot.value is Map) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> fetchedGeneralNotifications = [];

          data.forEach((key, value) {
            if (value is Map) {
              Map<dynamic, dynamic> notification = value;
              print("Processing notification with key: $key");

              // Determine color based on priority
              Color notificationColor;
              String priority = notification['priority']?.toString().toLowerCase() ?? 'medium';
              switch (priority) {
                case 'high':
                  notificationColor = Colors.red;
                  break;
                case 'medium':
                  notificationColor = Colors.orange;
                  break;
                case 'low':
                  notificationColor = Colors.green;
                  break;
                default:
                  notificationColor = Colors.blue;
              }

              // Print debug info about createdAt field
              print("createdAt type: ${notification['createdAt']?.runtimeType}");
              print("createdAt value: ${notification['createdAt']}");

              // Build notification object
              fetchedGeneralNotifications.add({
                'id': key.toString(),
                'type': 'General Notification',
                'objectID': key.toString().substring(0, min(8, key.toString().length)), // Use part of the Firebase key as object ID
                'name': notification['title']?.toString() ?? 'Untitled Notification',
                'message': notification['message']?.toString() ?? 'No description',
                'priority': notification['priority']?.toString() ?? 'medium',
                'color': notificationColor,
                'timestamp': notification['createdAt'] is int
                    ? notification['createdAt']
                    : DateTime.now().millisecondsSinceEpoch,
              });
            }
          });

          if (fetchedGeneralNotifications.isNotEmpty) {
            generalNotifications.addAll(fetchedGeneralNotifications);
            print("Added ${fetchedGeneralNotifications.length} notifications from 'notifications' path");
          } else {
            print("No general notifications found in valid format");
          }
        } else {
          print("Data at 'notifications' is not a Map: ${snapshot.value.runtimeType}");
        }
      } else {
        print("No data exists at 'notifications' path");
      }
    } catch (e) {
      print("Error fetching general notifications: $e");
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

    // Get the notification type for display
    String typeText = notification['type'];

    // For general notifications, add priority level
    if (typeText == 'General Notification') {
      String priority = notification['priority'] ?? 'medium';
      typeText = '$typeText - ${priority.toUpperCase()}';
    }

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
                      _getNotificationIcon(notification['type']),
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
                        typeText,
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
                // Conditional location/district display based on notification type
                if (notification['type'] == 'Beach Safety Alert')
                  _buildInfoChip(
                    icon: Icons.location_on,
                    text: '${notification['district']}, ${notification['state']}',
                  )
                else if (notification['type'] == 'Activity Notification')
                  _buildInfoChip(
                    icon: Icons.location_on,
                    text: notification['location'] ?? 'Unknown',
                  )
                else if (notification['type'] == 'General Notification')
                    _buildInfoChip(
                      icon: Icons.priority_high,
                      text: 'Priority: ${(notification['priority'] ?? 'medium').toUpperCase()}',
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Beach Safety Alert':
        return Icons.warning;
      case 'Activity Notification':
        return Icons.directions_run;
      case 'General Notification':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
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