import 'package:flutter/material.dart';

class CustomSnackBar {
  // General purpose method with customizable parameters
  static SnackBar show({
    required String message,
    IconData icon = Icons.check_circle,
    Color iconColor = Colors.greenAccent,
    Color backgroundColor = const Color(0xFF222831),
    Duration duration = const Duration(seconds: 3),
    double elevation = 6,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return SnackBar(
      content: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: duration,
      elevation: elevation,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  // Specific method for success messages
  static SnackBar success({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return show(
      message: message,
      icon: Icons.check_circle,
      iconColor: Colors.greenAccent,
      backgroundColor: const Color(0xFF222831),
      duration: duration,
      elevation: 6,
    );
  }

  // Specific method for error messages
  static SnackBar error({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    return show(
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.redAccent,
      backgroundColor: const Color(0xFF23272A),
      duration: duration,
      elevation: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
