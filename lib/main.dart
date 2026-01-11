import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- IMPORT FILES KAMU ---
import 'services/auth_gate.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: File .env tidak ditemukan/gagal dimuat.");
  }
  
  await Supabase.initialize(
    url: 'https://puulfsptvvhdcijbikqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1dWxmc3B0dnZoZGNpamJpa3FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5Mjg0OTcsImV4cCI6MjA4MjUwNDQ5N30.L5SWYsDnR5tuG6ClTfoNjaQi_PZPwnRo2xFqjzKTSQk', 
  );

  // 3. Setup OAuth untuk Web
  if (kIsWeb) {
    try {
      // Menggunakan strategi aman untuk web
      final route = Uri.base.fragment;
      if (route.contains('access_token')) {
         await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
      }
    } catch (e) {
      debugPrint('OAuth redirect error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SiniCerita',
      theme: ThemeData.dark(), // Disarankan pakai dark theme agar cocok dengan MoodOverlay

      // ✅ ROOT APP: AuthGate akan menentukan user ke Login atau Home
      home: const AuthGate(),

      // ✅ NAVIGASI
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}