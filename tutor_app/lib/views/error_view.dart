import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF171F45),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
