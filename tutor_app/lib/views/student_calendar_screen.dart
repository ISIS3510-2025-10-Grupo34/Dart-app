import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/calendar_appointment_model.dart';
import '../services/calendar_appointment_service.dart';
import '../providers/auth_provider.dart';
import 'appointment_detail_screen.dart';

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  late CalendarAppointmentService _calendarAppointmentService;
  late AuthProvider _authProvider;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarAppointment>> _appointments = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calendarAppointmentService = CalendarAppointmentService();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _selectedDay = _focusedDay;
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final studentId = _authProvider.currentUser?.id;
      if (studentId == null) {
        throw Exception("Student ID not found. Please log in again.");
      }
      final int ownerId = int.parse(studentId);
      final fetchedAppointments =
          await _calendarAppointmentService.fetchCalendarAppointments(ownerId);

      final Map<DateTime, List<CalendarAppointment>> events = {};
      for (var appointment in fetchedAppointments) {
        final day = DateTime.utc(appointment.date.year, appointment.date.month,
            appointment.date.day);
        if (events[day] == null) {
          events[day] = [];
        }
        events[day]!.add(appointment);
      }
      setState(() {
        _appointments = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching appointments: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  List<CalendarAppointment> _getEventsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Color _getColorForDay(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) return Colors.transparent;
    if (events.length == 1) return Colors.blue.shade100;
    if (events.length == 2) return Colors.blue.shade300;
    return Colors.blue.shade500;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      final events = _getEventsForDay(selectedDay);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetailScreen(
            selectedDate: selectedDay,
            appointments: events,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLegend(),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(child: Center(child: Text(_errorMessage!)))
          else
            TableCalendar<CalendarAppointment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: const BoxDecoration(
                  color: Colors.transparent, // Hide default markers
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _getColorForDay(day),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                      border: isSameDay(day, DateTime.now())
                          ? Border.all(
                              color: Theme.of(context).primaryColor, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                            color: isSameDay(day, _selectedDay)
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _getColorForDay(day)
                          .withOpacity(0.7), // Slightly different for selection
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.deepPurple, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _getColorForDay(day),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.redAccent, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                            color: isSameDay(day, _selectedDay)
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  );
                },
              ),
              onDaySelected: _onDaySelected,
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
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 5.0,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(Colors.blue.shade100, "1 Appointment"),
        _legendItem(Colors.blue.shade300, "2 Appointments"),
        _legendItem(Colors.blue.shade500, "3+ Appointments"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
