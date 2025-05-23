import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/network_utils.dart'; 
import '../controllers/subscribe_controller.dart'; 
import '../views/error_view.dart'; 

class SubscribeCourseScreen extends StatefulWidget {
  const SubscribeCourseScreen({super.key});

  @override
  State<SubscribeCourseScreen> createState() => _SubscribeCourseScreenState();
}

class _SubscribeCourseScreenState extends State<SubscribeCourseScreen> {
  late TextEditingController _universityTextController;
  late TextEditingController _courseTextController;

  // State for view-initiated network error
  bool _showViewLevelNetworkError = false;
  String _viewLevelNetworkErrorMessage = "Please check your internet connection and try again.";

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<SubscribeCourseController>(context, listen: false);
    _universityTextController = TextEditingController(text: controller.selectedUniversity ?? '');
    _courseTextController = TextEditingController(text: controller.selectedCourse ?? '');

    if (controller.universities.isEmpty && !controller.isLoadingUniversities) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<SubscribeCourseController>(context, listen: false).loadUniversities();
        }
      });
    }
  }

  @override
  void dispose() {
    _universityTextController.dispose();
    _courseTextController.dispose();
    super.dispose();
  }

  Future<void> _handleSubscribeButtonPressed() async {
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!mounted) return;

    if (!hasInternet) {
      setState(() {
        _showViewLevelNetworkError = true;
        // You can customize this message further if needed
        _viewLevelNetworkErrorMessage = "No internet connection. Please connect to a network and try again.";
      });
    } else {
      // If internet is available, hide any previously shown view-level network error
      // and proceed with calling the controller's subscription method.
      if (_showViewLevelNetworkError) { // Check if it was previously true
        setState(() {
          _showViewLevelNetworkError = false;
        });
      }
      // Let the controller handle the subscription logic and its own state management
      Provider.of<SubscribeCourseController>(context, listen: false).submitSubscription();
    }
  }

  Widget _buildDropdownMenu({ /* ... same as your previous version ... */ 
      required BuildContext context,
      required TextEditingController textEditingController,
      required List<String> entries,
      required String? currentSelectionFromController,
      required String hintText,
      required bool isLoading,
      required String? apiError,
      required String? selectionError,
      required void Function(String?) onSelected,
      required bool enabled,
    }) {
      if (textEditingController.text != (currentSelectionFromController ?? '')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            textEditingController.text = currentSelectionFromController ?? '';
          }
        });
      }

      if (isLoading) {
        return const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(),
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownMenu<String>(
            controller: textEditingController,
            initialSelection: currentSelectionFromController,
            dropdownMenuEntries: entries.map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry<String>(value: value, label: value);
            }).toList(),
            onSelected: (String? value) {
              onSelected(value);
              if (value != null) {
                textEditingController.text = value;
              } else {
                textEditingController.clear();
              }
            },
            expandedInsets: EdgeInsets.zero,
            menuHeight: 300,
            hintText: entries.isEmpty && !isLoading && apiError == null ? 'No options available' : hintText,
            enabled: enabled && !isLoading && entries.isNotEmpty,
            inputDecorationTheme: _dropdownInputDecorationTheme(context),
            menuStyle: _dropdownMenuStyle(),
          ),
          if (apiError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(apiError, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
          if (selectionError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(selectionError, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
        ],
      );
    }

  InputDecorationTheme _dropdownInputDecorationTheme(BuildContext context) { /* ... same ... */ 
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      hintStyle: TextStyle(color: Colors.grey[500])
    );
  }
  
  MenuStyle _dropdownMenuStyle() { /* ... same ... */ 
    return MenuStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
      elevation: WidgetStateProperty.all<double>(3),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using context.watch() for SubscribeCourseController to rebuild when controller notifies listeners
    final controller = context.watch<SubscribeCourseController>();

    // Sync TextEditingControllers with the main controller's state
    // This ensures if controller.selectedUniversity changes, UI reflects it.
    // Do this before building the main content.
     WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (_universityTextController.text != (controller.selectedUniversity ?? '')) {
            _universityTextController.text = controller.selectedUniversity ?? '';
          }
          if (_courseTextController.text != (controller.selectedCourse ?? '')) {
            _courseTextController.text = controller.selectedCourse ?? '';
          }
        }
      });

    Widget screenBody;

    if (_showViewLevelNetworkError) {
      screenBody = Padding(
        padding: const EdgeInsets.all(20.0),
        child: ErrorView(
          title: "No Internet Connection",
          message: _viewLevelNetworkErrorMessage,
          icon: Icons.wifi_off_rounded,
          onRetry: () {
            // When retrying from this view-level error,
            // first hide this specific error view and then attempt subscription again.
            setState(() {
              _showViewLevelNetworkError = false;
            });
            _handleSubscribeButtonPressed(); // This will re-check internet
          },
        ),
      );
    } else {
      // If no view-level network error, build based on controller's state
      bool isNetworkErrorFromController = controller.state == SubscribeCourseState.error &&
          controller.subscriptionError != null &&
          (controller.subscriptionError!.toLowerCase().contains("check your internet connection") ||
           controller.subscriptionError!.toLowerCase().contains("could not connect to the server") ||
           controller.subscriptionError!.toLowerCase().contains("network is unreachable") ||
           controller.subscriptionError!.toLowerCase().contains("socketexception") ||
           controller.subscriptionError!.toLowerCase().contains("failed host lookup"));

      if (isNetworkErrorFromController) {
        screenBody = Padding(
          padding: const EdgeInsets.all(20.0),
          child: ErrorView(
            title: "Network Connection Error",
            message: controller.subscriptionError!,
            icon: Icons.wifi_off_rounded,
            onRetry: () {
              // Retry logic when the error came from the controller's attempt
              controller.submitSubscription();
            },
          ),
        );
      } else {
        // Normal form content
        screenBody = SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Display OTHER subscription errors or success messages from controller
              if (controller.state == SubscribeCourseState.error && controller.subscriptionError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container( /* ... error message style ... */ 
                     padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!)
                      ),
                      child: Text(
                        controller.subscriptionError!,
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                  ),
                ),
              if (controller.state == SubscribeCourseState.success && controller.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container( /* ... success message style ... */ 
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!)
                    ),
                    child: Text(
                      controller.successMessage!,
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // University Dropdown
              const Text("Select University", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildDropdownMenu(
                context: context,
                textEditingController: _universityTextController,
                entries: controller.universities,
                currentSelectionFromController: controller.selectedUniversity,
                hintText: 'Choose a university',
                isLoading: controller.isLoadingUniversities,
                apiError: controller.universityApiError,
                selectionError: controller.universitySelectionError,
                onSelected: (String? universityName) {
                  controller.selectUniversity(universityName);
                  if (universityName == null || universityName.isEmpty) {
                     _courseTextController.clear();
                  }
                },
                enabled: !controller.isLoadingUniversities,
              ),
              const SizedBox(height: 20),

              // Course Dropdown
              const Text("Select Course", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildDropdownMenu(
                context: context,
                textEditingController: _courseTextController,
                entries: controller.courses,
                currentSelectionFromController: controller.selectedCourse,
                hintText: 'Choose a course',
                isLoading: controller.isLoadingCourses,
                apiError: controller.courseApiError,
                selectionError: controller.courseSelectionError,
                onSelected: (String? courseName) {
                  controller.selectCourse(courseName);
                },
                enabled: !controller.isLoadingCourses && (controller.selectedUniversity != null && controller.selectedUniversity!.isNotEmpty),
              ),
              if (controller.selectedUniversity == null || controller.selectedUniversity!.isEmpty && !controller.isLoadingUniversities)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Please select a university first to see courses.", style: TextStyle(color: Colors.grey[600])),
                ),
              const SizedBox(height: 30),

              // Subscribe Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF171F45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: (controller.selectedUniversity != null &&
                            controller.selectedCourse != null &&
                            controller.state != SubscribeCourseState.subscribing)
                    ? _handleSubscribeButtonPressed // Call the new handler
                    : null,
                child: controller.state == SubscribeCourseState.subscribing && !_showViewLevelNetworkError // Only show loading if not showing view-level error
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Subscribe to Course'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribe to a Course"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: screenBody),
    );
  }
}