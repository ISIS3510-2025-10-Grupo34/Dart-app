import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tutor_sign_in_controller.dart';
import 'profile_picture_screen.dart';
import 'welcome_screen.dart';
import '../providers/sign_in_process_provider.dart';

class TutorSignInScreen extends StatefulWidget {
  const TutorSignInScreen({super.key});

  @override
  _TutorSignInState createState() => _TutorSignInState();
}

class _TutorSignInState extends State<TutorSignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaOfExpertiseMenuController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _universityMenuController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    signInProcessProvider.loadSignUpProgress().then((_) {
      _nameController.text = signInProcessProvider.savedName ?? '';
      _phoneNumberController.text =
          signInProcessProvider.savedPhoneNumber ?? '';
      if (signInProcessProvider.savedUniversity != null) {
        _universityMenuController.text =
            signInProcessProvider.savedUniversity ?? '';
      }
      if (signInProcessProvider.savedAreaOfExpertise != null) {
        _areaOfExpertiseMenuController.text =
            signInProcessProvider.savedAreaOfExpertise ?? '';
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    final controller =
        Provider.of<TutorSignInController>(context, listen: false);
    controller.addListener(() {
      if (!mounted) return;

      final state = controller.state;
      if (state == TutorSignInState.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePictureScreen()),
          (route) => false,
        );
        controller.resetStateAfterNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorSignInController>(
      builder: (context, controller, child) {
        final isLoading = controller.state == TutorSignInState.loading;
        final nameError = (controller.state == TutorSignInState.error)
            ? controller.nameError
            : null;
        final phoneError = (controller.state == TutorSignInState.error)
            ? controller.phoneError
            : null;
        final generalError = (controller.state == TutorSignInState.error)
            ? controller.generalError
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Opacity(
              opacity: isLoading ? 0.7 : 1.0, // Dim UI while loading
              child: AbsorbPointer(
                absorbing: isLoading, // Prevent interaction while loading
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    // Added SingleChildScrollView
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            // Navigate to welcome screen when TutorApp text is tapped?
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WelcomeScreen()), // Assuming WelcomeScreen exists
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
                        const SizedBox(height: 40), // Adjusted spacing
                        const Center(
                          child: Text(
                            "Tutor",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF171F45),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "We would like to know more about you",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          enabled: !isLoading,
                          onChanged: (_) => controller.clearInputErrors(),
                          decoration: InputDecoration(
                            hintText: 'First and last name',
                            errorText: nameError,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
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
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneNumberController,
                          enabled: !isLoading,
                          onChanged: (_) => controller.clearInputErrors(),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            errorText: phoneError,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
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
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUniversityDropdown(controller),
                        if (controller.universityError != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: Text(
                              controller.universityError!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _buildAOEDropdown(controller),
                        if (controller.expertiseError != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: Text(
                              controller.expertiseError!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (generalError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              generalError,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<TutorSignInController>()
                                        .submitTutorDetails(
                                          name: _nameController.text,
                                          phoneNumber:
                                              _phoneNumberController.text,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF171F45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3)
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40), // Adjusted spacing
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaOfExpertiseMenuController.dispose();
    _phoneNumberController.dispose();
    _universityMenuController.dispose();
    super.dispose();
  }

  Widget _buildUniversityDropdown(dynamic controller) {
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    if (signInProcessProvider.savedUniversity != null) {
      controller.selectUniversity(signInProcessProvider.savedUniversity);
    }
    final List<String> universities = controller.universities;
    final String? selectedValue = controller.selectedUniversity;
    final Function(String?) onSelectedUpdate = controller.selectUniversity;

    return DropdownMenu<String>(
      controller: _universityMenuController,
      initialSelection: selectedValue,
      dropdownMenuEntries:
          universities.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
      onSelected: (String? value) {
        onSelectedUpdate(value);
      },
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      hintText: 'Select University',
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    );
  }

  Widget _buildAOEDropdown(dynamic controller) {
    final signInProcessProvider =
        Provider.of<SignInProcessProvider>(context, listen: false);
    if (signInProcessProvider.savedAreaOfExpertise != null) {
      controller.selectAOE(signInProcessProvider.savedAreaOfExpertise);
    }
    final List<String> aoes = controller.aoe;
    final String? selectedAOE = controller.selectedAOE;
    final Function(String?) onSelectedUpdate = controller.selectAOE;

    return DropdownMenu<String>(
      controller: _areaOfExpertiseMenuController,
      initialSelection: selectedAOE,
      dropdownMenuEntries: aoes.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
      onSelected: (String? value) {
        onSelectedUpdate(value);
      },
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      hintText: 'Select Area Of Expertise',
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    );
  }
}
