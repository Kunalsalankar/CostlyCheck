import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Sample list of beach safety notifications
  List<Map<String, dynamic>> notifications = [
    {'id': 1, 'message': 'Dangerous waves expected at beach A.', 'isImportant': false},
    {'id': 2, 'message': 'High tide warning at beach B. Stay alert!', 'isImportant': false},
    {'id': 3, 'message': 'Shark sighting reported at beach C.', 'isImportant': true},
  ];

  // Variable to hold the last deleted notification for undo
  Map<String, dynamic>? lastDeletedNotification;
  int? lastDeletedIndex;

  // Function to sort notifications with important ones at the top
  List<Map<String, dynamic>> getSortedNotifications() {
    notifications.sort((a, b) {
      // If both notifications are important, they are already in the correct order
      if (a['isImportant'] == b['isImportant']) {
        return 0;
      }
      // Otherwise, make sure important notifications come first
      return a['isImportant'] ? -1 : 1;
    });
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Safety Notifications'),
        backgroundColor: Colors.teal,
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
                color: Colors.teal,
              ),
              SizedBox(height: 20),
              Text(
                'No new notifications',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.teal,
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
              // Save the last deleted notification for undo
              lastDeletedNotification = notification;
              lastDeletedIndex = index;

              // Remove notification from the list
              setState(() {
                notifications.removeAt(index);
              });

              // Show a snackbar with undo option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${notification['message']} deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      // Undo the delete
                      setState(() {
                        notifications.insert(lastDeletedIndex!, lastDeletedNotification!);
                      });
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
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
                  key: ValueKey(notification['isImportant']),
                ),
                title: Text(notification['message']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        notification['isImportant']
                            ? Icons.star
                            : Icons.star_border,
                      ),
                      onPressed: () {
                        // Toggle the importance of the notification
                        setState(() {
                          notification['isImportant'] =
                          !notification['isImportant'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            notification['isImportant']
                                ? 'Marked as Important'
                                : 'Removed from Important',
                          ),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
