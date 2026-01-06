import 'package:flutter/material.dart';

class CalculateStressScreen extends StatefulWidget {
  const CalculateStressScreen({super.key});

  @override
  State<CalculateStressScreen> createState() => _CalculateStressScreenState();
}

class _CalculateStressScreenState extends State<CalculateStressScreen> {
  // --- CONTROLLER ---
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // --- DATA PERTANYAAN ---
  final List<Map<String, dynamic>> _questionsData = [
    // 1. AKADEMIK (Teal Theme)
    {'q': "Apakah Anda merasa tegang atau gelisah secara teratur selama kuliah?", 'cat': 'Akademik', 'color': const Color(0xFF00897B)},
    {'q': "Apakah Anda merasa tugas kuliah terlalu banyak untuk diselesaikan?", 'cat': 'Akademik', 'color': const Color(0xFF00897B)},
    {'q': "Apakah Anda sulit berkonsentrasi atau fokus saat belajar?", 'cat': 'Akademik', 'color': const Color(0xFF00897B)},
    {'q': "Apakah Anda merasa tertekan oleh persaingan nilai?", 'cat': 'Akademik', 'color': const Color(0xFF00897B)},
    {'q': "Apakah Anda merasa stres saat ujian besar mendekat?", 'cat': 'Akademik', 'color': const Color(0xFF00897B)},
    {'q': "Apakah Anda merasa salah jurusan atau ingin berhenti kuliah?", 'cat': 'Akademik', 'color': const Color(0xFF00897B)},

    // 2. FISIK & KESEHATAN (Orange Theme)
    {'q': "Apakah Anda mengalami sulit tidur (insomnia) karena pikiran menumpuk?", 'cat': 'Fisik', 'color': const Color(0xFFFB8C00)},
    {'q': "Apakah Anda sering merasa lelah fisik meski sudah tidur cukup?", 'cat': 'Fisik', 'color': const Color(0xFFFB8C00)},
    {'q': "Apakah Anda sering sakit kepala atau masalah pencernaan saat stres?", 'cat': 'Fisik', 'color': const Color(0xFFFB8C00)},
    {'q': "Apakah nafsu makan Anda berubah drastis (terlalu banyak/sedikit)?", 'cat': 'Fisik', 'color': const Color(0xFFFB8C00)},
    {'q': "Apakah Anda mengandalkan kafein/zat lain berlebih agar tetap kuat?", 'cat': 'Fisik', 'color': const Color(0xFFFB8C00)},
    {'q': "Apakah jantung Anda sering berdebar kencang tanpa alasan?", 'cat': 'Fisik', 'color': const Color(0xFFFB8C00)},

    // 3. EMOSIONAL & MENTAL (Purple Theme)
    {'q': "Apakah Anda sering merasa mudah marah atau sensitif?", 'cat': 'Emosional', 'color': const Color(0xFF8E24AA)},
    {'q': "Apakah Anda merasa cemas berlebihan memikirkan masa depan?", 'cat': 'Emosional', 'color': const Color(0xFF8E24AA)},
    {'q': "Apakah Anda merasa sedih atau ingin menangis tanpa pemicu jelas?", 'cat': 'Emosional', 'color': const Color(0xFF8E24AA)},
    {'q': "Apakah Anda merasa hampa atau kehilangan minat pada hobi?", 'cat': 'Emosional', 'color': const Color(0xFF8E24AA)},
    {'q': "Apakah Anda merasa bersalah jika sedang bersantai (Toxic Productivity)?", 'cat': 'Emosional', 'color': const Color(0xFF8E24AA)},
    {'q': "Apakah Anda sering membandingkan diri dengan pencapaian orang lain?", 'cat': 'Emosional', 'color': const Color(0xFF8E24AA)},

    // 4. SOSIAL & LINGKUNGAN (Blue Theme)
    {'q': "Apakah Anda merasa kesepian atau terisolasi di kampus?", 'cat': 'Sosial', 'color': const Color(0xFF1E88E5)},
    {'q': "Apakah Anda menarik diri dari teman karena merasa lelah bersosialisasi?", 'cat': 'Sosial', 'color': const Color(0xFF1E88E5)},
    {'q': "Apakah Anda mengalami konflik dengan teman atau orang tua?", 'cat': 'Sosial', 'color': const Color(0xFF1E88E5)},
    {'q': "Apakah Anda merasa sulit menolak permintaan orang lain (People Pleaser)?", 'cat': 'Sosial', 'color': const Color(0xFF1E88E5)},
    {'q': "Apakah Anda cemas saat harus presentasi atau bicara di depan umum?", 'cat': 'Sosial', 'color': const Color(0xFF1E88E5)},
    {'q': "Apakah Anda merasa lingkungan tempat tinggal Anda tidak kondusif?", 'cat': 'Sosial', 'color': const Color(0xFF1E88E5)},

    // 5. MANAJEMEN DIRI (Green Theme)
    {'q': "Apakah Anda merasa jadwal harian Anda terlalu padat?", 'cat': 'Manajemen', 'color': const Color(0xFF43A047)},
    {'q': "Apakah Anda sering menunda pekerjaan (prokrastinasi) karena takut gagal?", 'cat': 'Manajemen', 'color': const Color(0xFF43A047)},
    {'q': "Apakah Anda khawatir berlebihan tentang masalah keuangan?", 'cat': 'Manajemen', 'color': const Color(0xFF43A047)},
    {'q': "Apakah Anda merasa tidak punya waktu untuk 'Me Time'?", 'cat': 'Manajemen', 'color': const Color(0xFF43A047)},
    {'q': "Apakah Anda merasa sulit mengambil keputusan sederhana?", 'cat': 'Manajemen', 'color': const Color(0xFF43A047)},
    {'q': "Apakah Anda merasa kehilangan kendali atas hidup Anda?", 'cat': 'Manajemen', 'color': const Color(0xFF43A047)},
  ];

  // --- STATE JAWABAN ---
  final Map<int, int> _answers = {};

  // Opsi Jawaban
  final List<Map<String, dynamic>> _options = [
    {'label': 'Tidak Pernah', 'value': 0, 'emoji': '😊'},
    {'label': 'Jarang', 'value': 1, 'emoji': '🙂'},
    {'label': 'Kadang-kadang', 'value': 2, 'emoji': '😐'},
    {'label': 'Sering', 'value': 3, 'emoji': '😰'},
    {'label': 'Selalu', 'value': 4, 'emoji': '😫'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _questionsData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _calculateScore();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  // Fungsi untuk Lompat ke Halaman Tertentu (dari Grid)
  void _jumpToPage(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color currentColor = _questionsData[_currentIndex]['color'];
    String currentCat = _questionsData[_currentIndex]['cat'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFB),
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            top: -100,
            right: -50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                // UPDATE: withOpacity -> withValues(alpha: ...)
                color: currentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 2. CUSTOM APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.black87,
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      // Progress Bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / _questionsData.length,
                            backgroundColor: Colors.grey[200],
                            // Gunakan valueColor agar aman dari error 'color undefined'
                            valueColor: AlwaysStoppedAnimation<Color>(currentColor),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Tombol Grid untuk lihat semua soal
                      InkWell(
                        onTap: () => _showQuestionMap(currentColor),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            // UPDATE: withValues
                            color: currentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: currentColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${_currentIndex + 1}/${_questionsData.length}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: currentColor,
                                  fontSize: 14
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.grid_view_rounded, size: 18, color: currentColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. MAIN CONTENT
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _questionsData.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(index, currentColor, currentCat);
                    },
                  ),
                ),

                // 4. BOTTOM NAVIGATION
                _buildBottomControls(currentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL GRID PERTANYAAN ---
  void _showQuestionMap(Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle Bar
              const SizedBox(height: 12),
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Peta Soal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),

              // Legend / Keterangan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Row(
                  children: [
                    _buildLegendItem(themeColor, "Dijawab"),
                    const SizedBox(width: 15),
                    _buildLegendItem(Colors.white, "Belum", isBorder: true),
                    const SizedBox(width: 15),
                    _buildLegendItem(themeColor, "Saat Ini", isBorder: true, isCurrent: true),
                  ],
                ),
              ),
              const Divider(height: 30),

              // Grid Content
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: _questionsData.length,
                  itemBuilder: (context, index) {
                    bool isAnswered = _answers.containsKey(index);
                    bool isCurrent = index == _currentIndex;
                    
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context); // Tutup modal
                        _jumpToPage(index); // Pindah halaman
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAnswered ? themeColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrent 
                            ? Border.all(color: themeColor, width: 3)
                            : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: isAnswered ? Colors.white : (isCurrent ? themeColor : Colors.grey[700]),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isBorder = false, bool isCurrent = false}) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: isBorder ? Colors.white : color,
            borderRadius: BorderRadius.circular(4),
            border: (isBorder || isCurrent) 
              ? Border.all(color: isCurrent ? color : Colors.grey.shade300, width: isCurrent ? 3 : 1) 
              : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // --- WIDGET QUESTION CARD ---
  Widget _buildQuestionCard(int index, Color themeColor, String category) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // UPDATE: withValues
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category.toUpperCase(),
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _questionsData[index]['q'],
              key: ValueKey<int>(index),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.3),
            ),
          ),
          const SizedBox(height: 30),
          ..._options.map((option) => _buildOptionItem(index, option, themeColor)),
        ],
      ),
    );
  }

  // --- WIDGET ANSWER OPTION ---
  Widget _buildOptionItem(int qIndex, Map<String, dynamic> option, Color themeColor) {
    bool isSelected = _answers[qIndex] == option['value'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () {
          setState(() { _answers[qIndex] = option['value']; });
          Future.delayed(const Duration(milliseconds: 250), () {
            if (_currentIndex < _questionsData.length - 1) { _nextPage(); }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? themeColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? themeColor : Colors.grey.shade200, width: 2),
            boxShadow: isSelected
                // UPDATE: withValues
                ? [BoxShadow(color: themeColor.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Text(option['emoji'], style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option['label'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[800]),
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 20)
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BOTTOM CONTROLS ---
  Widget _buildBottomControls(Color themeColor) {
    bool isLastPage = _currentIndex == _questionsData.length - 1;
    bool hasAnswered = _answers.containsKey(_currentIndex);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          // UPDATE: withValues
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 0)
            IconButton(
              onPressed: _prevPage,
              icon: Icon(Icons.arrow_back_rounded, color: Colors.grey[600]),
              style: IconButton.styleFrom(backgroundColor: Colors.grey[100], padding: const EdgeInsets.all(12)),
            )
          else const SizedBox(width: 48),
          
          ElevatedButton(
            onPressed: hasAnswered ? (isLastPage ? _calculateScore : _nextPage) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: hasAnswered ? 4 : 0,
            ),
            child: Row(
              children: [
                Text(isLastPage ? "LIHAT HASIL" : "SELANJUTNYA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                if (!isLastPage) ...[const SizedBox(width: 8), const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18)]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA SKOR ---
  void _calculateScore() {
    int totalScore = 0;
    _answers.forEach((_, value) => totalScore += value);
    double maxPossible = _questionsData.length * 4.0;
    double percentage = (totalScore / maxPossible) * 100;

    String title, desc;
    Color color;
    IconData icon;

    if (percentage <= 25) {
      title = "Mental Sehat ✨"; desc = "Luar biasa! Kamu memegang kendali penuh atas stresmu."; color = const Color(0xFF43A047); icon = Icons.sentiment_very_satisfied_rounded;
    } else if (percentage <= 50) {
      title = "Stres Ringan 🌤️"; desc = "Ada sedikit tekanan, tapi masih dalam batas wajar."; color = const Color(0xFFFB8C00); icon = Icons.sentiment_neutral_rounded;
    } else if (percentage <= 75) {
      title = "Stres Sedang 🌩️"; desc = "Lampu kuning. Stres mulai mengganggu produktivitasmu."; color = const Color(0xFFF4511E); icon = Icons.warning_amber_rounded;
    } else {
      title = "Burnout Berat 🚨"; desc = "Zona merah. Tubuh dan pikiranmu berteriak minta istirahat."; color = const Color(0xFFD32F2F); icon = Icons.health_and_safety_rounded;
    }
    _showResultModal(percentage, title, desc, color, icon);
  }

  // --- RESULT MODAL ---
  void _showResultModal(double score, String title, String desc, Color color, IconData icon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  // UPDATE: withValues
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle, 
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2)
                ),
                child: Icon(icon, size: 70, color: color),
              ),
              const SizedBox(height: 24),
              Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              Text("Tingkat Stress: ${score.toStringAsFixed(0)}%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF5FBFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 8),
                  onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                  child: const Text("Selesai", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}