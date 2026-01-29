// Flutter imports:
import 'package:flutter/material.dart';

class ToastService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFF4CAF50), // Green
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFFF44336), // Red
      icon: Icons.error_outline_rounded,
    );
  }

  static void showInfo(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFF2196F3), // Blue
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFFFF9800), // Orange
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _showSnackBar(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.removeCurrentSnackBar(); // Remove any existing snackbar

    state.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating, // Floating is more modern
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }
}
