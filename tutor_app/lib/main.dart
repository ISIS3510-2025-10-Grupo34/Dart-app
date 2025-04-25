// main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/services/area_of_expertise_service.dart';

// Services
import 'package:tutor_app/services/auth_service.dart';
import 'package:tutor_app/services/tutor_service.dart';
import 'package:tutor_app/services/user_service.dart';
import 'package:tutor_app/services/tutoring_session_service.dart';
import 'package:tutor_app/services/metrics_service.dart';
import 'package:tutor_app/services/universities_service.dart';
import 'package:tutor_app/services/majors_service.dart';
import 'package:tutor_app/services/filter_service.dart';
import 'package:tutor_app/services/course_service.dart';
import 'package:tutor_app/services/review_service.dart';
import 'package:tutor_app/services/sync_service.dart';
import 'package:tutor_app/services/local_cache_service.dart';
import 'package:tutor_app/services/location_service.dart';
import 'package:tutor_app/services/student_tutoring_sessions_service.dart';

// Controllers & Providers
import 'package:tutor_app/providers/auth_provider.dart';
import 'package:tutor_app/providers/sign_in_process_provider.dart';
import 'package:tutor_app/controllers/login_controller.dart';
import 'package:tutor_app/controllers/sign_in_controller.dart';
import 'package:tutor_app/controllers/student_home_controller.dart';
import 'package:tutor_app/controllers/learning_styles_controller.dart';
import 'package:tutor_app/controllers/profile_picture_controller.dart';
import 'package:tutor_app/controllers/university_id_controller.dart';
import 'package:tutor_app/controllers/student_sign_in_controller.dart';
import 'package:tutor_app/controllers/tutor_profile_controller.dart';
import 'package:tutor_app/controllers/tutor_sign_in_controller.dart';
import 'package:tutor_app/controllers/student_profile_controller.dart';
import 'package:tutor_app/controllers/filter_controller.dart';
import 'package:tutor_app/controllers/student_tutoring_sessions_controller.dart';
import 'package:tutor_app/controllers/write_review_controller.dart';

// UI
import 'package:tutor_app/views/welcome_screen.dart';
import 'utils/env_config.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  final authService = AuthService();
  final tutorService = TutorService();
  final courseService = CourseService();
  final userService = UserService();
  final reviewService = ReviewService();
  final aoeService = AreaOfExpertiseService();
  final tutoringSessionService = TutoringSessionService();
  final metricsService = MetricsService();
  final studentTutoringSessionsService = StudentTutoringSessionsService();
  final universitiesService = UniversitiesService();
  final majorsService = MajorsService();
  final localCacheService = LocalCacheService();
  final locationService = LocationService();

  final authProvider = AuthProvider(userService: userService);
  final signInProcessProvider = SignInProcessProvider(userService: userService);

  runApp(
    MultiProvider(
      providers: [
        // Core Services
        Provider<AuthService>.value(value: authService),
        Provider<TutorService>.value(value: tutorService),
        Provider<CourseService>.value(value: courseService),
        Provider<UserService>.value(value: userService),
        Provider<UniversitiesService>.value(value: universitiesService),
        Provider<MajorsService>.value(value: majorsService),
        Provider<ReviewService>.value(value: reviewService),
        Provider<AreaOfExpertiseService>.value(value: aoeService),
        Provider<StudentTutoringSessionsService>.value(
            value: studentTutoringSessionsService),
        Provider<TutoringSessionService>.value(value: tutoringSessionService),
        Provider<MetricsService>.value(value: metricsService),
        Provider<LocalCacheService>.value(value: localCacheService),
        Provider<LocationService>.value(value: locationService),

        // Sync
        Provider<SyncService>(
          create: (context) => SyncService(
            scaffoldMessengerKey: scaffoldMessengerKey,
            reviewService: context.read<ReviewService>(),
            cacheService: context.read<LocalCacheService>(),
            locationService: context.read<LocationService>(),
          ),
        ),

        // Auth & Sign-In Flow
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SignInProcessProvider>.value(
            value: signInProcessProvider),

        ChangeNotifierProvider(
          create: (context) => LoginController(
            authService: context.read<AuthService>(),
            authProvider: context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SignInController(
            context.read<SignInProcessProvider>(),
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentHomeController(
            tutorService: context.read<TutorService>(),
            authProvider: context.read<AuthProvider>(),
            sessionService: context.read<TutoringSessionService>(),
            metricsService: context.read<MetricsService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LearningStylesController(context.read<SignInProcessProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ProfilePictureController(context.read<SignInProcessProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              UniversityIdController(context.read<SignInProcessProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentSignInController(
            context.read<SignInProcessProvider>(),
            context.read<UniversitiesService>(),
            context.read<MajorsService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TutorProfileController(
            authProvider: context.read<AuthProvider>(),
            userService: context.read<UserService>(),
            sessionService: context.read<TutoringSessionService>(),
            universitiesService: context.read<UniversitiesService>(),
            courseService: context.read<CourseService>(),
            tutorService: context.read<TutorService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TutorSignInController(
            context.read<SignInProcessProvider>(),
            context.read<UniversitiesService>(),
            context.read<AreaOfExpertiseService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FilterController(filterService: FilterService()),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentProfileController(
            authProvider: authProvider,
            reviewService: reviewService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentTutoringSessionsController(
            studentTutoringSessionsService: studentTutoringSessionsService,
            authProvider: authProvider,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WriteReviewController(
            reviewService: context.read<ReviewService>(),
            userService: context.read<UserService>(),
            cacheService: context.read<LocalCacheService>(),
          ),
        ),
      ],
      child: const TutorApp(),
    ),
  );
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService =
        context.read<SyncService>(); // 👈 Garantiza construcción
    debugPrint("🧠 SyncService initialized in main");
    Future.microtask(() {
      context.read<SyncService>().syncPendingData();
    });

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'TutorApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          switch (authProvider.authState) {
            case AuthState.authenticated:
              return const WelcomeScreen();
            case AuthState.unauthenticated:
            case AuthState.unknown:
              return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
