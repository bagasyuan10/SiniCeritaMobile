import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Cek status login pakai Supabase
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      title: 'Sini Cerita',
      debugShowCheckedModeBanner: false,
      // Jika user ada -> Home, jika tidak -> Login
      initialRoute: user != null ? AppRoutes.home : AppRoutes.login,
      routes: AppRoutes.routes,
      theme: ThemeData(
        primaryColor: const Color(0xFF00897B),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
    );
  }
}