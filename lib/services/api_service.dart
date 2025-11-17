import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';

class ApiService {
  static const String baseUrl = 'http://156.67.31.137:3000/api/flights';

  Future<List<Flight>> fetchFlights(Map<String, String> query) async {
    Uri uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List flightsList = decoded("flights");
      return flightsList.map((e) => Flight.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load flights');
    }
  }
}