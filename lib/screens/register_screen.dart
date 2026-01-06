import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../widgets/home_widgets.dart'; // Pastikan warna ada di sini

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false; // Loading khusus tombol Google
  bool _isPasswordVisible = false;

  // Handle Register Email Biasa
  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email dan Password wajib diisi")));
       return;
    }

    setState(() => _isLoading = true);
    final error = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat! Silakan Login.")));
        Navigator.pop(context); // Kembali ke Login
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // Handle Google Sign In
  void _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    final error = await _authService.signInWithGoogle();
    setState(() => _isGoogleLoading = false);

    if (error == null) {
      // Kalau sukses Google Sign In, langsung masuk ke Home
      // Kita gunakan pushNamedAndRemoveUntil agar user tidak bisa back ke halaman register
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } else {
      if (mounted && error != "Login dibatalkan oleh user") {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true, // Agar AppBar transparan di atas header
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Warna Orange/Accent biar beda dari Login)
            // ==========================================
            SizedBox(
              height: size.height * 0.30,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                      width: double.infinity,
                      height: size.height * 0.30,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF8F00), accentOrange], // Nuansa Orange
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -60,
                    left: -60,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        // PERBAIKAN 1: Ganti withOpacity -> withValues
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Mulai Perjalananmu",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Buat Akun Baru 🚀",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. FORM AREA
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildModernTextField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    label: "Kata Sandi",
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 30),

                  // TOMBOL DAFTAR (Orange)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isGoogleLoading) ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        // PERBAIKAN 2: Ganti withOpacity -> withValues
                        shadowColor: accentOrange.withValues(alpha: 0.4),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8F00), accentOrange],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Daftar Sekarang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // DIVIDER "ATAU"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("atau daftar dengan", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL GOOGLE
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: _isGoogleLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ikon Google (Bisa ganti Image.asset jika punya aset png)
                              const Icon(Icons.g_mobiledata, size: 32, color: Colors.red), 
                              const SizedBox(width: 10),
                              const Text("Lanjutkan dengan Google", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FOOTER LOGIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Masuk", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget TextField Modern (Sama seperti Login)
  Widget _buildModernTextField({
    required String label, 
    required IconData icon, 
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // PERBAIKAN 3: Ganti withOpacity -> withValues
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: accentOrange), // Ikon warna Orange
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ) 
            : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}

// Clipper untuk lengkungan Header (Sama seperti Login)
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}