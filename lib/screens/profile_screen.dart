import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';
import '../services/auth_service.dart'; // Pastikan path ini sesuai dengan auth_service Anda

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- WARNA TEMA ---
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color darkTeal = Color(0xFF004D40);
  static const Color backgroundGrey = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundGrey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 22),
              tooltip: "Edit Profil",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              },
            ),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('users')
            .stream(primaryKey: ['id'])
            .eq('id', user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryTeal));
          }

          final data = snapshot.data?.isNotEmpty == true ? snapshot.data!.first : null;

          final String displayName = data?['display_name'] ?? user.userMetadata?['full_name'] ?? "Pengguna";
          final String email = user.email ?? "-";
          final String? photoURL = data?['photo_url'];
          final String bio = data?['bio'] ?? "Belum ada deskripsi diri.";
          final String gender = data?['gender'] ?? "-";
          final String phone = data?['phone_number'] ?? "-";
          
          String birthDate = "-";
          if (data?['birth_date'] != null && data!['birth_date'].toString().isNotEmpty) {
            birthDate = data['birth_date'];
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // --- 1. HEADER DENGAN PATTERN & FOTO ---
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    _buildDynamicHeader(),
                    
                    Positioned(
                      bottom: -60,
                      child: _buildProfileImage(photoURL, context),
                    ),
                  ],
                ),

                const SizedBox(height: 75),

                // --- 2. KONTEN UTAMA DENGAN ANIMASI ---
                _EntranceAnimation(
                  delay: 100,
                  child: Column(
                    children: [
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2D3436), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blueGrey.shade100),
                        ),
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- 3. BIO CARD (KHUSUS) ---
                _EntranceAnimation(
                  delay: 200,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryTeal.withValues(alpha: 0.05), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryTeal.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.format_quote_rounded, color: primaryTeal.withValues(alpha: 0.4), size: 30),
                        Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontStyle: FontStyle.italic, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 4. DETAILS CARD ---
                _EntranceAnimation(
                  delay: 300,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
                        BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 5, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person_outline_rounded, "Jenis Kelamin", gender, Colors.blueAccent),
                        _buildDivider(),
                        _buildInfoRow(Icons.cake_outlined, "Tanggal Lahir", birthDate, Colors.pinkAccent),
                        _buildDivider(),
                        _buildInfoRow(Icons.phone_iphone_rounded, "Nomor Handphone", phone, Colors.orangeAccent),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- 5. LOGOUT BUTTON ---
                _EntranceAnimation(
                  delay: 400,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () async {
                           await AuthService().logout();
                           if (context.mounted) {
                             Navigator.of(context).popUntil((route) => route.isFirst);
                           }
                        },
                        icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
                        label: Text("Keluar Akun", style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildDynamicHeader() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkTeal, primaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Stack(
        children: [
          // Ornamen Lingkaran
          Positioned(
            top: -50, right: -50,
            child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: 40, left: -20,
            child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            top: 80, left: 40,
            child: CircleAvatar(radius: 20, backgroundColor: Colors.white.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? photoURL, BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
            child: photoURL == null
                ? const Icon(Icons.person, size: 70, color: primaryTeal)
                : null,
          ),
        ),
        // Tombol Edit Mini di Foto
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
                ]
              ),
              child: const Icon(Icons.edit, size: 18, color: primaryTeal),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Colors.grey.shade100, thickness: 1.5, height: 1),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Color(0xFF2D3436), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- CLASS ANIMASI SEDERHANA (Tanpa Package) ---
class _EntranceAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const _EntranceAnimation({required this.child, required this.delay});

  @override
  State<_EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<_EntranceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );

    // Mulai animasi setelah delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}