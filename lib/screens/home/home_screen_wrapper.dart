import 'package:flutter/material.dart';

import '../mood_overlay.dart';
import 'home_screen.dart';

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  bool _showMoodOverlay = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeScreen(),

        // ✅ Mood Overlay hanya tampil sekali setelah login
        if (_showMoodOverlay)
          MoodOverlay(
            onDismiss: () {
              if (!mounted) return;
              setState(() {
                _showMoodOverlay = false;
              });
            },
          ),
      ],
    );
  }
}
