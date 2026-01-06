// File: lib/widgets/learn_more_button.dart
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class LearnMoreButton extends StatelessWidget {
  const LearnMoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF00897B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.learnMoreAboutApp),
        borderRadius: BorderRadius.circular(30),
        splashColor: primaryTeal.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pelajari Lebih Lanjut',
                style: TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18, color: primaryTeal),
            ],
          ),
        ),
      ),
    );
  }
}