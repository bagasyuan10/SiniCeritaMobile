import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
// Pastikan path import ini sesuai dengan struktur foldermu
import '../widgets/mood_overlay.dart'; 

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _showMoodOverlay = true; // Default tampilkan overlay saat baru masuk

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      final uri = Uri.base;
      final code = uri.queryParameters['code'];

      // Jika ada kode dari Google, tukar jadi sesi login
      if (code != null) {
        await Supabase.instance.client.auth.exchangeCodeForSession(code);
      }
    } catch (e) {
      debugPrint("Error Auth: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;

        // JIKA SUDAH LOGIN
        if (session != null) {
          // Tampilkan Home ditumpuk dengan MoodOverlay
          return Stack(
            children: [
              const HomeScreen(), // Layer Belakang
              
              // Layer Depan (Hanya muncul jika _showMoodOverlay = true)
              if (_showMoodOverlay)
                MoodOverlay(
                  onDismiss: () {
                    // Saat tombol lanjut diklik, hilangkan overlay
                    setState(() {
                      _showMoodOverlay = false;
                    });
                  },
                ),
            ],
          );
        }

        // JIKA BELUM LOGIN
        return const LoginScreen();
      },
    );
  }
}