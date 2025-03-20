import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'utils/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.load();

  runApp(const TutorApp());
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutorApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}
