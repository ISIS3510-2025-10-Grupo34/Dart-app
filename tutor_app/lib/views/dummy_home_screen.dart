// lib/views/dummy_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Adjust import path if needed
import '../models/user_model.dart'; // Adjust import path if needed

class DummyHomeScreen extends StatelessWidget {
  const DummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to access the AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final User? user = authProvider.currentUser;

        // Handle cases where user might be null temporarily
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Home (Loading...)')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Display user information
        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome ${user.name ?? 'User'}!'),
            // Optional: Add a logout button or other actions
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Dummy Home Screen',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Text('User Info from AuthProvider:',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _buildUserInfoRow('ID:', user.id),
                  _buildUserInfoRow('Name:', user.name),
                  _buildUserInfoRow('Email:', user.email),
                  _buildUserInfoRow('Role:', user.role),
                  _buildUserInfoRow('Phone:', user.phoneNumber),
                  _buildUserInfoRow('University:', user.university),
                  if (user.role == 'student') ...[
                    _buildUserInfoRow('Major:', user.major),
                    _buildUserInfoRow('Learning Styles:', user.learningStyles),
                  ],
                  if (user.role == 'tutor') ...[
                    _buildUserInfoRow(
                        'Area of Expertise:', user.areaOfExpertise),
                    _buildUserInfoRow(
                        'Avg Rating:', user.avgRating?.toStringAsFixed(1)),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text('$label ${value ?? 'N/A'}'),
    );
  }
}
