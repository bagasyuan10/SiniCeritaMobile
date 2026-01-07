import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
// import '../routes/app_routes.dart'; // Pastikan import routes jika menggunakan named route

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selectedMoodIndex != null) {
      // Simpan data mood ke database/state management di sini jika perlu
      
      // Navigasi ke HomeScreen menggunakan Named Route
      // Pastikan '/home' sudah terdaftar di main.dart
      Navigator.pushReplacementNamed(context, '/home'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background transparan agar layer sebelumnya terlihat
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          // 1. BLUR EFFECT
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              // PERBAIKAN 1: Mengganti withOpacity menjadi withValues
              color: Colors.black.withValues(alpha: 0.4), 
            ),
          ),

          // 2. KONTEN TENGAH
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        // PERBAIKAN 2: Mengganti withOpacity menjadi withValues
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Halo!",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bagaimana perasaanmu saat ini?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      
                      // Grid Mood
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: List.generate(_moods.length, (index) {
                          final isSelected = _selectedMoodIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMoodIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF00897B) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                  width: 2
                                ),
                                boxShadow: isSelected ? [
                                  // PERBAIKAN 3: Mengganti withOpacity menjadi withValues
                                  BoxShadow(
                                    color: const Color(0xFF00897B).withValues(alpha: 0.4), 
                                    blurRadius: 10, 
                                    offset: const Offset(0,4)
                                  )
                                ] : [],
                              ),
                              child: Text(
                                _moods[index]['emoji']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Tombol Lanjut
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedMoodIndex != null ? _onContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D40),
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Lanjut ke Beranda",
                            style: TextStyle(
                              color: _selectedMoodIndex != null ? Colors.white : Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}