import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tutor_app/controllers/booked_sessions_controller.dart';
import 'misc/constants.dart';
import 'package:lru/lru.dart';
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
import 'package:tutor_app/services/profile_creation_time_service.dart';
import 'package:tutor_app/services/area_of_expertise_service.dart';
import 'package:tutor_app/services/local_database_service.dart';

// Controllers & Providers
import 'package:tutor_app/providers/auth_provider.dart';
import 'package:tutor_app/providers/sign_in_process_provider.dart';
import 'package:tutor_app/providers/create_tutoring_session_process_provider.dart';
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
import 'package:tutor_app/models/similar_tutor_review_model.dart';

// UI
import 'package:tutor_app/views/welcome_screen.dart';
import 'package:tutor_app/views/student_home_screen.dart';
import 'package:tutor_app/views/tutor_profile_screen.dart';

import 'utils/env_config.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

typedef SimilarTutorReviewsCache = LruCache<int, SimilarTutorReviewsResponse>;
typedef TimeToCreateProfile = LruCache<String, DateTime>;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox(HiveKeys.signUpProgressBox);
  await Hive.openBox(HiveKeys.sessionProgressBox);
  final similarTutorReviewsCache = SimilarTutorReviewsCache(10);
  //sqfliteFfiInit();
  //databaseFactory = databaseFactoryFfi;

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
  final profileCreationTimeService = ProfileCreationTimeService();
  final filterService = FilterService(); 

  final authProvider = AuthProvider(userService: userService);
  final signInProcessProvider = SignInProcessProvider(
    userService: userService,
    localCacheService: localCacheService,
  );
  await authProvider.tryRestoreSession();
  final createTutoringSessionProcessProvider = CreateTutoringSessionProcessProvider(
    sessionService: tutoringSessionService, 
    localCacheService: localCacheService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<FilterService>.value(value: filterService),
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
        Provider<ProfileCreationTimeService>.value(
            value: profileCreationTimeService),
        Provider<LocalDatabaseService>(
          create: (_) => LocalDatabaseService(),
        ),
        // Base providers
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<SignInProcessProvider>.value(
            value: signInProcessProvider),
        Provider<SimilarTutorReviewsCache>.value(
            value: similarTutorReviewsCache),
        ChangeNotifierProvider<CreateTutoringSessionProcessProvider>.value(
            value: createTutoringSessionProcessProvider),
      ],
      child: Builder(
        builder: (context) => MultiProvider(
          providers: [
            // Now all services are available for reading
            ChangeNotifierProvider(
              create: (context) => LoginController(
                authService: context.read<AuthService>(),
                authProvider: context.read<AuthProvider>(),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => BookedSessionsController(
                sessionService: context.read<TutoringSessionService>(),
                userService: context.read<UserService>(),
                authProvider: context.read<AuthProvider>(),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SignInController(
                context.read<SignInProcessProvider>(),
                context.read<AuthService>(),
                profileCreationTimeService:
                    context.read<ProfileCreationTimeService>(),
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
              create: (context) => LearningStylesController(
                  context.read<SignInProcessProvider>()),
            ),
            ChangeNotifierProvider(
              create: (context) => ProfilePictureController(
                  context.read<SignInProcessProvider>()),
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
              create: (_) => FilterController(
                universitiesService: context.read<UniversitiesService>(),
                coursesService: context.read<CourseService>(),
                tutorService: context.read<TutorService>(),
                filterService: context.read<FilterService>(),
                ),
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
                localDatabaseService: context.read<LocalDatabaseService>(),
              ),
            ),

            // SyncService (notifier-less, but has dependencies)
            Provider<SyncService>(
              create: (context) => SyncService(
                scaffoldMessengerKey: scaffoldMessengerKey,
                reviewService: context.read<ReviewService>(),
                cacheService: context.read<LocalCacheService>(),
                locationService: context.read<LocationService>(),
                userService: context.read<UserService>(),
                signInProcessProvider: context.read<SignInProcessProvider>(),
              ),
            ),
          ],
          child: const TutorApp(),
        ),
      ),
    ),
  );
}

class TutorApp extends StatefulWidget {
  const TutorApp({super.key});

  @override
  State<TutorApp> createState() => _TutorAppState();
}

class _TutorAppState extends State<TutorApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = context.read<SyncService>();
      debugPrint("SyncService instance obtained in TutorApp state.");
      syncService.syncPendingData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            case AuthState.unknown:
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            case AuthState.authenticated:
              final role = authProvider.currentUser?.role;
              debugPrint("Authenticated state detected. Role: $role");
              if (role == 'student') {
                return const StudentHomeScreen();
              } else if (role == 'tutor') {
                return const TutorProfileScreen();
              } else {
                debugPrint(
                    "Authenticated, but role is unknown/invalid. Defaulting to WelcomeScreen.");
                return const WelcomeScreen();
              }
            case AuthState.unauthenticated:
              return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
