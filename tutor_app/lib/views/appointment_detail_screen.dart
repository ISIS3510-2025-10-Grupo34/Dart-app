import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_appointment_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarAppointment> appointments;

  const AppointmentDetailScreen({
    super.key,
    required this.selectedDate,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Appointments for ${DateFormat.yMMMd().format(selectedDate)}'),
      ),
      body: appointments.isEmpty
          ? const Center(
              child: Text(
                'No appointments for this day.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.event_note,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      appointment.courseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Tutor: ${appointment.tutorName}'),
                        Text(
                            'Time: ${DateFormat.jm().format(appointment.dateTime)}'), // Display time
                        Text('Cost: \$${appointment.cost.toStringAsFixed(0)}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
