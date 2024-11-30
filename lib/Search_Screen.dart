import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // List of beaches from Kochi and Vizag
  List<String> beaches = [
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

  List<String> filteredBeaches = [];

  @override
  void initState() {
    super.initState();
    filteredBeaches = beaches;
    _searchController.addListener(() {
      filterBeaches();
    });
  }

  void filterBeaches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBeaches = beaches.where((beach) => beach.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search for beaches...',
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 0, 13, 12)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}
