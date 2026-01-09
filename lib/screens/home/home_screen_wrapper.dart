import 'package:flutter/material.dart';

import '../mood_check_in_screen.dart';
import 'home_screen.dart';

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  bool _hasCheckedMood = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeScreen(),

        if (!_hasCheckedMood)
          MoodCheckInScreen(
            onComplete: () {
              if (!mounted) return;
              setState(() => _hasCheckedMood = true);
            },
          ),
      ],
    );
  }
}
