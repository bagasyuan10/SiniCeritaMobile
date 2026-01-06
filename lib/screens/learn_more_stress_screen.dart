import 'dart:ui'; // Diperlukan untuk ImageFilter (Glassmorphism)
import 'package:flutter/material.dart';

class LearnMoreStressScreen extends StatefulWidget {
  const LearnMoreStressScreen({super.key});

  @override
  State<LearnMoreStressScreen> createState() => _LearnMoreStressScreenState();
}

class _LearnMoreStressScreenState extends State<LearnMoreStressScreen> with SingleTickerProviderStateMixin {
  // --- PALET WARNA ---
  final Color primaryTeal = const Color(0xFF00897B);
  final Color darkTeal = const Color(0xFF004D40);
  final Color accentOrange = const Color(0xFFFFAB40);
  final Color backgroundTeal = const Color(0xFFE0F2F1);
  final Color softSurface = const Color(0xFFF5FBFB);
  final Color alertRed = const Color(0xFFE57373);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Durasi diperpanjang sedikit karena konten makin banyak
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
      backgroundColor: softSurface,
      body: Stack(
        children: [
          // 1. BACKGROUND PATTERN
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(color: primaryTeal.withValues(alpha: 0.05)),
            ),
          ),

          // 2. SCROLL VIEW UTAMA
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- HEADER PARALLAX ---
              SliverAppBar(
                expandedHeight: 340.0,
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
                    'Kenali Stres',
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

              // --- KONTEN UTAMA ---
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -40, 0),
                  child: Column(
                    children: [
                      // Floating Icon
                      Transform.translate(
                        offset: const Offset(0, -50),
                        child: _buildFloatingIcon(),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            // 1. Intro Header
                            _buildAnimatedItem(
                              index: 0,
                              child: Column(
                                children: [
                                  Text(
                                    'Pernah ngerasa kayak',
                                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, letterSpacing: 1.1),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Semuanya Numpuk\ndi Kepala?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: darkTeal,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(height: 4, width: 50, decoration: BoxDecoration(color: accentOrange, borderRadius: BorderRadius.circular(2))),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),

                            // Intro Text
                            _buildAnimatedItem(
                              index: 1,
                              child: Text(
                                'Badan capek, pikiran mumet, tapi gak tau kenapa? Yup, itu bisa jadi stres. Dan tenang… kamu nggak sendirian.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade700),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // 2. Definisi Box
                            _buildAnimatedItem(
                              index: 2, 
                              child: _buildSectionTitle('Apa Itu Stres?')
                            ),
                            const SizedBox(height: 16),
                            _buildAnimatedItem(
                              index: 3,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: backgroundTeal),
                                  boxShadow: [
                                    BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                                  ]
                                ),
                                child: Text(
                                  'Stres adalah cara tubuh merespons tekanan atau tuntutan. Sebenarnya dalam dosis kecil, stres itu baik (bikin kita waspada). Tapi kalau berlebihan dan terus-terusan, itu yang bahaya.',
                                  style: TextStyle(fontSize: 15, height: 1.6, color: darkTeal),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),

                            // 3. Penyebab Umum (Trigger) - BAGIAN BARU
                            _buildAnimatedItem(
                              index: 4, 
                              child: _buildSectionTitle('Pemicu Paling Sering')
                            ),
                            const SizedBox(height: 16),
                            _buildAnimatedItem(
                              index: 5,
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildTriggerChip('💼 Pekerjaan Numpuk'),
                                  _buildTriggerChip('💸 Masalah Keuangan'),
                                  _buildTriggerChip('💔 Hubungan Sosial'),
                                  _buildTriggerChip('🔄 Perubahan Hidup'),
                                  _buildTriggerChip('🎓 Tugas Sekolah/Kuliah'),
                                  _buildTriggerChip('⏳ Kurang Waktu Me-Time'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                            
                            // 4. Tanda-tanda (Checklist)
                            _buildAnimatedItem(
                              index: 6, 
                              child: _buildSectionTitle('Sinyal Dari Tubuhmu')
                            ),
                            const SizedBox(height: 20),
                            
                            _buildAnimatedItem(index: 7, child: _buildFeatureCard('🌀', 'Cemas Berlebih', 'Merasa khawatir, takut salah, atau gelisah tanpa sebab yang jelas.')),
                            const SizedBox(height: 12),
                            _buildAnimatedItem(index: 8, child: _buildFeatureCard('🌙', 'Gangguan Tidur', 'Susah tidur (insomnia) atau malah kebanyakan tidur tapi tetap lelah.')),
                            const SizedBox(height: 12),
                            _buildAnimatedItem(index: 9, child: _buildFeatureCard('🥴', 'Fisik Terganggu', 'Sakit kepala, leher tegang, asam lambung naik, atau jantung berdebar.')),
                            const SizedBox(height: 12),
                            _buildAnimatedItem(index: 10, child: _buildFeatureCard('😠', 'Emosi Labil', 'Sumbu pendek (mudah marah), mudah menangis, atau merasa hampa.')),

                            const SizedBox(height: 40),

                            // 5. Solusi / Cara Mengatasi - BAGIAN BARU
                            _buildAnimatedItem(
                              index: 11,
                              child: _buildSectionTitle('Coba Lakukan Ini')
                            ),
                            const SizedBox(height: 16),
                            _buildAnimatedItem(index: 12, child: _buildSolutionCard('1', 'Tarik Napas Dalam', 'Teknik 4-7-8: Tarik 4 detik, tahan 7 detik, hembuskan 8 detik. Ulangi 3x.')),
                            const SizedBox(height: 12),
                            _buildAnimatedItem(index: 13, child: _buildSolutionCard('2', 'Gerakkan Badan', 'Jalan kaki 15 menit aja cukup buat nurunin hormon kortisol (stres).')),
                            const SizedBox(height: 12),
                            _buildAnimatedItem(index: 14, child: _buildSolutionCard('3', 'Jeda Digital', 'Taruh HP. Berhenti scroll sosmed yang bikin insecure setidaknya 1 jam sebelum tidur.')),
                            const SizedBox(height: 12),
                            _buildAnimatedItem(index: 15, child: _buildSolutionCard('4', 'Journaling', 'Tulis apa yang bikin pusing di kertas. Ini bantu "mengeluarkan" beban dari kepala.')),

                            const SizedBox(height: 40),

                            // 6. Kapan Cari Bantuan? - BAGIAN BARU
                            _buildAnimatedItem(
                              index: 16,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: alertRed, size: 28),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Kapan Harus ke Profesional?',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Jika stres sudah mengganggu aktivitas sehari-hari (gak bisa kerja/sekolah), bikin kamu menarik diri dari teman, atau muncul keinginan menyakiti diri sendiri. Jangan ragu cari Psikolog ya.',
                                      style: TextStyle(color: Colors.red.shade800, height: 1.5, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                            
                            // Quote Box
                            _buildAnimatedItem(
                              index: 17,
                              child: _buildQuoteBox(),
                            ),

                            const SizedBox(height: 40),

                            // Gradient Button
                            _buildAnimatedItem(
                              index: 18,
                              child: _buildGradientButton(context),
                            ),
                            
                            const SizedBox(height: 50),
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
            'assets/images/exhausted-businesswoman-sitting-desk-office.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (ctx, err, stack) => Container(color: darkTeal),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  darkTeal.withValues(alpha: 0.5),
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
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentOrange.withValues(alpha: 0.3), 
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
              colors: [accentOrange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 45),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    // Penyesuaian timing animasi agar support item yang banyak
    final double start = (index * 0.04).clamp(0.0, 1.0); 
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
        Container(width: 20, height: 2, color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey.shade500, 
              letterSpacing: 1.5
            ),
          ),
        ),
        Container(width: 20, height: 2, color: Colors.grey.shade300),
      ],
    );
  }

  // WIDGET BARU: Chip untuk Pemicu Stres
  Widget _buildTriggerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(color: darkTeal, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            height: 45,
            width: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundTeal, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: backgroundTeal),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkTeal)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BARU: Kartu Solusi dengan Nomor
  Widget _buildSolutionCard(String number, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentOrange, width: 4)), // Aksen garis di kiri
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             width: 24,
             height: 24,
             alignment: Alignment.center,
             decoration: BoxDecoration(
               color: accentOrange,
               shape: BoxShape.circle,
             ),
             child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                 const SizedBox(height: 4),
                 Text(desc, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4)),
               ],
             ),
           )
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
              colors: [const Color(0xFF00695C), accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
               BoxShadow(color: accentOrange.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
            ]
          ),
          child: Column(
            children: [
              const Text(
                '“Tenang... Kamu bisa atasi kok! Mulai dari tarik napas dalam, istirahat sejenak, itu semua membantu.”',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16, height: 1.6, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '#JagaKewarasan',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
              ),
              child: const Icon(Icons.spa_rounded, color: Color(0xFF00695C), size: 24),
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

// --- HELPER CLASSES ---

class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 90, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.85), 70, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}