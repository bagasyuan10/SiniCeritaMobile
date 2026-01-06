import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/home_widgets.dart';
import '../widgets/learn_more_button.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final Color softSurface = const Color(0xFFF8FDFD);
  late AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State untuk Mood Tracker
  int _selectedMoodIndex = 0;
  final List<Map<String, String>> _moods = [
    {"emoji": "😊", "label": "Senang"},
    {"emoji": "😔", "label": "Sedih"},
    {"emoji": "😡", "label": "Marah"},
    {"emoji": "😐", "label": "Biasa"},
    {"emoji": "😰", "label": "Cemas"},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: softSurface,
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          // 1. Background Pattern Halus
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(color: primaryTeal.withValues(alpha: 0.05)),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- HEADER APP BAR ---
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: darkTeal,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  child: HomeMenuButton(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GlassIconButton(
                      icon: Icons.notifications_outlined,
                      onTap: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Stack(
                    children: [
                      // Gradient Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF004D40), Color(0xFF00897B)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                      // Dekorasi Abstrak
                      Positioned(top: -60, right: -40, child: _circleDeco(220, 0.08)),
                      Positioned(top: 80, left: -50, child: _circleDeco(180, 0.05)),
                      Positioned(bottom: 40, right: 20, child: _circleDeco(80, 0.03)),
                      
                      // Teks Sapaan
                      Positioned(
                        bottom: 90,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                "Halo, Sahabat! 👋",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Siap bercerita\nhari ini?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                letterSpacing: -0.5,
                                shadows: [Shadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 10)]
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- KONTEN BODY ---
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: softSurface,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH BAR (Floating)
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildAnimatedItem(0, _buildModernSearchBar()),
                        ),
                      ),

                      // MOOD TRACKER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAnimatedItem(1, Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Apa yang kamu rasakan?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              child: Row(
                                children: List.generate(_moods.length, (index) {
                                  return _buildMoodChip(
                                    index,
                                    _moods[index]["emoji"]!,
                                    _moods[index]["label"]!,
                                    _selectedMoodIndex == index,
                                  );
                                }),
                              ),
                            ),
                          ],
                        )),
                      ),

                      const SizedBox(height: 32),

                      // SECTION HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAnimatedItem(2, Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(title: "Jelajahi Topik"),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey.shade600),
                            )
                          ],
                        )),
                      ),
                      
                      const SizedBox(height: 16),

                      // --- DUAL CARD SECTION (PREMIUM CARDS) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAnimatedItem(3, Row(
                          children: [
                            // KARTU 1: Tentangmu
                            Expanded(
                              child: PremiumCard(
                                height: 260,
                                title: 'Tentangmu,\nKita,\nSiniCerita',
                                subtitle: 'Ruang aman untuk berbagi cerita.',
                                icon: Icons.spa_rounded,
                                colors: const [Color(0xFF00695C), Color(0xFF004D40)],
                                onTap: () => Navigator.pushNamed(context, AppRoutes.learnMoreAboutApp),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // KARTU 2: Stress
                            Expanded(
                              child: PremiumCard(
                                height: 260,
                                title: 'Kenali\nStress\n& Gejala',
                                subtitle: 'Pahami sinyal tubuhmu.',
                                icon: Icons.self_improvement_rounded,
                                colors: const [Color(0xFF26A69A), Color(0xFF00897B)],
                                onTap: () => Navigator.pushNamed(context, AppRoutes.learnMoreStress),
                              ),
                            ),
                          ],
                        )),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // DIVIDER
                      _buildAnimatedItem(4, Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(color: Colors.grey.withValues(alpha: 0.15), thickness: 1.5),
                      )),
                      const SizedBox(height: 20),

                      // FOOTER
                      _buildAnimatedItem(5, Center(
                        child: Column(
                          children: [
                            Text("Ingin mengenal kami lebih jauh?", style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            const LearnMoreButton(),
                          ],
                        ),
                      )),
                      const SizedBox(height: 120),
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

  // --- WIDGET HELPER ---

  Widget _circleDeco(double size, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white.withValues(alpha: opacity), Colors.white.withValues(alpha: 0)],
        )
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 10)
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari topik curhat...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: primaryTeal),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: surfaceTeal, shape: BoxShape.circle),
              child: const Icon(Icons.tune_rounded, color: primaryTeal, size: 20),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMoodChip(int index, String emoji, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSelected ? 14 : 12),
              decoration: BoxDecoration(
                gradient: isSelected
                  ? const LinearGradient(colors: [primaryTeal, darkTeal], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : null,
                color: isSelected ? null : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? primaryTeal.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.08),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 6),
                  )
                ],
                border: isSelected ? null : Border.all(color: Colors.grey.shade100),
              ),
              child: Text(emoji, style: TextStyle(fontSize: isSelected ? 26 : 24)),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Jakarta', 
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryTeal : Colors.grey.shade500
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    final double start = (index * 0.1).clamp(0.0, 1.0);
    final double end = (start + 0.4).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutQuad)),
        ),
        child: child,
      ),
    );
  }
}

// -------------------------------------------------------------------------
// NEW WIDGET: PREMIUM CARD
// -------------------------------------------------------------------------

class PremiumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final double height;

  const PremiumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    this.onTap,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Watermark Icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            // 2. Lingkaran cahaya dekoratif
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            // 3. Konten Utama
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.4
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}