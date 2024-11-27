import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TideScreen.dart'; // Import the TideScreen.dart file

class TidalForecastScreen extends StatefulWidget {
  const TidalForecastScreen({super.key});

  @override
  _TidalForecastScreenState createState() => _TidalForecastScreenState();
}

class _TidalForecastScreenState extends State<TidalForecastScreen> {
  final List stations = [
    'Mangalore', 'Marmagao', 'Miani', 'Minicoy', 'Mirissa', 'Mora-Bandar-Uran',
      'Mundra', 'Muskazi', 'NW-Hazira-Tapi-River', 'Nagapatnam', 'Nancowry-Harbour',
      'Navi-Wat', 'Navlakhi', 'Nawabandar', 'Nindakara', 'Normans-Point', 'Okha',
      'Pamban-Pass', 'Paradip', 'Peros-Banhos', 'Pipavav-Bandar', 'Point-Pedro', 'Pondichery',
      'Ponnani', 'Porbandar', 'Port-Albert-Victor', 'Port-Anson', 'Port-Blair', 'Port-Cornwallis',
      'Porto-Novo', 'Pussur-River-Jefford', 'Pyinsalu', 'Quilon', 'Rabnabad-Channel', 'Ratnagiri',
      'Revadanda', 'Revas-Bandar', 'Rozi', 'Sacramento-Shoal', 'Sagar-Roads', 'Sagu-Island',
      'Salaya-Sykes-Point', 'Satpati', 'Searle-Point', 'Short-Island', 'Shrivardhan', 'Sikka',
      'Solomon-Islands', 'South-Galatea-Bay', 'St-Martins-Island', 'Stewart-Sound', 'Straight-Island',
      'Sultanpur-Gulf-of-Cambay', 'Surya-Lanka', 'Suvali', 'Tadri', 'Tangalle', 'Tekra',
      'Tellicherry', 'Temple-Sound', 'The-Sisters', 'Tiger-Point', 'Trincomalee', 'Trivandrum',
      'Trombay-Bombay', 'Tuticorin', 'Umbargaon', 'Vasai', 'Vengurla', 'Vijyadurg', 'Vishakapatnam',
      'Mingalakyun', 'Muttam', 'Navinal-Point', 'Palshet', 'Achra', 'Alleppey', 'Ambheta', 'AndrewBay',
      'Arnala', 'Bandra', 'Bankot', 'Baruva', 'Bassein-River', 'Beypore', 'Bhatkal', 'Bhavnagar1',
      'Bhavnagar2', 'Bhimunipatnam', 'Bombay-Apollo-Bandar', 'Bombay-Princes-Dock', 'Boria-Bay',
      'Bulsar', 'Bundal-Island', 'Calicut', 'Cannanore', 'Car-Nicobar', 'Chandbali', 'Chaungtha-Kyaung-Tha',
      'Chilka-Mouth', 'Chittagong', 'Cinque-Island', 'Cleugh-Passage', 'Colombo', 'Coondapore-Ganguli',
      'Coxs-Bazar', 'Cuddalore', 'Dabhol', 'Dahej-Bandar', 'Delft-Island', 'Devgarh', 'Devi-River-Entrance',
      'Dhamra', 'Diamond-Harbour', 'Diego-Garcia', 'Dring-Harbour', 'Dwarka-Rupen-Bandar', 'Egmont-Island',
      'Expedition-Harbour', 'False-Point', 'Galle', 'Ghizri-Creek', 'Gopalpur', 'Goyangyi-Kyun', 'Gwa-Bay',
      'Hansthal-Point', 'Hasan-Point', 'Hazira', 'Hoare-Bay', 'Ihavandhoo', 'Jafarabad', 'Jaigarh',
      'Jalebar', 'Janjira-Dangri-Bandar', 'Kachchaitivu', 'Kalingapatnam', 'Kalpitiya', 'Kandla-Harbour',
      'Karachi', 'Karwar', 'Kasargod', 'Kavaratti-Laccadive', 'Kelve-Mahim', 'Khal-No18', 'Kolachal',
      'Koteshwar', 'Kotra', 'Kulasekarapatnam', 'Kumta', 'Kushbhadra-River', 'Kutubdia-Island', 'Kyauk-Pyu',
      'Lakhpat', 'Lee-Puram', 'Long-Island', 'Chennai', 'Malpe', 'Malvan', 'Akyab', 'Azhikal', 'Betul',
      'Boat-Island', 'Calcutta-Kidderpore-docks', 'Chaungwa', 'Kochi', 'Dahanu', 'Dhulasar', 'Eagle-Island',
      'Godia-Creek', 'Harnai', 'Jaffna', 'Kakinada', 'Mandvi'
  ];

  final TextEditingController _searchController = TextEditingController();
  List _filteredStations = [];
  String? _selectedStation;
  dynamic _fullApiResponse;
  bool _isLoading = false;
  String? _errorMessage;

  static const String API_KEY = '446d183e64e64e8eb4bca1407ab02a89';
  static const String BASE_URL = 'https://gemini.incois.gov.in/incoisapi/rest/high-low';

  @override
  void initState() {
    super.initState();
    _filteredStations = stations;
  }

  void _searchStations(String query) {
    setState(() {
      _filteredStations = stations
          .where((station) => station.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future _fetchTidePredictions(String station) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fullApiResponse = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/$station'),
        headers: {'Authorization': API_KEY},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _fullApiResponse = data;
          _isLoading = false;
        });

        // Navigate to TideScreen with the fetched data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TideScreen(predictionsData: _fullApiResponse),
          ),
        );
      } else {
        throw Exception('Failed to load tide predictions: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tidal Forecast'),
        backgroundColor: const Color.fromARGB(255, 149, 209, 244),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Coastal Region',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchStations,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStations.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.lightBlue.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      _filteredStations[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
                    onTap: () {
                      setState(() {
                        _selectedStation = _filteredStations[index];
                      });
                      _fetchTidePredictions(_selectedStation!);
                    },
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
