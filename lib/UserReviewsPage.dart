import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class UserReviewsPage extends StatefulWidget {
  final Map<String, dynamic> beach;

  const UserReviewsPage({super.key, required this.beach});

  @override
  _UserReviewsPageState createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late DatabaseReference _beachReviewsRef;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Ensure Firebase is initialized
      await Firebase.initializeApp();

      // Create a safe path key for the beach name
      String safeBeachKey = createSafeKey(widget.beach['name']);

      // Set up the reference to the beach reviews location
      _beachReviewsRef = _database.child('BeachesSet').child(safeBeachKey).child('reviews');

      // Set loading state to false
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Firebase initialization error: $e");
      setState(() {
        _errorMessage = "Failed to initialize database: $e";
        _isLoading = false;
      });
    }
  }

  // Create a safe key for database path (remove invalid characters)
  String createSafeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
  }

  // Method to add review to Realtime Database
  Future<void> _addReview() async {
    // Validate input
    if (_nameController.text.isEmpty ||
        _reviewController.text.isEmpty ||
        _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and provide a rating')),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a new review entry with a unique key
      DatabaseReference newReviewRef = _beachReviewsRef.push();

      // Add the new review with current timestamp in milliseconds
      Map<String, dynamic> reviewData = {
        'name': _nameController.text,
        'rating': _rating,
        'review': _reviewController.text,
        'date': DateTime.now().millisecondsSinceEpoch,
      };

      await newReviewRef.set(reviewData);

      // Log success to debug
      print("Review added successfully at ${newReviewRef.path}");

      // Clear input fields
      _nameController.clear();
      _reviewController.clear();
      setState(() {
        _rating = 0.0;
        _isLoading = false;
      });

      // Close the dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error adding review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding review: $e')),
      );
    }
  }

  // Method to show add review dialog
  void _showAddReviewDialog() {
    setState(() {
      _rating = 0.0;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Your Review',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.rate_review),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rate Your Experience:',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            iconSize: 30,
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1.0;
                              });
                            },
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _addReview,
                          child: const Text('Submit Review'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.beach['name']} Reviews',
          style: const TextStyle(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 149, 209, 244),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: _showAddReviewDialog,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeFirebase,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : StreamBuilder(
        stream: _beachReviewsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            print("Error in StreamBuilder: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reviews: ${snapshot.error}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Refresh
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          // Get data snapshot
          DataSnapshot dataSnapshot = snapshot.data!.snapshot;

          // No reviews or data doesn't exist
          if (!dataSnapshot.exists || dataSnapshot.value == null) {
            print("No reviews found at path: ${_beachReviewsRef.path}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'Be the first to add a review!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _showAddReviewDialog,
                  ),
                ],
              ),
            );
          }

          try {
            // Convert data from Realtime Database
            Map<dynamic, dynamic> reviewsMap = Map<dynamic, dynamic>.from(dataSnapshot.value as Map);
            List<Map<String, dynamic>> reviewsList = [];

            reviewsMap.forEach((key, value) {
              Map<String, dynamic> review = Map<String, dynamic>.from(value as Map);
              review['key'] = key;
              reviewsList.add(review);
            });

            // Sort by date (newest first)
            reviewsList.sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));

            // Display reviews
            return reviewsList.isEmpty
                ? Center(
              child: Text('No reviews yet'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviewsList.length,
              itemBuilder: (context, index) {
                // Get review data
                var review = reviewsList[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Optional: Add interaction when tapping a review
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    review['name'] ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                        (starIndex) => Icon(
                                      starIndex < (review['rating'] ?? 0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['review'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              // Convert timestamp to readable date
                              review['date'] != null
                                  ? DateFormat('MMM dd, yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      review['date'] as int))
                                  : 'Date unavailable',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            print("Error parsing data: $e");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error parsing review data: $e',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        backgroundColor: Colors.blue.shade400,
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
