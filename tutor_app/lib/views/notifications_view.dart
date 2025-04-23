import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController controller = NotificationController();
  List<NotificationModel> notifications = [];
  String? selectedUniversity;
  bool isLoading = false;

  final List<String> universityNames = [
    "Universidad Nacional",
    "Universidad de los Andes",
    "Pontificia Universidad Javeriana",
    "Universidad del Rosario",
    "Universidad de la Sabana",
  ];

  Future<void> loadNotifications(String universityName) async {
    setState(() => isLoading = true);

    try {
      final data = await controller.fetchNotificationsByUniversity(universityName);
      setState(() => notifications = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar notificaciones: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    notifications.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF171F45),
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF171F45)),
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Selecciona una universidad",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedUniversity,
              items: universityNames.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedUniversity = value);
                  loadNotifications(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (notifications.isEmpty && selectedUniversity != null)
              Expanded(
                child: Center(
                  child: Text(
                    "No hay notificaciones para esta universidad.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return NotificationCard(notification: notifications[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(notification.date);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF171F45),
                    )),
            const SizedBox(height: 8),
            Text(notification.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF171F45),
                    )),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notification.place,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF171F45),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF171F45),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
