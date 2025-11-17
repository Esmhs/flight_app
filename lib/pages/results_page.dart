import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> multiCityQuery;
  final Map<String, String> filters;

  const ResultsPage({
    super.key,
    required this.multiCityQuery,
    required this.filters,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool isLoading = true;
  bool hasError = false;
  List<dynamic> flights = [];

  @override
  void initState() {
    super.initState();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    setState(() {
      isLoading = true;
      hasError = false;
      flights = [];
    });

    try {
      List<dynamic> allFlights = [];

      for (final segment in widget.multiCityQuery) {
        String url =
            'http://156.67.31.137:3000/api/flights?from=${segment['from']}&to=${segment['to']}&date=${segment['date']}';

        widget.filters.forEach((key, value) {
          url += '&$key=$value';
        });

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is Map && data.containsKey("flights")) {
            allFlights.addAll(data["flights"]);
          }
        } else {
          throw Exception('API returned error status');
        }
      }

      setState(() {
        flights = allFlights;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Widget buildFlightCard(dynamic flight) {
    final id = flight['id']?.toString() ?? 'N/A';
    final airline = flight['carrier'] ?? 'Unknown';
    final time = flight['time'] ?? '';
    // final arrivalTime = flight['arrivalTime'] ?? '';
    final price = flight['price'] != null ? '\$${flight['price']}' : 'N/A';
    final logo = flight['carrierLogo'] ?? 'default';
    // final stops = flight['stops'] ?? 0;
    // final stopsText = stops == 0 ? 'Direct' : '$stops stop${stops > 1 ? 's' : ''}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Airline logo
            SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                logo,
                errorBuilder: (_, __, ___) => const Icon(Icons.flight),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            // Flight info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flight ID: $id · $airline',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Direct",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Price & favorite icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.favorite_border),
                //   onPressed: () {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Added to favorites')),
                //     );
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (hasError) {
      return const Center(
        child: Text(
          'Failed to load flights.\nPlease try again later.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    } else if (flights.isEmpty) {
      return const Center(
        child: Text(
          'No flights found for your search.',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: flights.length,
        itemBuilder: (context, index) {
          return buildFlightCard(flights[index]);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.multiCityQuery.isNotEmpty
        ? '${widget.multiCityQuery[0]['from']} → ${widget.multiCityQuery[0]['to']}'
        : 'Flight Results';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: buildBody(),
    );
  }
}