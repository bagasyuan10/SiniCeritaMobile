import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // Diperlukan untuk kIsWeb

class AuthService {
  // Akses Client Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cek user login saat ini
  User? get currentUser => _supabase.auth.currentUser;

  // --- LOGIN EMAIL ---
  Future<String?> login({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null; // Sukses (tidak ada error)
    } on AuthException catch (e) {
      return e.message; // Error dari Supabase (misal: password salah)
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- REGISTER EMAIL ---
  Future<String?> register({required String email, required String password}) async {
    try {
      await _supabase.auth.signUp(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

// --- LOGIN GOOGLE (Supabase Native) ---
  Future<String?> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb 
            ? 'http://localhost:3000/' 
            // GANTI BAGIAN INI:
            : 'com.example.sinicerita://login-callback/', 
      );

      return null; 
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error Google Sign In: $e";
    }
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    // Cukup logout dari Supabase saja, otomatis sesi Google juga lepas
    await _supabase.auth.signOut();
  }
}