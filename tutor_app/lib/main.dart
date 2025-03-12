import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(TutorApp());
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TutorApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInScreen(),
    );
  }
}
