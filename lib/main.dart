import 'package:flutter/material.dart';
import 'pages/search_page.dart';

void main() {
  runApp(const FlightApp());
}

class FlightApp extends StatelessWidget {
  const FlightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Availability App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SearchPage(),
    );
  }
}