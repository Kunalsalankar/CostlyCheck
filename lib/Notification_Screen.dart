import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Firebase Realtime Database reference
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // A list to hold notifications fetched from Realtime Database
  List<Map<String, dynamic>> notifications = [];

  // Fetch notifications from Firebase Realtime Database
  Future<void> fetchNotifications() async {
    try {
      // Fetch data from Realtime Database (adjust reference path if needed)
      DatabaseReference ref = _database.ref('alerts'); // 'alerts' is the reference
      DataSnapshot snapshot = await ref.get();
      
      // Process the snapshot to extract data
      if (snapshot.exists) {
        Map<String, dynamic> data = Map.from(snapshot.value as Map);
        setState(() {
          notifications = data.entries.map((entry) {
            var notification = entry.value;
            return {
              'id': entry.key,
              'message': notification['message'],
              'isImportant': notification['isImportant'] ?? false, // Default to false if not provided
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications when screen is initialized
  }

  List<Map<String, dynamic>> getSortedNotifications() {
    notifications.sort((a, b) {
      if (a['isImportant'] == b['isImportant']) {
        return 0;
      }
      return a['isImportant'] ? -1 : 1;
    });
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Safety Notifications'),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 100,
                      color: Color.fromARGB(255, 39, 142, 232),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No new notifications',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 149, 209, 244),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You will see notifications here when you receive them.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: getSortedNotifications().length,
              itemBuilder: (context, index) {
                var notification = getSortedNotifications()[index];
                return Dismissible(
                  key: Key(notification['id'].toString()),
                  onDismissed: (direction) {
                    // Add functionality for deleting notifications if needed
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ListTile(
                      key: Key(notification['id'].toString()),
                      leading: Icon(
                        notification['isImportant']
                            ? Icons.star
                            : Icons.notifications,
                        color: notification['isImportant']
                            ? Colors.amber
                            : Colors.grey,
                      ),
                      title: Text(notification['message']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}