import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
// PERBAIKAN DI SINI: Import profile_screen.dart telah dihapus karena tidak dipakai

// --- KONSTANTA WARNA ---
const Color primaryTeal = Color(0xFF00897B);
const Color darkTeal = Color(0xFF004D40);
const Color surfaceTeal = Color(0xFFE0F2F1);
const Color accentOrange = Color(0xFFFFAB40);
const Color textDark = Color(0xFF263238);

// ... (Sisa kode ke bawah sama persis, tidak perlu diubah) ...
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

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

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: user != null
                ? Supabase.instance.client
                    .from('users')
                    .stream(primaryKey: ['id'])
                    .eq('id', user.id)
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
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                decoration: const BoxDecoration(
                  color: surfaceTeal,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryTeal, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                        child: photoURL == null
                            ? const Icon(Icons.person, size: 30, color: primaryTeal)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark), maxLines: 1),
                          Text(email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTile(context, Icons.home_rounded, 'Beranda', () => Navigator.pop(context), isActive: true),
                _buildTile(context, Icons.calculate_outlined, 'Kalkulator Stress', () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.calculateStress); }),
                _buildTile(context, Icons.chat_bubble_outline_rounded, 'Ruang Curhat', () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.chatRoom); }),
                _buildTile(context, Icons.support_agent_rounded, 'Hubungi Kami', () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.support); }),
                const Divider(),
                _buildTile(context, Icons.settings_rounded, 'Pengaturan Profil', () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.editProfile); }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () async {
                await AuthService().logout(); 
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isActive = false}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? primaryTeal : Colors.grey.shade600),
      title: Text(title, style: TextStyle(color: isActive ? primaryTeal : textDark, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      tileColor: isActive ? primaryTeal.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}

// ... Widget lain (BackgroundPatternPainter, HomeHeaderBackground, dll) tetap sama ...
// Agar lebih ringkas, saya tidak menulis ulang bagian bawah file ini karena tidak ada error di sana.
// Pastikan kode di bawah HomeDrawer tetap ada seperti semula.

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
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Cari topik curhat...',
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

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark));
  }
}

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
          boxShadow: [BoxShadow(color: color2.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 12))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(content, style: TextStyle(color: Colors.white.withValues(alpha: 0.9)), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}