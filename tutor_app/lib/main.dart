// lib/main.dart (Updated)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_app/controllers/student_tutoring_sessions_controller.dart';
import 'package:tutor_app/providers/sign_in_process_provider.dart';
import 'package:tutor_app/services/course_service.dart';
import 'package:tutor_app/services/review_service.dart';
import 'package:tutor_app/services/student_tutoring_sessions_service.dart';
import 'utils/env_config.dart';
import 'views/welcome_screen.dart';

// Import Services
import 'services/auth_service.dart';
import 'services/tutor_service.dart';
import 'services/user_service.dart';
import 'services/tutoring_session_service.dart';
import 'services/metrics_service.dart';
import 'services/universities_service.dart';
import 'services/majors_service.dart';
import 'services/filter_service.dart';
import 'services/review_service.dart';

// Import Providers/Controllers
import 'providers/auth_provider.dart';
import 'providers/sign_in_process_provider.dart';
import 'controllers/login_controller.dart';
import 'controllers/sign_in_controller.dart';
import 'controllers/student_home_controller.dart';
import 'controllers/learning_styles_controller.dart';
import 'controllers/profile_picture_controller.dart';
import 'controllers/university_id_controller.dart';
import 'controllers/student_sign_in_controller.dart';
import 'controllers/tutor_profile_controller.dart';
import 'controllers/tutor_sign_in_controller.dart';
import 'controllers/student_profile_controller.dart';
import 'services/student_tutoring_sessions_service.dart';
import 'controllers/filter_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();

  final authService = AuthService();
  final tutorService = TutorService();
  final courseService = CourseService();
  final userService = UserService();
  final reviewService = ReviewService();
  final tutoringSessionService = TutoringSessionService();
  final metricsService = MetricsService();
  final studentTutoringSessionsService = StudentTutoringSessionsService();
  final universitiesService = UniversitiesService();
  final majorsService = MajorsService();

  final authProvider = AuthProvider(userService: userService);
  final signInProcessProvider = SignInProcessProvider(userService: userService);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<TutorService>.value(value: tutorService),
        Provider<CourseService>.value(value: courseService),
        Provider<UserService>.value(value: userService),
        Provider<UniversitiesService>.value(value: universitiesService),
        Provider<MajorsService>.value(value: majorsService),
        Provider<ReviewService>.value(value: reviewService),
        Provider<StudentTutoringSessionsService>.value(
            value: studentTutoringSessionsService),
        Provider<TutoringSessionService>.value(value: tutoringSessionService),

        // Agrega el proveedor de MetricsService
        Provider<MetricsService>.value(value: metricsService),

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
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentHomeController(
            tutorService: context.read<TutorService>(),
            authProvider: context.read<AuthProvider>(),
            sessionService: context.read<TutoringSessionService>(),
            metricsService:
                context.read<MetricsService>(), // Proporciona MetricsService
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LearningStylesController(
            context.read<SignInProcessProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfilePictureController(
            context.read<SignInProcessProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UniversityIdController(
            context.read<SignInProcessProvider>(),
          ),
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
            sessionService:
                context.read<TutoringSessionService>(), // Agregado aquí
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TutorSignInController(
            context.read<SignInProcessProvider>(),
            context.read<UniversitiesService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FilterController(filterService: FilterService()),
        ),
        ChangeNotifierProvider(
            create: (context) => StudentProfileController(
                authProvider: authProvider, reviewService: reviewService)),
        ChangeNotifierProvider(
            create: (context) => StudentTutoringSessionsController(
                studentTutoringSessionsService: studentTutoringSessionsService,
                authProvider: authProvider))
      ],
      child: const TutorApp(),
    ),
  );
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutorApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthProvider>(builder: (context, authProvider, child) {
        switch (authProvider.authState) {
          case AuthState.authenticated:
            final role = authProvider.currentUser?.role;
            if (role == 'student') {
              return const WelcomeScreen();
            } else if (role == 'tutor') {
              return const WelcomeScreen();
            } else {
              return const WelcomeScreen();
            }
          case AuthState.unauthenticated:
          case AuthState.unknown:
            return const WelcomeScreen();
        }
      }),
    );
  }
}
