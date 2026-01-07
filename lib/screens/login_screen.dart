import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Panggil Service Asli
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Email dan Password wajib diisi"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    
    // Panggil fungsi login dari AuthService
    final error = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      _navigateToHome();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  // Logic Google sekarang tinggal panggil 1 baris
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    // Semua keruwetan Google ada di auth_service.dart
    final error = await _authService.signInWithGoogle();

    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      _navigateToHome();
    } else {
      if (mounted) {
        // Filter pesan "Login dibatalkan user" supaya tidak muncul error merah
        if (error != "Login dibatalkan user.") {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // UI TETAP SAMA SEPERTI SEBELUMNYA, CUMA LOGIC YANG BERUBAH
    final size = MediaQuery.of(context).size;
    const Color primaryColor = Color(0xFF00897B);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ... (Header Code sama, disingkat biar rapi) ...
            Container(height: size.height * 0.3, color: primaryColor, child: const Center(child: Text("Logo", style: TextStyle(color: Colors.white, fontSize: 30)))),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password", 
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      )
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // TOMBOL LOGIN EMAIL
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Masuk", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text("Atau"),
                  const SizedBox(height: 20),

                  // TOMBOL LOGIN GOOGLE
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                      label: const Text("Masuk dengan Google"),
                      onPressed: _isLoading ? null : _handleGoogleLogin, // Panggil fungsi baru
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text("Belum punya akun? Daftar"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}