import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan sudah: flutter pub add url_launcher

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // --- UPDATE KONTAK DI SINI ---
  final String _waNumber = "6287751728755"; // Format internasional tanpa '+'
  final String _emailAddress = "bagasyuan10@gmail.com";
  // -----------------------------

  Future<void> _launchWhatsApp() async {
    // URL WhatsApp API
    final Uri url = Uri.parse("https://wa.me/$_waNumber?text=Halo%20Admin%20SiniCerita,%20saya%20butuh%20bantuan...");
    
    try {
      // 1. Coba buka aplikasi WhatsApp langsung (External Application)
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // 2. Jika gagal (misal tidak ada WA), buka via Browser (Platform Default)
        if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
          debugPrint("Gagal membuka WhatsApp");
        }
      }
    } catch (e) {
      debugPrint("Error launching WA: $e");
    }
  }

  Future<void> _launchEmail() async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: _emailAddress,
      query: 'subject=Feedback SiniCerita&body=Halo Tim SiniCerita...',
    );
    try {
      if (!await launchUrl(url)) {
        debugPrint("Gagal membuka Email");
      }
    } catch (e) {
      debugPrint("Error launching Email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna SiniCerita
    final Color primaryTeal = const Color(0xFF00897B);
    final Color darkTeal = const Color(0xFF004D40);
    final Color softBg = const Color(0xFFF5FBFB);

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: darkTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pusat Bantuan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HERO SECTION (HEADER) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
              decoration: BoxDecoration(
                color: darkTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Kami Siap Membantu",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ada masalah dengan aplikasi? \nAtau punya ide fitur baru? Kabari kami ya.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. ACTION BUTTONS (MENU) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // TOMBOL WHATSAPP
                  _buildCoolCard(
                    title: "Chat via WhatsApp",
                    subtitle: "Hubungi +62 877-5172-8755",
                    icon: Icons.chat_bubble_rounded, 
                    gradientColors: [const Color(0xFF25D366), const Color(0xFF128C7E)], 
                    onTap: _launchWhatsApp,
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL EMAIL
                  _buildCoolCard(
                    title: "Kirim Email",
                    subtitle: "Kirim ke bagasyuan10@gmail.com",
                    icon: Icons.alternate_email_rounded,
                    gradientColors: [primaryTeal, darkTeal], 
                    onTap: _launchEmail,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 3. FOOTER INFO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Divider(color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 10),
                  Text(
                    "Jam Operasional Admin:\nSenin - Jumat, 09.00 - 17.00 WIB",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "v1.0.0 • SiniCerita",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CARD KEREN
  Widget _buildCoolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                ),
                Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}