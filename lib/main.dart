import 'package:flutter/material.dart';
import 'Welcome_Screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beach Search App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:  const Welcome_Screen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
