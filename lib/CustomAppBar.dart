// CustomAppBar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color.fromARGB(255, 149, 209, 244),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // AppBar height
}
