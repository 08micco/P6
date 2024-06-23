// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csr/screens/reservation_screen.dart';

class ReservationCalendarScreen extends StatefulWidget {
  final int chargingPointId;

  const ReservationCalendarScreen({super.key, required this.chargingPointId});

  @override
  _ReservationCalendarState createState() => _ReservationCalendarState();
}

class _ReservationCalendarState extends State<ReservationCalendarScreen> {
  final _storage = const FlutterSecureStorage();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<DateTimeRange>> _reservations = {};
  List<DateTimeRange> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchReservations();
  }

  static DateTime _parseDateTime(String rawDate) {
    try {
        DateTime utcDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(rawDate);
        return DateTime(utcDate.year, utcDate.month, utcDate.day, utcDate.hour, utcDate.minute, utcDate.second);
    } catch (e) {
        return DateTime.now();
    }
}

  String formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Future<void> _fetchReservations() async {
    try {
      var url = Uri.parse(
          'http://127.0.0.1:5000/reservations/get?charging_point_id=${widget.chargingPointId}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'] as List;
        var reservations = data
            .map((res) => {
                  'reservation_start_time': res['reservation_start_time'],
                  'reservation_end_time': res['reservation_end_time'],
                })
            .toList();

        setState(() {
          _reservations = _groupReservationsByDay(reservations);
        });
      } else {
        _showSnackBar(
            "Failed to fetch reservations: Status code ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Failed to fetch reservations: Error $e");
    }
    _reservations[DateTime.now()] = [
      DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(hours: 1)),
      ),
    ];
    _calculateAvailableSlots();
  }

  void _calculateAvailableSlots() {
    if (_selectedDay != null) {

      DateTime normalizedSelectedDay =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      List<DateTimeRange> reservedSlots =
          _reservations[normalizedSelectedDay] ?? [];

      DateTime startOfDay =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      DateTime endOfDay = DateTime(
          _selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 23, 45);

      List<DateTimeRange> allSlots = [];
      DateTime currentTime = startOfDay;
      while (currentTime.isBefore(endOfDay)) {
        DateTime endTime = currentTime.add(const Duration(minutes: 30));
        allSlots.add(DateTimeRange(start: currentTime, end: endTime));
        currentTime = endTime;
      }

      _availableSlots = allSlots.where((slot) {
        return !reservedSlots.any((reserved) =>
            (slot.start.isBefore(reserved.end) &&
                slot.end.isAfter(reserved.start)));
      }).toList();

      setState(() {});
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Map<DateTime, List<DateTimeRange>> _groupReservationsByDay(
      List<dynamic> reservations) {
    Map<DateTime, List<DateTimeRange>> grouped = {};
    for (var reservation in reservations) {
      DateTime start = _parseDateTime(reservation['reservation_start_time']);
      DateTime end = _parseDateTime(reservation['reservation_end_time']);
      DateTime day = DateTime(
          start.year, start.month, start.day);

      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(DateTimeRange(start: start, end: end));
    }
    return grouped;
  }

  Future<void> bookChargingPoint(DateTime startTime, DateTime endTime) async {
    String? userId = await _storage.read(key: "userId");
    if (userId == null) {
      _showSnackBar("User not logged in");
      return;
    }

    final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/reservation/new/${widget.chargingPointId}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        "user_id": userId,
        "reservation_start_time": startTime.toString(),
        "reservation_end_time": endTime.toString(),
        "reservation_time": 30,
      }));
        

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 6000),
        backgroundColor: Colors.green,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text("Successfully booked for 30 minutes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservationsScreen()),
                );
              },
              child: const Text(
                "View Reservations",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        ));
        _fetchReservations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to book the charging point"),
        backgroundColor: Colors.red,
        duration:  Duration(milliseconds: 6000),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Reservation Date'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.blue, Color.fromARGB(255, 142, 200, 247)],
              stops: [0.5, 0.9],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
                _calculateAvailableSlots();
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _availableSlots.length,
              itemBuilder: (context, index) {
                DateTimeRange slot = _availableSlots[index];
                return ListTile(
                  title: Text(
                      '${DateFormat('HH:mm').format(slot.start)} - ${DateFormat('HH:mm').format(slot.end)}'),
                  onTap: () => bookChargingPoint(slot.start, slot.end),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
