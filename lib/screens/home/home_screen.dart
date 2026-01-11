import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter (Glassmorphism)

// --- 1. IMPORT ROUTES & WIDGETS ---
import '../../widgets/home_widgets.dart'; // Pastikan HomeDrawer ada di sini

// --- 2. IMPORT SCREENS TUJUAN ---
// Pastikan path folder ini sesuai dengan struktur project Anda
import '../chatbot_screen.dart';
import '../calculate_stress_screen.dart';
import '../learn_more_stress_screen.dart';     // File tujuan "Mengenal Stress"
import '../learn_more_about_app_screen.dart';  // File tujuan "Tentang Aplikasi"

// --- KONFIGURASI WARNA & STYLE ---
const Color primaryTeal = Color(0xFF00897B);
const Color accentOrange = Color(0xFFFFB74D);
const Color bgWhite = Color(0xFFF8F9FA);
const Color textDark = Color(0xFF1A1A1A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Controller untuk animasi list agar muncul perlahan
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgWhite,
      drawer: const HomeDrawer(), // Pastikan widget ini ada di project Anda

      body: Stack(
        children: [
          // 1. BACKGROUND HEADER DENGAN EFEK WAVE KEREN
          const _CoolDoubleWaveHeader(),

          // 2. CONTENT SCROLLABLE
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar (Menu & Notif)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassButton(
                            icon: Icons.grid_view_rounded,
                            onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          _GlassButton(
                            icon: Icons.notifications_active_outlined,
                            onTap: () {
                              // Fitur notifikasi (Opsional)
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Greeting Text dengan Animasi Fade
                      FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo, Sahabat!",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Bagaimana\nPerasaanmu?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                    color: Colors.black26,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Search Bar Modern
                      const _ModernSearchBar(),
                    ],
                  ),
                ),

                // --- MAIN CONTENT BODY ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildSectionTitle("Mulai Dari Sini"),
                      const SizedBox(height: 16),

                      // GRID MENU (Cards)
                      Row(
                        children: [
                          // BUTTON 1: CEK STRESS
                          Expanded(
                            child: _ModernGridCard(
                              title: "Cek Stress",
                              subtitle: "Ukur kondisimu",
                              icon: Icons.graphic_eq_rounded,
                              gradientColors: const [Color(0xFF29B6F6), Color(0xFF0277BD)],
                              delay: 200, 
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CalculateStressScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // BUTTON 2: CURHAT AI
                          Expanded(
                            child: _ModernGridCard(
                              title: "Curhat AI",
                              subtitle: "Teman cerita 24h",
                              icon: Icons.smart_toy_rounded,
                              gradientColors: const [Color(0xFFFFCA28), Color(0xFFF57C00)],
                              delay: 400,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle("Jelajahi"),
                      const SizedBox(height: 16),

                      // LIST ARTIKEL & INFO (Navigasi Diperbaiki)
                      _ModernListTile(
                        title: "Mengenal Stress",
                        subtitle: "Cara mengelola emosi & pikiran.",
                        icon: Icons.spa_rounded,
                        color: Colors.purpleAccent,
                        delay: 600,
                        // NAVIGASI LANGSUNG KE SCREEN TUJUAN
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LearnMoreStressScreen()),
                          );
                        },
                      ),
                      
                      _ModernListTile(
                        title: "Tentang Aplikasi",
                        subtitle: "Fitur yang membantumu.",
                        icon: Icons.info_outline_rounded,
                        color: Colors.tealAccent.shade700,
                        delay: 800,
                        // NAVIGASI LANGSUNG KE SCREEN TUJUAN
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LearnMoreAboutAppScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 100), // Padding bawah agar scroll nyaman
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FadeTransition(
      opacity: _animationController,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// =========================================================
// WIDGETS VISUAL MODERN (COOLER DESIGN)
// =========================================================

// 1. HEADER KEREN DENGAN DOUBLE WAVE
class _CoolDoubleWaveHeader extends StatelessWidget {
  const _CoolDoubleWaveHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // Background Gradient Utama
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00695C), 
                  Color(0xFF00897B), 
                  Color(0xFF4DB6AC), 
                ],
              ),
            ),
          ),
          
          // Dekorasi Lingkaran Abstrak
          Positioned(top: -60, right: -60, child: _CircleDeco(size: 250, opacity: 0.1)),
          Positioned(top: 80, left: -40, child: _CircleDeco(size: 150, opacity: 0.05)),
          
          // Wave Lapisan Belakang (Lebih Transparan)
          ClipPath(
            clipper: _WaveClipperBack(),
            child: Container(
              height: 400,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          // Wave Lapisan Depan (Penutup Utama)
          ClipPath(
            clipper: _WaveClipperFront(),
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0), // Transparan
                    bgWhite, // Warna background body
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Lingkaran
class _CircleDeco extends StatelessWidget {
  final double size;
  final double opacity;
  const _CircleDeco({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// Clipper untuk Wave Depan
class _WaveClipperFront extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    // Membuat kurva gelombang yang smooth
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 90);
    var secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0); // Tutup path ke atas
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Clipper untuk Wave Belakang (Efek Layering)
class _WaveClipperBack extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 3, size.height - 90);
    var firstEndPoint = Offset(size.width / 1.5, size.height - 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 2. GLASSMORPHISM BUTTON
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), 
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

// 3. MODERN SEARCH BAR
class _ModernSearchBar extends StatelessWidget {
  const _ModernSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari artikel atau bantuan...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.search_rounded, color: primaryTeal.withValues(alpha: 0.8), size: 26),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// 4. MODERN GRID CARD (Efek Scale saat muncul)
class _ModernGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final int delay;

  const _ModernGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Container(
            height: 170, // Sedikit lebih tinggi
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 5. MODERN LIST TILE (Slide Up Animation)
class _ModernListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _ModernListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        // Efek Slide dari bawah ke atas
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), 
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            splashColor: color.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}