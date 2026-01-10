import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://puulfsptvvhdcijbikqr.supabase.co',
    anonKey: 'sb_publishable_-NLBLD86vdP7I4yqHu6cGQ_wGMPWrWe',
  );

  // 🔑 WAJIB untuk Flutter Web OAuth (Google Login)
  if (kIsWeb) {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(
        Uri.base,
      );
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ ROOT APP LANGSUNG AUTHGATE
      home: AuthGate(),

      // ❌ JANGAN PAKAI:
      // initialRoute
      // routes
      // onGenerateRoute
    );
  }
}
