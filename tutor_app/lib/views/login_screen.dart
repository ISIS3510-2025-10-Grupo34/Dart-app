import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:tutor_app/views/dummy_home_screen.dart';
import '../controllers/login_controller.dart'; // Your refactored controller
import 'tutor_home_screen.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller = Provider.of<LoginController>(context, listen: false);

    controller.addListener(() {
      final state = controller.state;

      if (!mounted) return;

      if (state == LoginState.successStudent) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
        );
        controller.resetStateAfterNavigation();
      } else if (state == LoginState.successTutor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DummyHomeScreen()),
        );
        controller.resetStateAfterNavigation();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        final isLoading = controller.state == LoginState.loading;
        final errorMessage = (controller.state == LoginState.error)
            ? controller.errorMessage
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // Optional: Dim/disable UI while loading
              child: Opacity(
                opacity: isLoading ? 0.7 : 1.0,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "TutorApp", //
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500), //
                        textAlign: TextAlign.center, //
                      ),
                      const SizedBox(height: 30), //
                      const Center(
                        child: Text(
                          "Login", //
                          style: TextStyle(
                              fontSize: 30, //
                              fontWeight: FontWeight.w700, //
                              color: Color(0xFF171F45)), //
                        ),
                      ),
                      const SizedBox(height: 8), //
                      const Center(
                        child: Text(
                          "Enter your credentials to login", //
                          style: TextStyle(
                              fontSize: 16, //
                              fontWeight: FontWeight.w400, //
                              color: Colors.black54), //
                        ),
                      ),
                      const SizedBox(height: 32), //
                      // Email Field
                      TextField(
                        controller: _emailController, //
                        keyboardType: TextInputType.emailAddress, //
                        decoration: InputDecoration(
                          //
                          hintText: 'Email', //
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16), //
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)), //
                        ),
                        enabled: !isLoading, // Disable field when loading
                      ),
                      const SizedBox(height: 16), //
                      // Password Field
                      TextField(
                        controller: _passwordController, //
                        obscureText: _obscurePassword, //
                        decoration: InputDecoration(
                          //
                          hintText: 'Password', //
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16), //
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)), //
                          suffixIcon: IconButton(
                            //
                            icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey), //
                            // Only allow toggling if not loading
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      // Local UI state update is fine
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                          ),
                        ),
                        enabled: !isLoading, // Disable field when loading
                      ),
                      const SizedBox(height: 24), //
                      // Error Message (read from controller state)
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0), //
                          child: Text(
                            errorMessage, // Display error from controller
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14), //
                            textAlign: TextAlign.center, //
                          ),
                        ),
                      // Login Button
                      SizedBox(
                        width: double.infinity, //
                        height: 56, //
                        child: ElevatedButton(
                          // Disable button when loading, call controller's login on press
                          onPressed: isLoading
                              ? null
                              : () {
                                  // Call controller via Provider, no context needed here
                                  context.read<LoginController>().login(
                                        _emailController.text, // Pass values
                                        _passwordController.text,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            //
                            backgroundColor: const Color(0xFF171F45), //
                            foregroundColor: Colors.white, //
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)), //
                          ),
                          // Show loading indicator based on controller state
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3) //
                              : const Text("Login", //
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)), //
                        ),
                      ),
                      const SizedBox(height: 20), //
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
