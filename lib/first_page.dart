import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart'; // Ensure you have a separate file for LoginScreen

void main() => runApp(const FirstPageApp());

class FirstPageApp extends StatelessWidget {
  const FirstPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool isFirstTime = true; // Replace with actual logic to check user's first-time status

  @override
  Widget build(BuildContext context) {
    return isFirstTime ? const SignUpScreen() : const LoginScreen();
  }
}

// You can keep the existing LoginScreen class in 'login_screen.dart' and the SignUpScreen class in 'signup_screen.dart' for better organization.
