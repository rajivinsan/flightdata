import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Flight {
  int flightid;
  String flightNumber;
  String departureStation;
  String arrivalStation;
  String departureTime;
  String arrivalTime;
  String date;
  String availableSeats;
  int col;
  String TotJournay;
  String Layovertime;

  Flight({
    required this.flightid,
    required this.flightNumber,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.date,
    required this.availableSeats,
    required this.col,
    required this.TotJournay,
    required this.Layovertime,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightid: json['Flightid'],
      flightNumber: json['flight_number'],
      departureStation: json['departure_station'],
      arrivalStation: json['arrival_station'],
      departureTime: json['departure_time'],
      arrivalTime: json['arrival_time'],
      date: json['date'],
      availableSeats: json['available_seats'],
      //for temp color
      col: json['col'],
      TotJournay: json['Tot'],
      Layovertime: json['layover'],
    );
  }
}

class FlightListPage extends StatefulWidget {
  @override
  _FlightListPageState createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  List<Flight> _flights = [];
  List<Flight> flights = [];
  List<String> _departureStations = [];
  List<String> _arrivalStations = [];
  String _selectedDepartureStation = 'All';
  String _selectedArrivalStation = 'All';
  bool _direct = false;
  String error = '';
  bool listviewloading = true;

  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    // _loadFlightsFromApi();
    _controller.text = "2";
    _loadFlightsFromJson();
  }

  void _loadFlightsFromJson() async {
    try {
      String data = await rootBundle.loadString('assets/flightdata.json');
      List<dynamic> flightsJson = jsonDecode(data);
      List<Flight> flights =
          flightsJson.map((json) => Flight.fromJson(json)).toList();
      List<String> departureStations =
          flights.map((flight) => flight.departureStation).toSet().toList();
      departureStations.sort();
      List<String> arrivalStations =
          flights.map((flight) => flight.arrivalStation).toSet().toList();
      arrivalStations.sort();
      setState(() {
        _flights = flights;
        _departureStations = ['All'] + departureStations;

        _arrivalStations = ['All'] + arrivalStations;
        error = _flights.length.toString();
      });
    } on Exception catch (_, ex) {
      setState(() {
        error = ex.toString();
      });
    }
  }

  // void _loadFlightsFromApi() async {
  //   final response = await http.get(Uri.parse(
  //       'https://s5.aconvert.com/convert/p3r68-cdx67/ic45d-eh8i4.json'));

  //   if (response.statusCode == 200) {
  //     final List<dynamic> flightsJson = jsonDecode(response.body);
  //     List<Flight> flights =
  //         flightsJson.map((json) => Flight.fromJson(json)).toList();
  //     List<String> departureStations =
  //         flights.map((flight) => flight.departureStation).toSet().toList();
  //     departureStations.sort();
  //     List<String> arrivalStations =
  //         flights.map((flight) => flight.arrivalStation).toSet().toList();
  //     arrivalStations.sort();
  //     setState(() {
  //       _flights = flights;
  //       _departureStations = ['All'] + departureStations;
  //       _arrivalStations = ['All'] + arrivalStations;
  //     });
  //   } else {
  //     throw Exception('Failed to load flights from API');
  //   }
  // }

  void _getFilteredFlights() {
    List<Flight> filtterflight = [];
    if (_selectedDepartureStation == 'All' &&
        _selectedArrivalStation == 'All') {
      _flights.forEach((element) {
        element.col = 0;
        element.TotJournay = "";
        element.Layovertime = "";
      });
      flights = _flights;
    } else if (_selectedDepartureStation == 'All' &&
        _selectedArrivalStation != 'All') {
      _flights.forEach((element) {
        element.col = 0;
        element.TotJournay = "";
        element.Layovertime = "";
      });
      var fl = _flights
          .where((flight) => flight.arrivalStation == _selectedArrivalStation)
          .toList();
      flights = fl;
    } else if (_selectedDepartureStation != 'All' &&
        _selectedArrivalStation == 'All') {
      _flights.forEach((element) {
        element.col = 0;

        element.TotJournay = "";
        element.Layovertime = "";
      });
      var fl = _flights
          .where(
              (flight) => flight.departureStation == _selectedDepartureStation)
          .toList();
      flights = fl;
    } else {
      // if (!_direct) {
      //   var direct = _flights
      //       .where((flight) =>
      //           flight.departureStation == _selectedDepartureStation &&
      //           flight.arrivalStation == _selectedArrivalStation)
      //       .toList();
      //   return direct;
      // } else
      {
        List<Flight> routeflight = [];
        var direct = _flights
            .where((flight) =>
                flight.departureStation == _selectedDepartureStation &&
                flight.arrivalStation == _selectedArrivalStation)
            .toList();

        routeflight = direct;
        routeflight.forEach((element) {
          element.col = 0;
        });

        var listflight = _flights
            .where((flight) =>
                flight.departureStation == _selectedDepartureStation)
            .toList();

        var flightall = _flights
            .where((flight) => flight.arrivalStation == _selectedArrivalStation)
            .toList();

        int i = 1;
        int ix = 0;
        listflight.forEach((element) => {
              flightall.forEach((element1) {
                var startTime = _StringToTime(element.arrivalTime);
                var currentTime = _StringToTime(element1.departureTime);
                if (element1.departureStation == element.arrivalStation &&
                    element1.arrivalStation == _selectedArrivalStation &&
                    currentTime!.difference(startTime!).inMinutes > 10 &&
                    currentTime.difference(startTime).inHours <
                        num.parse(_controller.value.text.isEmpty
                            ? '0'
                            : _controller.text)) {
                  // flightall[index1].col = i;
                  // listflight[index].col = i;
                  // //element1.col = i;
                  // //element.col = i;

                  var sTime = _StringToTime(element.departureTime.isEmpty
                      ? '0'
                      : element.departureTime);
                  var cTime = _StringToTime(element1.arrivalTime.isEmpty
                      ? '0'
                      : element1.arrivalTime);

                  element1.TotJournay =
                      durationToString(cTime!.difference(sTime!).inMinutes);

                  element1.Layovertime = durationToString(
                      currentTime.difference(startTime).inMinutes);

                  routeflight.add(element);
                  routeflight.elementAt(routeflight.indexOf(element)).col = i;

                  routeflight.add(element1);

                  routeflight.elementAt(routeflight.indexOf(element1)).col = i;
                  i++;
                  ix += 2;
                }
              })
            });
        listviewloading = true;
        flights = routeflight;
      }
    }
  }

  List<Flight> _getFilteredFlights1() {
    {
      var flightall = _flights.toList();
      List<Flight> listflight = [];
      List<Flight> filtterflight = [];
      if (_selectedDepartureStation == 'All' &&
          _selectedArrivalStation == 'All') {
        return _flights;
      } else if (_selectedDepartureStation != 'All' &&
          _selectedArrivalStation != 'All') {
        listflight = _flights
            .where((flight) =>
                flight.departureStation == _selectedDepartureStation)
            .toList();

        flightall.forEach((element) => {
              listflight.forEach((element1) {
                if (element.departureStation == element1.arrivalStation &&
                    element.arrivalStation == _selectedArrivalStation) {
                  filtterflight.add(element1);
                  filtterflight.add(element);
                } else {}
              })
            });
        return filtterflight;
      } else {
        listflight = _flights
            .where((flight) =>
                flight.departureStation == _selectedDepartureStation)
            .toList();

        return listflight;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flight Data"),
      ),
      body: _flights.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton(
                        value: _selectedDepartureStation,
                        items: _departureStations
                            .map((station) => DropdownMenuItem(
                                  child: Text(station),
                                  value: station,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartureStation = value.toString();
                          });
                        },
                        hint: Text('Select Departure Station'),
                      ),
                      DropdownButton(
                        value: _selectedArrivalStation,
                        items: _arrivalStations
                            .map((station) => DropdownMenuItem(
                                  child: Text(station),
                                  value: station,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedArrivalStation = value.toString();
                          });
                        },
                        hint: Text('Select Arrival Station'),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 10),
                      child: Text('Layovertime (Hrs)'),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                          onEditingComplete: () => setState(() {}),
                          keyboardType: TextInputType.number,
                          controller: _controller),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _getFilteredFlights();
                          });
                        },
                        child: Text("Filter"),
                      ),
                    ),
                  ],
                ),
                Divider(height: 18),
                Expanded(
                  child: ListView.builder(
                    itemCount: flights.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            tileColor: flights[index].col == 0
                                ? setcolor(0)
                                : setcolor(index + 1),
                            title: Text(
                                //'${(index + 1).toString()}) '
                                //'${flights[index].col}\n'
                                '${flights[index].flightNumber}'
                                '  ${flights[index].departureStation}'
                                ' ${flights[index].departureTime}'
                                ' -- ${flights[index].arrivalStation}'
                                ': ${flights[index].arrivalTime}\n'
                                '${flights[index].TotJournay.isNotEmpty ? '\n Total Journery: ${flights[index].TotJournay} ' : ''}'
                                ' ${flights[index].Layovertime.isNotEmpty ? ' Layover :${flights[index].Layovertime}' : ''}'),
                            trailing: Text(
                              '${flights[index].availableSeats} seats',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          flights[index].TotJournay.isNotEmpty ||
                                  flights[index].col == 0
                              ? Divider()
                              : Container(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

Color setcolor(int value) {
  Color set = Colors.white;
  if (value == null) {
    set = Colors.white;
    return set;
  }
  if (value == 0) {
    set = Colors.greenAccent;
  } else {
    if (value % 2 == 0) {
      set = Colors.orange.shade200;
    } else {
      set = Colors.lightBlue.shade300;
    }
  }
  return set;
}

DateTime? _StringToTime(String time) {
  DateTime? _dateTime;

  try {
    _dateTime = DateFormat("HH:mm").parse(time);
  } catch (e) {}
  return _dateTime;
}

String durationToString(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}
