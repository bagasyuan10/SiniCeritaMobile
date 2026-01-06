import 'dart:ui'; // Diperlukan untuk ImageFilter (Glassmorphism)
import 'package:flutter/material.dart';

class LearnMoreAboutAppScreen extends StatefulWidget {
  const LearnMoreAboutAppScreen({super.key});

  @override
  State<LearnMoreAboutAppScreen> createState() => _LearnMoreAboutAppScreenState();
}

class _LearnMoreAboutAppScreenState extends State<LearnMoreAboutAppScreen> with SingleTickerProviderStateMixin {
  // --- PALET WARNA MODERN ---
  final Color primaryTeal = const Color(0xFF00897B);
  final Color darkTeal = const Color(0xFF004D40);
  final Color accentOrange = const Color(0xFFFFAB40);
  final Color backgroundTeal = const Color(0xFFE0F2F1);
  final Color softSurface = const Color(0xFFF5FBFB);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Sedikit lebih cepat agar snappy
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softSurface, // Background sedikit off-white
      body: Stack(
        children: [
          // BACKGROUND PATTERN (Dekorasi Abstrak)
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(color: primaryTeal.withValues(alpha: 0.05)),
            ),
          ),
          
          // MAIN SCROLL VIEW
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. PARALLAX HEADER ---
              SliverAppBar(
                expandedHeight: 360.0,
                floating: false,
                pinned: true,
                backgroundColor: darkTeal,
                elevation: 0,
                leading: IconButton(
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.black.withValues(alpha: 0.2),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: const Text(
                    'Tentang Kami',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                    ),
                  ),
                  background: _buildParallaxBackground(),
                ),
              ),

              // --- 2. KONTEN UTAMA ---
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -50, 0),
                  child: Column(
                    children: [
                      // Ikon Floating dengan Glow
                      Transform.translate(
                        offset: const Offset(0, -60), // Naik sedikit lagi
                        child: _buildFloatingIcon(),
                      ),

                      // Konten Teks & Widget
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Intro Title
                            _buildAnimatedItem(
                              index: 0,
                              child: Column(
                                children: [
                                  Text(
                                    'Selamat Datang di',
                                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, letterSpacing: 1.2),
                                  ),
                                  Text(
                                    'SiniCerita',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: darkTeal,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    height: 4, 
                                    width: 60, 
                                    decoration: BoxDecoration(
                                      color: accentOrange, 
                                      borderRadius: BorderRadius.circular(2)
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Intro Desc
                            _buildAnimatedItem(
                              index: 1,
                              child: Text(
                                'Kadang, kita cuma butuh tempat buat cerita. Tempat yang aman, anonim, dan nggak nge-judge. Di sinilah ruang amanmu berada.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade700),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // --- GLASS STATISTIK BAR ---
                            _buildAnimatedItem(
                              index: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryTeal.withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatItem('10k+', 'Pengguna', Icons.people_outline),
                                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                                          _buildStatItem('50k+', 'Cerita', Icons.chat_bubble_outline),
                                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                                          _buildStatItem('4.9', 'Rating ⭐', Icons.star_border),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // --- FITUR UTAMA ---
                            _buildAnimatedItem(index: 3, child: _buildSectionTitle('Kenapa Harus SiniCerita?')),
                            const SizedBox(height: 20),
                            _buildAnimatedItem(index: 4, child: _buildFeatureCard(Icons.lock_outline_rounded, 'Privasi Terjaga', 'Curhat bebas, 100% anonim, tanpa takut dihakimi.')),
                            const SizedBox(height: 16),
                            _buildAnimatedItem(index: 5, child: _buildFeatureCard(Icons.favorite_rounded, 'Support System', 'Dapat dukungan dari teman cerita yang mengerti rasanya.')),
                            const SizedBox(height: 16),
                            _buildAnimatedItem(index: 6, child: _buildFeatureCard(Icons.spa_rounded, 'Mental Health', 'Temukan ketenangan dan inspirasi baru setiap hari.')),

                            const SizedBox(height: 40),

                            // --- TIM DIBALIK LAYAR ---
                            _buildAnimatedItem(index: 7, child: _buildSectionTitle('Tim Kami')),
                            const SizedBox(height: 20),
                            _buildAnimatedItem(
                              index: 8,
                              child: SizedBox(
                                height: 150,
                                child: ListView(
                                  clipBehavior: Clip.none,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    _buildTeamMember('Alex', 'Founder', Colors.blue),
                                    _buildTeamMember('Sarah', 'Psychologist', Colors.pink),
                                    _buildTeamMember('Budi', 'Developer', Colors.orange),
                                    _buildTeamMember('Dina', 'Community', Colors.purple),
                                    _buildTeamMember('Rian', 'Designer', Colors.teal),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // --- FAQ ---
                            _buildAnimatedItem(index: 9, child: _buildSectionTitle('Sering Ditanyakan')),
                            const SizedBox(height: 16),
                            _buildAnimatedItem(
                              index: 10,
                              child: Column(
                                children: [
                                  _buildFAQItem('Apakah ini benar-benar gratis?', 'Ya! 100% gratis untuk semua fitur dasar curhat dan komunitas.'),
                                  _buildFAQItem('Apakah identitas saya aman?', 'Sangat aman. Kami tidak menyimpan nama asli atau data sensitif Anda.'),
                                  _buildFAQItem('Bagaimana cara melapor spam?', 'Gunakan fitur "Report" di pojok kanan atas setiap postingan.'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Quote Box dengan Style Baru
                            _buildAnimatedItem(index: 11, child: _buildQuoteBox()),

                            const SizedBox(height: 50),

                            // Social Media Row
                            _buildAnimatedItem(
                              index: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(Icons.facebook),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(Icons.camera_alt),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(Icons.alternate_email),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Tombol Gradient Modern
                            _buildAnimatedItem(index: 13, child: _buildGradientButton(context)),

                            const SizedBox(height: 30),

                            // Version Info
                            Text(
                              'Versi Aplikasi 1.0.0 (Beta)',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            
                            // Padding bawah extra agar tidak mentok
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildParallaxBackground() {
    return ClipPath(
      clipper: BottomConcaveClipper(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/about_app_illustration.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, stack) => Container(color: darkTeal),
          ),
          // Gradient Overlay agar teks header terbaca jelas
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  darkTeal.withValues(alpha: 0.6),
                  Colors.transparent,
                  darkTeal.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
      child: Container(
        height: 90, // Lebih besar sedikit
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          // Shadow yang lebih soft dan colored (Glow)
          boxShadow: [
            BoxShadow(
              color: primaryTeal.withValues(alpha: 0.3), 
              blurRadius: 30, 
              offset: const Offset(0, 15)
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primaryTeal, darkTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 45),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: primaryTeal.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTeal),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTeamMember(String name, String role, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 10), // Margin bottom untuk shadow
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
              ]
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: Text(
                name[0],
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkTeal)),
          Text(role, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
          ]
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: backgroundTeal, shape: BoxShape.circle),
              child: Icon(Icons.question_mark_rounded, color: primaryTeal, size: 18),
            ),
            title: Text(
              question,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkTeal),
            ),
            children: [
              Text(
                answer,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ]
      ),
      child: Icon(icon, color: darkTeal, size: 24),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final double start = (index * 0.05).clamp(0.0, 1.0);
    final double end = (start + 0.4).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutQuart)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 2, width: 20, color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.5),
          ),
        ),
        Container(height: 2, width: 20, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundTeal, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: backgroundTeal),
            ),
            child: Icon(icon, color: primaryTeal, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: darkTeal)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteBox() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkTeal, const Color(0xFF00695C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
               BoxShadow(color: primaryTeal.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
            ]
          ),
          child: Column(
            children: [
              const Text(
                '“Setiap suara layak didengar, dan setiap hati berhak merasa lega.”',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 18, height: 1.5, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 30, height: 1, color: Colors.white54),
                  const SizedBox(width: 10),
                  const Text('Misi SiniCerita', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Container(width: 30, height: 1, color: Colors.white54),
                ],
              )
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 24),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGradientButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryTeal, const Color(0xFF4DB6AC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: primaryTeal.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Kembali ke Beranda',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER UNTUK BACKGROUND PATTERN ---
class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Menggambar lingkaran abstrak di berbagai posisi
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.5), 100, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 40, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- CLIPPER SAMA SEPERTI SEBELUMNYA ---
class BottomConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}