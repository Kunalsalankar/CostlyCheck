import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'Welcome_Screen.dart';
import 'home_view.dart';
import 'SignupPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Signup App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isSignedUp = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSignupStatus();
  }

  Future<void> _checkSignupStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSignedUp = prefs.getBool('isSignedUp') ?? false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isSignedUp ? HomeView() : SignupPage();
  }
}
