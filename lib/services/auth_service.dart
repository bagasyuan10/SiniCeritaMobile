import 'package:flutter/foundation.dart'; // WAJIB ADA
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as gs;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ID CLIENT (Hanya dipakai untuk HP/Android sekarang)
  static const String _webClientId = '955427922283-htl9ue0j549hlpd1c34itppuurojks90.apps.googleusercontent.com';

  // --- LOGIN EMAIL ---
  Future<String?> login({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
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
      return "Error: $e";
    }
  }

  // --- GOOGLE SIGN IN (FINAL FIX) ---
  Future<String?> signInWithGoogle() async {
    try {
      
      // ==========================================
      // STRATEGI 1: KHUSUS WEB (Jauh lebih stabil)
      // ==========================================
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          // UBAH DARI localhost JADI 127.0.0.1
          redirectTo: 'http://127.0.0.1:3000', 
          scopes: 'openid profile email', 
          queryParams: {'access_type': 'offline', 'prompt': 'consent'},
        );
        return null; 
      }

      // ==========================================
      // STRATEGI 2: KHUSUS ANDROID / IOS (HP)
      // ==========================================
      final gs.GoogleSignIn googleSignIn = gs.GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: _webClientId,
        serverClientId: _webClientId, // Di HP ini wajib ada
      );
      
      final gs.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "Login dibatalkan user.";

      final gs.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        return "Gagal mendapatkan token Google.";
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        return null; 
      } else {
        return "Gagal login ke Supabase.";
      }

    } catch (e) {
      debugPrint("Error Google: $e");
      return "Error: $e";
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    if (!kIsWeb) {
        final gs.GoogleSignIn googleSignIn = gs.GoogleSignIn(clientId: _webClientId);
        await googleSignIn.signOut();
    }
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}