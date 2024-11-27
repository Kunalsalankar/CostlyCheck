import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Name extends StatefulWidget {
  const Name({super.key});

  @override
  _NameState createState() => _NameState();
}

class _NameState extends State<Name> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySubmitted();
  }

  void _checkIfAlreadySubmitted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSubmitted = prefs.getBool('formSubmitted') ?? false;

    if (isSubmitted) {
      Navigator.pushReplacementNamed(context, '/HomeScreen');
    }
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'dob': _dobController.text,
      'address': _addressController.text,
    };

    // Save data and set the flag
    await prefs.setString('userData', json.encode(userData));
    await prefs.setBool('formSubmitted', true);

    // Navigate to Home Screen
    Navigator.pushReplacementNamed(context, '/HomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
                  }
                },
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveData();
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
