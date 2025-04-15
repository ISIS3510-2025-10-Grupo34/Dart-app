import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/views/notifications_view.dart';
import 'student_profile_screen.dart';
import '../controllers/student_home_controller.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  DateTime? _screenLoadTime;

  @override
  void initState() {
    super.initState();
    _screenLoadTime = DateTime.now();  // Asegúrate de inicializar _screenLoadTime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentHomeController>(context, listen: false)
          .loadAvailableTutoringSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<StudentHomeController>(
          builder: (context, controller, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------- Header -----------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TutorApp",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          // Notifications Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF171F45),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                                );
                              },
                              iconSize: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Profile Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF171F45),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.person, color: Colors.white),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
                                );
                              },
                              iconSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ---------------------------- Filter Button ----------------------------
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF171F45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: const Text(
                      "Filter results",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ---------------------------- Session List ----------------------------
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (controller.state == StudentHomeState.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (controller.state == StudentHomeState.error) {
                        return Center(
                          child: Text(controller.errorMessage ?? "Unknown error"),
                        );
                      } else if (controller.sessions.isEmpty) {
                        return const Center(child: Text("No available sessions."));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: controller.sessions.length,
                        itemBuilder: (context, index) {
                          final session = controller.sessions[index];
                          return Card(
                            color: const Color(0xFFFDF7FF),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF171F45),
                                        child: Text(
                                          session.tutorName[0],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        session.tutorName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final start = DateTime.now();
                                      await Future.delayed(const Duration(milliseconds: 300));
                                      final loadTime = DateTime.now().difference(start).inMilliseconds;
                                      await controller.sendTimeToBookMetric(loadTime);
                                    },
                                    child: Text(
                                      session.course,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    session.university,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Price: \$${session.cost}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "Date: ${session.dateTime}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final timeToBook = DateTime.now().difference(_screenLoadTime!).inMilliseconds;
                                        await controller.sendTimeToBookMetric(timeToBook);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF171F45),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        "Book",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
