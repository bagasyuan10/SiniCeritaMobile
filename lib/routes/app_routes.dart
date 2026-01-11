import 'package:flutter/material.dart';

// --- IMPORT SCREENS ---
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/calculate_stress_screen.dart';

class AppRoutes {
  // --- DAFTAR STRING RUTE (Konstanta) ---
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  // Fitur Utama
  static const String calculateStress = '/calculate-stress';
  static const String chatbot = '/chatbot';

  // --- BAGIAN YANG HILANG (PENYEBAB ERROR) ---
  // Kita tambahkan kembali agar home_widgets.dart tidak error
  static const String chatRoom = '/chat-room'; 
  static const String support = '/support';
  static const String learnMoreStress = '/learn-more-stress';
  static const String learnMoreAboutApp = '/about-app';
  static const String editProfile = '/edit-profile';

  // --- GENERATOR RUTE ---
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 1. Auth & Home
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // 2. Fitur Utama
      case calculateStress:
        return MaterialPageRoute(builder: (_) => const CalculateStressScreen());
      
      case chatbot:
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());
      
      // ✅ FIX: Arahkan 'chatRoom' ke ChatbotScreen juga
      case chatRoom: 
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());

      // 3. Halaman Placeholder (Support, Edit Profile, dll)
      case support:
      case editProfile:
      case learnMoreStress:
      case learnMoreAboutApp:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(settings.name?.replaceAll('/', '') ?? "Info"),
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.construction, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Halaman ${settings.name}\nSedang dalam pengembangan",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );

      // 4. Default (Route tidak ditemukan)
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}