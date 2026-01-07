import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/home_widgets.dart'; 
import '../widgets/mood_overlay.dart' hide primaryTeal; 

// IMPORT FILE CHATBOT (Pastikan path-nya sesuai)
import '../screens/chatbot_screen.dart';

// Definisi warna lokal agar tidak error jika tidak ada di home_widgets
const Color primaryTeal = Color(0xFF00897B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showMoodOverlay = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. SCAFFOLD UTAMA
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FA), // Warna background lebih soft
          drawer: const HomeDrawer(),
          body: SingleChildScrollView(
            // Efek membal saat ditarik (Premium feel)
            physics: const BouncingScrollPhysics(), 
            child: Column(
              children: [
                // --- HEADER SECTION ---
                SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: HomeHeaderBackground()),
                      // Pattern overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BackgroundPatternPainter(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  HomeMenuButton(
                                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                                  ),
                                  GlassIconButton(
                                    icon: Icons.notifications_none_rounded,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const Spacer(), // Dorong teks ke bawah sedikit
                              const Text(
                                "Halo, Sahabat!",
                                style: TextStyle(
                                  color: Colors.white70, 
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Ceritakan\nHarimu Disini.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34, // Font sedikit lebih besar
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 40),
                              const HomeSearchBar(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- CONTENT SECTION (ANIMATED) ---
                // Animasi Slide Up + Fade In agar terlihat keren saat loading
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)), // Efek naik dari bawah
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: "Mulai Dari Sini"),
                        const SizedBox(height: 16),
                        
                        // GRID MENU
                        Row(
                          children: [
                            Expanded(
                              child: GradientCard(
                                title: "Cek Stress",
                                content: "Ukur tingkat stressmu.",
                                icon: Icons.speed_rounded,
                                color1: const Color(0xFF64B5F6),
                                color2: const Color(0xFF1976D2),
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.calculateStress),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GradientCard(
                                title: "Curhat AI",
                                content: "Teman cerita 24 jam.",
                                icon: Icons.smart_toy_rounded,
                                // Gradient lebih vibrant untuk AI
                                color1: const Color(0xFFFFCC80), 
                                color2: const Color(0xFFFB8C00),
                                onTap: () {
                                  // --- NAVIGASI KE CHATBOT SCREEN ---
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatbotScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        const SectionHeader(title: "Jelajahi"),
                        const SizedBox(height: 16),
                        
                        _buildArticleItem(
                          context,
                          "Mengenal Stress",
                          "Pelajari apa itu stress dan cara mengatasinya.",
                          Icons.menu_book_rounded,
                          AppRoutes.learnMoreStress,
                        ),
                        _buildArticleItem(
                          context,
                          "Tentang Aplikasi",
                          "Kenali fitur-fitur yang bisa membantumu.",
                          Icons.info_outline_rounded,
                          AppRoutes.learnMoreAboutApp,
                        ),
                        const SizedBox(height: 100), // Ruang ekstra di bawah
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. MOOD OVERLAY
        if (_showMoodOverlay)
          MoodOverlay(
            onDismiss: () {
              setState(() {
                _showMoodOverlay = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildArticleItem(BuildContext context, String title, String subtitle,
      IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Jarak antar item lebih lega
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sudut lebih bulat
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.1), // Shadow halus
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: primaryTeal, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 16,
                          color: Color(0xFF263238),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13, 
                          color: Colors.grey,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14, 
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}