import 'package:flutter/material.dart';
import 'results_page.dart';

enum TripType { roundTrip, oneWay, multiCity }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;

  List<Map<String, dynamic>> multiCitySegments = [
    {'from': '', 'to': '', 'date': null}
  ];

  int travellers = 1;
  String travelClass = 'Economy';

  TripType tripType = TripType.roundTrip;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        tripType = TripType.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // ⭐️ UPDATED HERE → allows selecting past dates
  Future<void> _pickDate(BuildContext context,
      {required bool isDeparture, int? index}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),      // today
      firstDate: DateTime(1900),        // past allowed
      lastDate: DateTime(2100),         // future allowed
    );

    if (pickedDate != null) {
      setState(() {
        if (tripType == TripType.multiCity && index != null) {
          multiCitySegments[index]['date'] = pickedDate;
        } else {
          if (isDeparture) {
            _departureDate = pickedDate;
          } else {
            _returnDate = pickedDate;
          }
        }
      });
    }
  }

  void _swapFromTo() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  void _addMultiCitySegment() {
    setState(() {
      multiCitySegments.add({'from': '', 'to': '', 'date': null});
    });
  }

  void _removeMultiCitySegment(int index) {
    if (multiCitySegments.length <= 1) return;
    setState(() {
      multiCitySegments.removeAt(index);
    });
  }

  Widget _buildAirportInput(TextEditingController controller, String label) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.flight_takeoff),
          border: const OutlineInputBorder(),
          hintText: label,
        ),
        maxLength: 3,
      ),
    );
  }
  Widget _buildMultiCityInput(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: multiCitySegments[index]['from'],
                    onChanged: (val) =>
                    multiCitySegments[index]['from'] = val.toUpperCase(),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: multiCitySegments[index]['to'],
                    onChanged: (val) =>
                    multiCitySegments[index]['to'] = val.toUpperCase(),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLength: 3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _removeMultiCitySegment(index),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _pickDate(context, isDeparture: true, index: index),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      multiCitySegments[index]['date'] != null
                          ? _formatDate(
                          multiCitySegments[index]['date'] as DateTime)
                          : 'Select Date',
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _search() {
    if (tripType == TripType.roundTrip) {
      if (_fromController.text.isEmpty ||
          _toController.text.isEmpty ||
          _departureDate == null ||
          _returnDate == null) {
        _showError('Please fill all fields');
        return;
      }
    }
    else if (tripType == TripType.oneWay) {
      if (_fromController.text.isEmpty ||
          _toController.text.isEmpty ||
          _departureDate == null) {
        _showError('Please fill all fields');
        return;
      }
    }
    else if (tripType == TripType.multiCity) {
      for (final segment in multiCitySegments) {
        if ((segment['from'] ?? '').isEmpty ||
            (segment['to'] ?? '').isEmpty ||
            segment['date'] == null) {
          _showError('Please fill all multi-city segments');
          return;
        }
      }
    }

    List<Map<String, dynamic>> querySegments = [];

    if (tripType == TripType.roundTrip) {
      querySegments = [
        {
          'from': _fromController.text.toUpperCase(),
          'to': _toController.text.toUpperCase(),
          'date': _formatDate(_departureDate),
        },
        {
          'from': _toController.text.toUpperCase(),
          'to': _fromController.text.toUpperCase(),
          'date': _formatDate(_returnDate),
        },
      ];
    } else if (tripType == TripType.oneWay) {
      querySegments = [
        {
          'from': _fromController.text.toUpperCase(),
          'to': _toController.text.toUpperCase(),
          'date': _formatDate(_departureDate),
        }
      ];
    } else {
      querySegments = multiCitySegments
          .map((segment) => {
        'from': (segment['from'] ?? '').toString().toUpperCase(),
        'to': (segment['to'] ?? '').toString().toUpperCase(),
        'date': _formatDate(segment['date'] as DateTime?),
      })
          .toList();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          multiCityQuery: querySegments,
          filters: {},
        ),
      ),
    );
  }


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Round-trip'),
            Tab(text: 'One-way'),
            Tab(text: 'Multi-city'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoundTripTab(),
          _buildOneWayTab(),
          _buildMultiCityTab(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _search,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Search Flights', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildRoundTripTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildAirportInput(_fromController, 'From'),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 32),
                onPressed: _swapFromTo,
              ),
              _buildAirportInput(_toController, 'To'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context, isDeparture: true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_departureDate != null
                      ? _formatDate(_departureDate)
                      : 'Departure Date'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context, isDeparture: false),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_returnDate != null
                      ? _formatDate(_returnDate)
                      : 'Return Date'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTravellersAndClass(),
        ],
      ),
    );
  }
  Widget _buildOneWayTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildAirportInput(_fromController, 'From'),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 32),
                onPressed: _swapFromTo,
              ),
              _buildAirportInput(_toController, 'To'),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _pickDate(context, isDeparture: true),
            icon: const Icon(Icons.calendar_today),
            label: Text(_departureDate != null
                ? _formatDate(_departureDate)
                : 'Departure Date'),
          ),
          const SizedBox(height: 16),
          _buildTravellersAndClass(),
        ],
      ),
    );
  }

  Widget _buildMultiCityTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: multiCitySegments.length,
              itemBuilder: (context, index) => _buildMultiCityInput(index),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _addMultiCitySegment,
            icon: const Icon(Icons.add),
            label: const Text('Add Flight'),
          ),
          const SizedBox(height: 12),
          _buildTravellersAndClass(),
        ],
      ),
    );
  }

  Widget _buildTravellersAndClass() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: travellers,
            decoration: const InputDecoration(
              labelText: 'Travellers',
              border: OutlineInputBorder(),
            ),
            items: List.generate(9, (i) => i + 1)
                .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => travellers = val);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: travelClass,
            decoration: const InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
            ),
            items: ['Economy', 'Business', 'First']
                .map((cls) => DropdownMenuItem(value: cls, child: Text(cls)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => travelClass = val);
            },
          ),
        ),
      ],
    );
  }
}