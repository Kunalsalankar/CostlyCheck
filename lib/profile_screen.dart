import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> profileOptions = [
    {
      'icon': Icons.person_outline,
      'title': 'Personal Information',
      'subtitle': 'Edit profile details',
    },
    {
      'icon': Icons.travel_explore,
      'title': 'My Trips',
      'subtitle': 'View your saved and past trips',
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'Settings',
      'subtitle': 'App preferences and configurations',
    },
    {
      'icon': Icons.help_outline,
      'title': 'Help & Support',
      'subtitle': 'Get assistance and FAQs',
    },
    {
      'icon': Icons.logout,
      'title': 'Logout',
      'subtitle': 'Sign out of your account',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 64, 186, 255),
                      Color.fromARGB(255, 86, 204, 242)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Picture and Name
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'John Doe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Beach Explorer Enthusiast',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Profile Stats
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProfileStatWidget(
                          value: '12',
                          label: 'Beaches\nVisited',
                        ),
                        ProfileStatWidget(
                          value: '5',
                          label: 'Active\nTrips',
                        ),
                        ProfileStatWidget(
                          value: '24',
                          label: 'Total\nPhotos',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Profile Options
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: profileOptions.map((option) {
                    return ProfileOptionTile(
                      icon: option['icon'],
                      title: option['title'],
                      subtitle: option['subtitle'],
                      onTap: () {
                        // Add navigation or action for each option
                        _handleProfileOptionTap(option['title']);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleProfileOptionTap(String title) {
    switch (title) {
      case 'Personal Information':
      // Navigate to personal info edit page
        break;
      case 'My Trips':
      // Navigate to trips page
        break;
      case 'Settings':
      // Navigate to settings page
        break;
      case 'Help & Support':
      // Navigate to help page
        break;
      case 'Logout':
      // Implement logout functionality
        break;
    }
  }
}

class ProfileStatWidget extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatWidget({
    Key? key,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileOptionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}