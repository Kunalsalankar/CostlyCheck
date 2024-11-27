import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book extends StatefulWidget {
  const Book({super.key});

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  int _numPeople = 0;
  List<Map<String, String>> _peopleDetails = [];
  String? _selectedBeach;
  String? _selectedActivity;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _totalPriceMessage = "";

  final List<String> beaches = [
    'Cherai Beach, Kochi',
    'Fort Kochi Beach, Kochi',
    'Puthuvype Beach, Kochi',
    'Munambam Beach, Kochi',
    'Andhakaranazhi Beach, Kochi',
    'Kuzhupilly Beach, Kochi',
    'Vypin Beach, Kochi',
    'Kappad Beach, Kochi',
    'Marari Beach, Kochi',
    'Ramakrishna Beach, Vizag',
    'Rushikonda Beach, Vizag',
    'Yarada Beach, Vizag',
    'Bheemili Beach, Vizag',
    'Lawson’s Bay Beach, Vizag',
    'Gangavaram Beach, Vizag',
    'Sagar Nagar Beach, Vizag',
    'Thotlakonda Beach, Vizag',
    'Appikonda Beach, Vizag',
  ];

  final List<String> activities = [
    'Parasailing',
    'Snorkeling',
    'Jet Skiing',
  ];

  final List<String> timeSlots = [
    '9:00 AM - 11:00 AM',
    '11:00 AM - 1:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];

  Map<String, Map<String, int>> pricing = {
    'Parasailing': {
      '10-15': 800,
      '16-40': 1200,
      '41-55': 1000,
    },
    'Snorkeling': {
      '8-12': 800,
      '13-25': 1200,
      '26-50': 1000,
    },
    'Jet Skiing': {
      '10-15': 1000,
      '16-30': 1500,
      '31-50': 1200,
    },
  };

  void calculateTotalPrice() {
    int totalPrice = 0;
    bool notEligible = false;

    for (var person in _peopleDetails) {
      final age = int.tryParse(person['age'] ?? '');
      if (age == null || _selectedActivity == null) continue;

      bool eligible = false;

      pricing[_selectedActivity!]!.forEach((ageRange, price) {
        final ages = ageRange.split('-').map(int.parse).toList();
        if (age >= ages[0] && age <= ages[1]) {
          totalPrice += price;
          eligible = true;
        }
      });

      if (!eligible) {
        notEligible = true;
      }
    }

    setState(() {
      _totalPriceMessage = notEligible
          ? "Some participants are not eligible for $_selectedActivity."
          : "Total Price: ₹$totalPrice";
    });
  }

  void _showConfirmationDialog(Map<String, dynamic> formDetails) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Booking Confirmed'),
        content: Text(
          'Thank you, ${formDetails['name']}! Your booking details are as follows:\n\n'
          'Beach: ${formDetails['beach']}\n'
          'Activity: ${formDetails['activity']}\n'
          'Date: ${formDetails['date']}\n'
          'Time Slot: ${formDetails['timeSlot']}\n'
          'Participants: ${formDetails['participants'].length}\n\n'
          '${formDetails['totalPrice']}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void _submitBooking(Map<String, dynamic> formDetails) async {
  try {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2)); // Replace with actual API call

    // Show confirmation dialog
    _showConfirmationDialog(formDetails);
  } catch (e) {
    // Handle errors gracefully
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit booking: $e')),
    );
  }
}

void sendDataToFirestore() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Gather data
    Map<String, dynamic> bookingData = {
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'email': _emailController.text,
      'beach': _selectedBeach,
      'activity': _selectedActivity,
      'numPeople': _numPeople,
      'peopleDetails': _peopleDetails,
      'date': _selectedDate?.toIso8601String(),
      'timeSlot': _selectedTimeSlot,
      'totalPriceMessage': _totalPriceMessage,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Send data to Firestore
      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );

      // Clear form after submission
      _formKey.currentState?.reset();
      setState(() {
        _nameController.clear();
        _mobileController.clear();
        _emailController.clear();
        _selectedBeach = null;
        _selectedActivity = null;
        _numPeople = 0;
        _peopleDetails = [];
        _selectedDate = null;
        _selectedTimeSlot = null;
        _totalPriceMessage = "";
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Adventure'),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244), // Simple color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Fields with Icons
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Dropdowns for Beach and Activity
              DropdownButtonFormField<String>(
                value: _selectedBeach,
                decoration: const InputDecoration(
                  labelText: 'Select Beach',
                  prefixIcon: Icon(Icons.beach_access),
                  border: OutlineInputBorder(),
                ),
                items: beaches
                    .map((beach) => DropdownMenuItem(value: beach, child: Text(beach)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBeach = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a beach';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedActivity,
                decoration: const InputDecoration(
                  labelText: 'Select Adventure Activity',
                  prefixIcon: Icon(Icons.directions_run),
                  border: OutlineInputBorder(),
                ),
                items: activities
                    .map((activity) => DropdownMenuItem(value: activity, child: Text(activity)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select an activity';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Number of People
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of People'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _numPeople = int.tryParse(value) ?? 0;
                    _peopleDetails = List.generate(_numPeople, (_) => {'name': '', 'age': ''});
                  });
                },
              ),
              if (_numPeople > 0)
                ...List.generate(_numPeople, (index) {
                  return Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Person ${index + 1} Name'),
                        onChanged: (value) {
                          _peopleDetails[index]['name'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Person ${index + 1} Age'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _peopleDetails[index]['age'] = value;
                          calculateTotalPrice();
                        },
                      ),
                      // Age eligibility message for each person
                      Text(
                        _peopleDetails[index]['age'] != '' && int.tryParse(_peopleDetails[index]['age'] ?? '') != null
                            ? getAgeEligibilityMessage(int.parse(_peopleDetails[index]['age']!))
                            : '',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  );
                }),
              const SizedBox(height: 10),
              // Date Picker
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : '$_selectedDate : ${_selectedDate!.toLocal()}'.split(' ')[0],  // Display the selected date
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Time Slot
              DropdownButtonFormField<String>(
                value: _selectedTimeSlot,
                decoration: const InputDecoration(
                  labelText: 'Select Time Slot',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                items: timeSlots
                    .map((slot) => DropdownMenuItem(value: slot, child: Text(slot)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeSlot = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a time slot';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Display Total Price or Eligibility Message
              Text(_totalPriceMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  sendDataToFirestore();
                  
                  if (_formKey.currentState?.validate() ?? false) {
                    final formDetails = {
                      'name': _nameController.text.trim(),
                      'mobile': _mobileController.text.trim(),
                      'email': _emailController.text.trim(),
                      'beach': _selectedBeach,
                      'activity': _selectedActivity,
                      'date': _selectedDate?.toIso8601String(),
                      'timeSlot': _selectedTimeSlot,
                      'participants': _peopleDetails,
                      'totalPrice': _totalPriceMessage,
                    };

                    _submitBooking(formDetails);
                  }
                },
                child: const Text('Book now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getAgeEligibilityMessage(int age) {
    if (_selectedActivity == null) return '';
    final activityPrice = pricing[_selectedActivity]!;
    String message = '';
    activityPrice.forEach((ageRange, price) {
      final ages = ageRange.split('-').map(int.parse).toList();
      if (age >= ages[0] && age <= ages[1]) {
        message = 'Eligible for $_selectedActivity';
      }
    });
    return message.isEmpty ? 'Not eligible for $_selectedActivity' : message;
  }
}

