import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT ---
import '../screens/login_screen.dart';
import '../screens/home/home_screen_wrapper.dart'; // 👈 Pastikan import Wrapper ini

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        // 1. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Belum Login
        if (session == null) {
          return const LoginScreen();
        }

        // 3. Sudah Login -> Panggil Wrapper (yang ada Overlay-nya)
        return const HomeScreenWrapper(); // ✅ BENAR
      },
    );
  }
}