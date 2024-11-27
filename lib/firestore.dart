import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');

  // Add booking details to Firestore
  Future<void> addBooking(
    String name,
    String mobile,
    String email,
    int numPeople,
    List<Map<String, String>> peopleDetails,
    String selectedBeach,
    String selectedActivity,
    DateTime selectedDate,
    String selectedTimeSlot,
    String totalPriceMessage,
  ) {
    // Prepare people details
    List<Map<String, dynamic>> people = peopleDetails.map((person) {
      return {
        'name': person['name'],
        'age': int.tryParse(person['age'] ?? '') ?? 0,
      };
    }).toList();

    // Add booking to Firestore
    return bookings.add({
      'name': name,
      'mobile': mobile,
      'email': email,
      'numPeople': numPeople,
      'peopleDetails': people,
      'selectedBeach': selectedBeach,
      'selectedActivity': selectedActivity,
      'selectedDate': selectedDate.toIso8601String(),
      'selectedTimeSlot': selectedTimeSlot,
      'totalPriceMessage': totalPriceMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
