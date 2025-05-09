import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/controllers/notification_controller.dart'; 
import 'package:tutor_app/views/notifications_view.dart';
import 'student_profile_screen.dart';
import '../controllers/student_home_controller.dart';
import '../controllers/filter_controller.dart'; 
import '../controllers/student_tutoring_sessions_controller.dart';
import '../views/filter_modal.dart'; 

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  DateTime? _screenLoadTime;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _screenLoadTime = DateTime.now();
    preloadNotifications();
    preloadStudentSessions(); 
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Remove listener
    _scrollController.dispose(); // Dispose controller
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) { 
      final controller = Provider.of<StudentHomeController>(context, listen: false);
       if (controller.state != StudentHomeState.loadingNextPage && controller.hasMorePages) {
            controller.loadOrderedSessions();
       }
    }
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
                // --- Filter Controls Row ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                  child: Row(
                    children: [
                      // Filter Button
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
                         onPressed: () async {
                           final filterController =
                               Provider.of<FilterController>(context, listen: false);
                           await filterController.loadFilterOptions();

                           showModalBottomSheet(
                             context: context,
                             isScrollControlled: true,
                             backgroundColor: Colors.transparent,
                             builder: (_) {
                               return FilterModal(
                                 onFilter:
                                     (university, course, professor) async {
                                   if (university.isNotEmpty) { await filterController.registerFilterUsed(university);}
                                   if (course.isNotEmpty) { await filterController.registerFilterUsed(course); }
                                   if (professor.isNotEmpty) { await filterController.registerFilterUsed(professor);}

                                   controller.applyFiltersAndUpdate(
                                       university, course, professor);
                                 },
                               );
                             },
                           );
                         },
                       ),
                       const SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reload"),
                      onPressed: () {
                        controller.loadOrderedSessions(loadFirstPage: true);
                      },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF171F45),
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(20),
                         ),
                       ),
                    ),
                  ),
                const SizedBox(height: 10),
                // Sessions
                Expanded(
                  child: Builder(
                    builder: (_) {
                      // Handle initial loading state
                      if (controller.state == StudentHomeState.loading && controller.sessions.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (controller.state == StudentHomeState.error && controller.sessions.isEmpty) {
                        // Show error only if there are no sessions to display
                        return Center(
                          child:
                              Text(controller.errorMessage ?? "Unknown error"),
                        );
                      } else if (controller.sessions.isEmpty && controller.state != StudentHomeState.loading) { 
                        return const Center(
                            child: Text("No available sessions found."));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: controller.sessions.length +
                            (controller.state == StudentHomeState.loadingNextPage ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.sessions.length &&
                              controller.state == StudentHomeState.loadingNextPage) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                           if (index >= controller.sessions.length) {
                               return const SizedBox.shrink(); 
                           }

                          final session = controller.sessions[index];
                          return buildSessionCard(session, controller);
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

  Widget buildIconButton({required IconData icon, required VoidCallback onPressed}) {
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
                onPressed: () async {
                  final timeToBook = DateTime.now()
                      .difference(_screenLoadTime!)
                      .inMilliseconds;
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
  }
}
