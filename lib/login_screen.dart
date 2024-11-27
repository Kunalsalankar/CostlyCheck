import 'package:flutter/material.dart';

void main() => runApp(const LoginApp());

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
       debugShowCheckedModeBanner: false, // Disable the debug banner
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login.jpg'), // Ensure this image exists in your assets folder
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center, // Center the login form
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // This ensures the column takes up minimal space
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: false, // This should be managed with state
                            onChanged: (bool? value) {
                              // Handle checkbox state
                            },
                          ),
                          const Text('Remember Password')
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Add forget password logic here
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Add login logic here
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
