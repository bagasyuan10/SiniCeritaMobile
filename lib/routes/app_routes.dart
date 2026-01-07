import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  // --- DAFTAR STRING RUTE (Konstanta) ---
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  // Tambahan yang kurang (Penyebab Error di Home):
  static const String calculateStress = '/calculate-stress';
  static const String learnMoreStress = '/learn-more-stress';
  static const String learnMoreAboutApp = '/about-app';
  static const String chatRoom = '/chat-room';
  static const String support = '/support';
  static const String editProfile = '/edit-profile';

  // --- GENERATOR RUTE ---
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        // final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      // --- RUTE SEMENTARA (Supaya tidak error saat diklik) ---
      case calculateStress:
      case learnMoreStress:
      case learnMoreAboutApp:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(settings.name ?? "Coming Soon")),
            body: const Center(child: Text("Halaman sedang dibuat")),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}