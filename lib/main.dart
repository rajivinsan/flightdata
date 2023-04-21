import 'package:flight_data/flight.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlightListPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/flightList');
          },
          child: Text('View Flights'),
        ),
      ),
    );
  }
}
