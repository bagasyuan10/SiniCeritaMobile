import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// --- IMPORT SCREEN LAIN ---
import '../screens/chatbot_screen.dart';
import '../screens/calculate_stress_screen.dart';
import '../screens/support_screen.dart';
import '../screens/profile_screen.dart';

// --- KONSTANTA WARNA ---
const Color primaryTeal = Color(0xFF00897B);
const Color darkTeal = Color(0xFF004D40);
const Color surfaceTeal = Color(0xFFE0F2F1);
const Color accentOrange = Color(0xFFFFAB40);
const Color textDark = Color(0xFF263238);

// =============================================================================
// 1. WIDGET MOOD CHECK-IN CARD (DATABASE CONNECTED)
// =============================================================================
class MoodCheckInCard extends StatefulWidget {
  const MoodCheckInCard({super.key});

  @override
  State<MoodCheckInCard> createState() => _MoodCheckInCardState();
}

class _MoodCheckInCardState extends State<MoodCheckInCard> {
  final supabase = Supabase.instance.client;
  Map<String, String> moodHistory = {}; // Format: "YYYY-MM-DD": "Emoji"
  bool hasCheckedInToday = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  String _getDateStr(DateTime date) => date.toIso8601String().split('T')[0];

  Future<void> _fetchMoodData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('daily_moods')
          .select('date, mood_emoji')
          .eq('user_id', user.id)
          .gte('date', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('date', ascending: true);

      final Map<String, String> loadedData = {};
      final todayStr = _getDateStr(DateTime.now());

      for (var item in response) {
        String rawDate = item['date'].toString();
        String dateKey = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
        loadedData[dateKey] = item['mood_emoji'] as String;
      }

      if (mounted) {
        setState(() {
          moodHistory = loadedData;
          hasCheckedInToday = moodHistory.containsKey(todayStr);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading mood: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _submitMood(String emoji, int score) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final todayStr = _getDateStr(DateTime.now());

    try {
      await supabase.from('daily_moods').upsert({
        'user_id': user.id,
        'date': todayStr,
        'mood_emoji': emoji,
        'mood_score': score,
      });

      if (mounted) {
        setState(() {
          moodHistory[todayStr] = emoji;
          hasCheckedInToday = true;
        });
        Navigator.pop(context); // Tutup BottomSheet
      }
    } catch (e) {
      debugPrint("Gagal menyimpan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 80, 
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      // Margin diset 0 karena sudah ada padding di ListView Parent
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFCC80), accentOrange]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text("Mood Kamu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                if (hasCheckedInToday)
                  const Icon(Icons.check_circle, color: Colors.white, size: 16)
              ],
            ),
          ),
          
          // List Hari
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
                String dateKey = _getDateStr(date);
                bool isToday = index == 6; 
                String? mood = moodHistory[dateKey];
                String dayName = ['Sn','Sl','Rb','Km','Jm','Sb','Mg'][date.weekday - 1];

                return Column(
                  children: [
                    Text(dayName, style: TextStyle(fontSize: 10, color: isToday ? accentOrange : Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday && mood == null ? accentOrange.withValues(alpha: 0.1) : Colors.transparent,
                        border: Border.all(
                          color: isToday ? accentOrange : (mood != null ? primaryTeal : Colors.grey.withValues(alpha: 0.2)),
                          width: 1.5
                        )
                      ),
                      child: Center(
                        child: mood != null 
                          ? Text(mood, style: const TextStyle(fontSize: 16))
                          : (isToday ? const Icon(Icons.add, size: 16, color: accentOrange) : null),
                      ),
                    )
                  ],
                );
              }),
            ),
          ),

          // Tombol Check-in (Jika belum checkin hari ini)
          if (!hasCheckedInToday)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton(
                  onPressed: () => _showMoodPicker(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Isi Mood Hari Ini", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Apa mood kamu hari ini?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _emojiBtn("😫", "Buruk", 1), 
                _emojiBtn("🙁", "Sedih", 2), 
                _emojiBtn("😐", "Biasa", 3), 
                _emojiBtn("🙂", "Baik", 4), 
                _emojiBtn("🤩", "Hebat", 5)
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _emojiBtn(String e, String label, int s) {
    return InkWell(
      onTap: () => _submitMood(e, s),
      child: Column(
        children: [
          Text(e, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. WIDGET LAINNYA
// =============================================================================

// GLASS ICON BUTTON
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

// HOME MENU BUTTON WRAPPER
class HomeMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const HomeMenuButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.sort_rounded,
      onTap: onTap,
    );
  }
}

// HOME DRAWER (Modifikasi: Ada Mood Checkin di dalamnya)
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final size = MediaQuery.of(context).size;

    return Drawer(
      backgroundColor: Colors.transparent,
      width: size.width * 0.85,
      elevation: 0,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30)
                ),
                boxShadow: [
                  BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: Column(
                children: [
                  // --- A. HEADER USER ---
                  _buildUserHeader(user),

                  // --- B. LIST MENU ---
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        
                        // 1. MOOD CHECK-IN (DISINI LETAKNYA)
                        const MoodCheckInCard(), 
                        
                        const SizedBox(height: 8),

                        // 2. BERANDA & MENU LAIN
                        _buildAnimatedTile(context, Icons.home_rounded, 'Beranda', () => Navigator.pop(context), isActive: true),
                        const SizedBox(height: 8),
                        _buildAnimatedTile(context, Icons.calculate_outlined, 'Kalkulator Stress', () { 
                          Navigator.pop(context); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculateStressScreen()));
                        }),
                        const SizedBox(height: 8),
                        _buildAnimatedTile(context, Icons.chat_bubble_outline_rounded, 'Ruang Curhat', () { 
                          Navigator.pop(context); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
                        }),
                        const SizedBox(height: 8),
                        _buildAnimatedTile(context, Icons.support_agent_rounded, 'Hubungi Kami', () { 
                          Navigator.pop(context); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())); 
                        }),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1),
                        ),

                        _buildAnimatedTile(context, Icons.settings_rounded, 'Pengaturan Profil', () { 
                          Navigator.pop(context); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                        }),
                      ],
                    ),
                  ),

                  // --- C. TOMBOL LOGOUT ---
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),

          // TOMBOL CLOSE (X)
          Positioned(
            top: 45, right: 16,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.red, size: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(User? user) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: user != null
          ? Supabase.instance.client.from('users').stream(primaryKey: ['id']).eq('id', user.id)
          : const Stream.empty(),
      builder: (context, snapshot) {
        String displayName = "Pengguna";
        String email = user?.email ?? "";
        String? photoURL;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
           final data = snapshot.data!.first;
           displayName = data['display_name'] ?? "Pengguna";
           photoURL = data['photo_url'];
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [surfaceTeal, Colors.white],
              begin: Alignment.topCenter, end: Alignment.bottomCenter
            ),
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryTeal, width: 2),
                  boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)]
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                  child: photoURL == null ? const Icon(Icons.person, size: 28, color: primaryTeal) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textDark), maxLines: 1),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildAnimatedTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [BoxShadow(color: primaryTeal.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey.shade600, size: 24),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: isActive ? Colors.white : textDark, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 15)),
            const Spacer(),
            if (isActive) const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14)
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: InkWell(
        onTap: () async {
          await AuthService().logout(); 
          if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade100)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 8),
              Text("Keluar Akun", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// BACKGROUND PAINTER
class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  BackgroundPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.5)..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.35, size.width * 0.5, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.05, size.width, size.height * 0.2);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// HEADER BACKGROUND
class HomeHeaderBackground extends StatelessWidget {
  const HomeHeaderBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [darkTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
    );
  }
}

// SEARCH BAR
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Cari topik curhat...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search_rounded, color: primaryTeal),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}

// SECTION HEADER
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5)),
    );
  }
}

// GRADIENT CARD
class GradientCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback? onTap;

  const GradientCard({super.key, required this.title, required this.content, required this.icon, required this.color1, required this.color2, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: color2.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 0, spreadRadius: 1, offset: const Offset(0,0))
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(content, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}