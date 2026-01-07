import 'package:flutter/foundation.dart'; // WAJIB ADA: untuk kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as gs;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- GANTI ID INI DENGAN ID YANG DARI SUPABASE/GOOGLE CLOUD ---
  // Contoh format: "123456-abcdefg.apps.googleusercontent.com"
  static const String _webClientId = '955427922283-htl9ue0j549hlpd1c34itppuurojks90.apps.googleusercontent.com';

  // --- LOGIN EMAIL ---
  Future<String?> login({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan koneksi: $e";
    }
  }

  // --- REGISTER EMAIL ---
  Future<String?> register({required String email, required String password}) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Gagal mendaftar: $e";
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<String?> signInWithGoogle() async {
    try {
      // PERBAIKAN PENTING DI SINI:
      // clientId harus dimasukkan di dalam kurung constructor GoogleSignIn
      final gs.GoogleSignIn googleSignIn = gs.GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: kIsWeb ? _webClientId : null, 
      );
      
      final gs.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "Login dibatalkan user.";

      final gs.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        return "Gagal mendapatkan token dari Google.";
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        return null; // Sukses
      } else {
        return "Gagal login ke Supabase dengan Google.";
      }

    } catch (e) {
      return "Google Sign In Error: $e";
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    // Perbaikan sintaks di sini juga:
    final gs.GoogleSignIn googleSignIn = gs.GoogleSignIn(
        clientId: kIsWeb ? _webClientId : null,
    );
    
    await googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  // --- CEK SESI USER ---
  User? get currentUser => _supabase.auth.currentUser;
}