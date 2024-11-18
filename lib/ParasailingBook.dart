import 'package:flutter/material.dart';

class ParasailingBook extends StatefulWidget {
  final String beachName; // Beach name passed from Explore.dart

  const ParasailingBook({super.key, required this.beachName});

  @override
  _ParasailingBookState createState() => _ParasailingBookState();
}

class _ParasailingBookState extends State<ParasailingBook> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController numberOfCandidatesController =
      TextEditingController();
  List<TextEditingController> ageControllers = [];
  String? selectedTimeSlot;
  DateTime? selectedDate;
  double totalFare = 0;

  // Time Slot options
  List<String> timeSlots = ['Morning', 'Afternoon', 'Evening'];

  // Fare Calculation based on age
  double calculateFare(int age) {
    if (age >= 10 && age <= 15) {
      return 800;
    } else if (age >= 16 && age <= 40) {
      return 1200;
    } else if (age >= 41 && age <= 55) {
      return 1000;
    } else {
      return 0; // No fare for ages outside the specified ranges
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Parasailing at ${widget.beachName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Form',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile Field
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
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
              const SizedBox(height: 16),

              // Number of Candidates
              TextFormField(
                controller: numberOfCandidatesController,
                decoration: const InputDecoration(
                  labelText: 'Number of Candidates',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number of candidates';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    int numCandidates = int.tryParse(value) ?? 0;
                    // Generate controllers for candidate ages
                    ageControllers = List.generate(numCandidates, (index) => TextEditingController());
                  });
                },
              ),
              const SizedBox(height: 16),

              // Age Fields for each candidate
              ...List.generate(ageControllers.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: ageControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Age of Candidate ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              // Time Slot Dropdown
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTimeSlot,
                items: timeSlots.map((timeSlot) {
                  return DropdownMenuItem<String>(
                    value: timeSlot,
                    child: Text(timeSlot),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedTimeSlot = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Preferred Time Slot',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a time slot';
                  }
                  return null;
                },
              ),

              // Date Picker
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    selectedDate == null
                        ? 'Select a Date'
                        : '${selectedDate!.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Fare Calculation
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    double fare = 0;
                    for (var controller in ageControllers) {
                      int age = int.tryParse(controller.text) ?? 0;
                      fare += calculateFare(age);
                    }

                    setState(() {
                      totalFare = fare;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Total Fare: \$${totalFare.toStringAsFixed(2)}')),
                    );
                  }
                },
                child: const Text('Calculate Total Fare'),
              ),
              const SizedBox(height: 16),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking Successful!')),
                      );
                    }
                  },
                  child: const Text('Submit Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
