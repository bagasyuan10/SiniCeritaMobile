import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Pastikan import ini ada

// Konstanta warna
const Color primaryTeal = Color(0xFF00897B);

class MoodOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const MoodOverlay({super.key, required this.onDismiss});

  @override
  State<MoodOverlay> createState() => _MoodOverlayState();
}

class _MoodOverlayState extends State<MoodOverlay> {
  int? _selectedMoodIndex;
  bool _isLoading = false; // 2. Tambahkan state untuk loading

  final List<Map<String, String>> _moods = [
    {'emoji': '😢', 'label': 'Sedih'},
    {'emoji': '😐', 'label': 'Biasa'},
    {'emoji': '😊', 'label': 'Senang'},
    {'emoji': '😁', 'label': 'Bahagia'},
  ];

  // 3. Fungsi untuk menyimpan ke Supabase
  Future<void> _submitMood() async {
    if (_selectedMoodIndex == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        // Handle jika user belum login (jarang terjadi di home screen, tapi jaga-jaga)
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User tidak ditemukan, silakan login ulang.")),
          );
        }
        return;
      }

      final selectedData = _moods[_selectedMoodIndex!];

      // Kirim data ke tabel 'daily_moods'
      await Supabase.instance.client.from('daily_moods').insert({
        'user_id': user.id, // Penting: ID user yang login
        'mood_label': selectedData['label'],
        'mood_emoji': selectedData['emoji'],
        // 'created_at': akan otomatis terisi oleh default database
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Mood hari ini tersimpan! ${selectedData['emoji']}"),
            backgroundColor: primaryTeal,
          ),
        );
        // Panggil onDismiss setelah sukses
        widget.onDismiss(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan mood: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 1. BACKGROUND BLUR
          GestureDetector(
            onTap: () {}, 
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          
          // 2. KONTEN DI TENGAH
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Apa kabar perasaanmu?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pilih ikon yang mewakili harimu.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // Grid Pilihan Mood
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_moods.length, (index) {
                      bool isSelected = _selectedMoodIndex == index;
                      return GestureDetector(
                        // Disable pemilihan saat loading
                        onTap: _isLoading ? null : () => setState(() => _selectedMoodIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryTeal.withValues(alpha: 0.15) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? primaryTeal : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Text(
                            _moods[index]['emoji']!, 
                            style: TextStyle(fontSize: isSelected ? 38 : 32),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 10),
                  Text(
                    _selectedMoodIndex != null 
                        ? _moods[_selectedMoodIndex!]['label']! 
                        : "...",
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: primaryTeal
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Tombol Lanjut
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // Panggil _submitMood saat ditekan
                      onPressed: (_selectedMoodIndex == null || _isLoading) 
                          ? null 
                          : _submitMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            "Lanjut ke Home", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}