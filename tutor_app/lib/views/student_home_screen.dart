import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/controllers/notification_controller.dart';
import 'package:tutor_app/utils/network_utils.dart';
import 'package:tutor_app/views/error_view.dart';
import 'package:tutor_app/views/notifications_view.dart';
import 'student_profile_screen.dart';
import '../controllers/student_home_controller.dart';
import '../controllers/filter_controller.dart';
import '../controllers/student_tutoring_sessions_controller.dart';
import '../views/filter_modal.dart';
import '../views/student_calendar_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

bool _hasInternet = true;
bool _showErrorView = false;

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  DateTime? _screenLoadTime;

  @override
  void initState() {
    super.initState();
    _screenLoadTime = DateTime.now();
    preloadNotifications();
    preloadStudentSessions();

    // Escuchar cambios en la conectividad
    Connectivity().onConnectivityChanged.listen((result) async {
      final isOnline = result != ConnectivityResult.none;
      setState(() {
        _hasInternet = isOnline;
        _showErrorView = !isOnline;
      });
    });

    _checkInitialInternet();
  }

  Future<void> _checkInitialInternet() async {
    final isOnline = await NetworkUtils.hasInternetConnection();
    setState(() {
      _hasInternet = isOnline;
      _showErrorView = !isOnline;
    });
  }

  void preloadNotifications() {
    final controller = NotificationController();
    final universityList = [
      "Universidad Nacional",
      "Universidad de los Andes",
      "Pontificia Universidad Javeriana",
      "Universidad del Rosario",
      "Universidad de la Sabana",
      "General",
    ];
    controller.preloadAllNotifications(universityList);
  }

  void preloadStudentSessions() {
    final sessionController =
        Provider.of<StudentTutoringSessionsController>(context, listen: false);
    sessionController.preloadStudentSessions();
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
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TutorApp",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          buildIconButton(
                            icon: Icons.calendar_month,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentCalendarScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          buildIconButton(
                            icon: Icons.notifications,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationsScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          buildIconButton(
                            icon: Icons.person,
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentProfileScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // --- Filter Controls Row + Internet warning ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text("Filter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _showErrorView
                                ? null
                                : () async {
                                    final hasInternet = await NetworkUtils.hasInternetConnection();
                                    if (!hasInternet) {
                                      setState(() => _showErrorView = true);
                                      return;
                                    }

                                    final filterController = Provider.of<FilterController>(context, listen: false);
                                    await filterController.loadFilterOptions();

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) {
                                        return FilterModal(
                                          onFilter: (university, course, professor) async {
                                            if (university.isNotEmpty) {
                                              await filterController.registerFilterUsed(university);
                                            }
                                            if (course.isNotEmpty) {
                                              await filterController.registerFilterUsed(course);
                                            }
                                            if (professor.isNotEmpty) {
                                              await filterController.registerFilterUsed(professor);
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Reload"),
                            onPressed: _showErrorView
                                ? null
                                : () async {
                                    final hasInternet = await NetworkUtils.hasInternetConnection();
                                    if (!hasInternet) {
                                      setState(() => _showErrorView = true);
                                      return;
                                    }
                                    final controller = Provider.of<StudentHomeController>(context, listen: false);
                                    await controller.reloadCurrentPage();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_showErrorView)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wifi_off, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "No internet connection detected. Filter, Reload, Book, Next and Previous buttons are disabled.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final hasInternet = await NetworkUtils.hasInternetConnection();
                                  setState(() {
                                    _showErrorView = !hasInternet;
                                  });
                                },
                                child: const Text("Retry"),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Sessions
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (controller.state == StudentHomeState.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (controller.state == StudentHomeState.error &&
                          controller.sessions.isEmpty) {
                        return ErrorView(
                          title: "Unable to load tutoring sessions",
                          message:
                              "No internet connection.\nPlease check your network and try again.",
                          icon: Icons.wifi_off,
                          onRetry: () {
                            //controller._loadSessions();
                          },
                        );
                      } else if (controller.sessions.isEmpty) {
                        return const Center(
                            child: Text("No available sessions found."));
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              itemCount: controller.sessions.length,
                              itemBuilder: (context, index) {
                                final session = controller.sessions[index];
                                return buildSessionCard(session, controller);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.chevron_left),
                                  label: const Text("Previous"),
                                  onPressed: controller.currentPage > 1 && !controller.isLoading && _hasInternet
                                      ? () => controller.loadPreviousPage()
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF171F45),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[700],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                                Text("Page ${controller.currentPage}"),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.chevron_right),
                                  label: const Text("Next"),
                                  onPressed: controller.hasNextPage && !controller.isLoading && _hasInternet
                                      ? () => controller.loadNextPage()
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF171F45),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[700],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget buildIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF171F45),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 20,
      ),
    );
  }

  Widget buildSessionCard(session, StudentHomeController controller) {
    return Card(
      color: const Color(0xFFFFFFFF),
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
                final loadTime =
                    DateTime.now().difference(start).inMilliseconds;
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
                onPressed: _hasInternet
                    ? () async {
                        final timeToBook = DateTime.now().difference(_screenLoadTime!).inMilliseconds;
                        await controller.sendTimeToBookMetric(timeToBook);
                      }
                    : null,
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
  }
}
