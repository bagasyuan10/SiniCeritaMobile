import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as gs;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Client ID Google (dipakai untuk Android / iOS)
  static const String _googleClientId =
      '955427922283-htl9ue0j549hlpd1c34itppuurojks90.apps.googleusercontent.com';

  // ================= EMAIL LOGIN =================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ================= EMAIL REGISTER =================
  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<String?> signInWithGoogle() async {
    try {
      // ---------- WEB ----------
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.toString(), // 🔑 WAJIB
        );
        return null;
      }

      // ---------- ANDROID / IOS ----------
      final googleSignIn = gs.GoogleSignIn(
        clientId: _googleClientId,
        serverClientId: _googleClientId,
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "Login dibatalkan user.";

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        return "Gagal mendapatkan token Google.";
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return null;
    } catch (e) {
      debugPrint("Google Login Error: $e");
      return e.toString();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    if (!kIsWeb) {
      await gs.GoogleSignIn(clientId: _googleClientId).signOut();
    }
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
