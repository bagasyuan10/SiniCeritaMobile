import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; 
import '../screens/learn_more_about_app_screen.dart';
import '../screens/learn_more_stress_screen.dart';
import '../screens/calculate_stress_screen.dart';
import '../screens/chatbot_screen.dart'; 
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/support_screen.dart'; // 1. Pastikan import ini ada
import '../screens/edit_profile_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  static const String learnMoreAboutApp = '/learn-more-about-app';
  static const String learnMoreStress = '/learn-more-stress';
  static const String calculateStress = '/calculate_stress';
  static const String chatRoom = '/chat_room'; 
  static const String support = '/support'; // 2. Tambahkan konstanta ini
  static const String editProfile = '/edit_profile';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(), 
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),

    learnMoreAboutApp: (context) => const LearnMoreAboutAppScreen(),
    learnMoreStress: (context) => const LearnMoreStressScreen(),
    calculateStress: (context) => const CalculateStressScreen(),
    chatRoom: (context) => const ChatbotScreen(),
    support: (context) => const SupportScreen(), // 3. Daftarkan di sini
    editProfile: (context) => const EditProfileScreen(),
  };
}