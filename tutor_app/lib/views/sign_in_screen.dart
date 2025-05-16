import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sign_in_controller.dart';
import 'student_sign_in_screen.dart';
import 'tutor_sign_in_screen.dart';
import 'welcome_screen.dart';
import '../providers/sign_in_process_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final signInController =
        Provider.of<SignInController>(context, listen: false);
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    signInProcessProvider.loadSignUpProgress().then((_) {
      if (signInProcessProvider.hasSavedProgress) {
        _emailController.text = signInProcessProvider.savedEmail ?? '';
        _passwordController.text = signInProcessProvider.savedPassword ?? '';
        _confirmPasswordController.text =
            signInProcessProvider.savedPassword ?? '';
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller = Provider.of<SignInController>(context, listen: false);
    controller.addListener(() {
      if (!mounted) return; // Safety check

      final state = controller.state;

      if (state == SignInState.validationSuccessStudent) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentSignInScreen()),
        );
        controller.resetStateAfterNavigation();
      } else if (state == SignInState.validationSuccessTutor) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TutorSignInScreen()),
        );
        controller.resetStateAfterNavigation();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get controller state and rebuild on changes
    return Consumer<SignInController>(
      builder: (context, controller, child) {
        // Read error states from controller
        final emailError = (controller.state == SignInState.validationError)
            ? controller.emailError
            : null;
        final passwordError = (controller.state == SignInState.validationError)
            ? controller.passwordError
            : null;
        final isValidating = controller.state == SignInState.validating;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              // Use SingleChildScrollView if content might overflow
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        controller.resetStateAfterNavigation();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "TutorApp",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Center(
                        child: Text("Create Account",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF171F45)))),
                    const SizedBox(height: 8),
                    const Center(
                        child: Text("Set up your account credentials",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54))),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        errorText: emailError,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                      ),
                      onChanged: (_) => controller.clearErrors(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        errorText: passwordError,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      onChanged: (_) => controller.clearErrors(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        errorText: passwordError,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                      ),
                      onChanged: (_) => controller
                          .clearErrors(), // Optional: Clear errors on change
                    ),
                    const SizedBox(height: 40),
                    const Center(
                        child: Text("Are you a tutor or a student?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isValidating
                                  ? null
                                  : () => context
                                      .read<SignInController>()
                                      .validateAndProceed(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                        _confirmPasswordController.text,
                                        "tutor",
                                      ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF171F45),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
                                  elevation: 0),
                              child: const Text("Tutor",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isValidating
                                  ? null
                                  : () => context
                                      .read<SignInController>()
                                      .validateAndProceed(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                        _confirmPasswordController.text,
                                        "student",
                                      ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF171F45),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
                                  elevation: 0),
                              child: const Text("Student",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
