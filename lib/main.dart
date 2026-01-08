import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; 

import 'routes/app_routes.dart';
import 'services/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); 

  // --- PERBAIKAN DI SINI ---
  // Hapus .instance (Langsung Supabase.initialize)
  await Supabase.initialize(
    url: 'https://puulfsptvvhdcijbikqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1dWxmc3B0dnZoZGNpamJpa3FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5Mjg0OTcsImV4cCI6MjA4MjUwNDQ5N30.L5SWYsDnR5tuG6ClTfoNjaQi_PZPwnRo2xFqjzKTSQk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sini Cerita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      
      home: const AuthGate(),

      // Penangkal Error Pink
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const AuthGate());
      },

      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}