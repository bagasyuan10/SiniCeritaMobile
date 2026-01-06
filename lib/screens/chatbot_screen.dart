import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Haptic Feedback
import 'package:intl/intl.dart'; // Wajib: flutter pub add intl
import '../services/deepseek_service.dart'; // Pastikan path ini sesuai dengan struktur foldermu

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // --- SERVICE AI (INTEGRASI BARU) ---
  final DeepSeekService _aiService = DeepSeekService();

  // --- PALET WARNA ---
  final Color primaryTeal = const Color(0xFF00897B);
  final Color darkTeal = const Color(0xFF004D40);
  final Color softSurface = const Color(0xFFF5FBFB);
  final Color errorColor = const Color(0xFFE57373);
  final Color warningColor = const Color(0xFFFFA726); // Warna Oranye untuk Token Habis

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // State Variables
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isInputLocked = false; // Kunci input jika token habis

  final List<String> _suggestions = [
    "😔 Lagi sedih banget",
    "😰 Aku merasa cemas",
    "😡 Susah kontrol emosi",
    "💡 Butuh motivasi",
    "💤 Susah tidur",
  ];

  @override
  void initState() {
    super.initState();
    // Pesan pembuka
    _addMessage(
      "Halo, Sahabat SiniCerita! 👋\nAku siap mendengarkan. Jangan ragu cerita apa saja ya.", 
      false
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIKA UTAMA ---

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty || _isInputLocked) return;

    _textController.clear();
    HapticFeedback.lightImpact(); 

    // 1. Tampilkan pesan User
    _addMessage(text, true);

    // 2. Loading State
    setState(() {
      _isTyping = true;
    });

    // 3. Panggil AI
    _getAIResponse(text);
  }

  // FUNGSI INI SUDAH DI-UPDATE MENGGUNAKAN SERVICE ASLI
Future<void> _getAIResponse(String userText) async {
    try {
      if (!mounted) return;

      String responseText = await _aiService.sendMessage(userText);
      
      if (!mounted) return;

      _addMessage(responseText, false);

    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = "Maaf, ada gangguan teknis.";
      bool isQuotaError = false;

      // PERBAIKAN: Ganti print dengan debugPrint
      debugPrint("Error Chatbot: $e"); 

      if (e.toString().contains("QUOTA_EXCEEDED")) {
        errorMessage = "🔋 Energi AI Habis\nKuota curhat harianmu sudah mencapai batas. Istirahat dulu ya, kita lanjut lagi besok!";
        isQuotaError = true;
        
        setState(() {
          _isInputLocked = true;
        });
      } else if (e.toString().contains("API_TOKEN_MISSING")) {
        errorMessage = "⚠️ Konfigurasi Error\nAPI Key belum diatur. Silakan cek file .env Anda.";
      } else if (e.toString().contains("TimeoutException") || e.toString().contains("SocketException")) {
        errorMessage = "⚠️ Koneksi Terputus\nGagal menghubungi server AI. Periksa internetmu.";
      } else {
        errorMessage = "⚠️ Sistem Sedang Sibuk\nTerjadi kesalahan teknis. Coba lagi nanti.";
      }

      _addMessage(errorMessage, false, isError: true, isQuotaError: isQuotaError);

    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  void _addMessage(String text, bool isUser, {bool isError = false, bool isQuotaError = false}) {
    setState(() {
      _messages.insert(0, {
        "text": text,
        "isUser": isUser,
        "isError": isError,
        "isQuotaError": isQuotaError,
        "time": DateTime.now(),
      });
    });
  }

  // --- UI BUILDING BLOCKS (TIDAK ADA PERUBAHAN SIGNIFIKAN) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softSurface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 1. LIST PESAN
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(
                  msg['text'], 
                  msg['isUser'], 
                  msg['time'],
                  isError: msg['isError'] ?? false,
                  isQuotaError: msg['isQuotaError'] ?? false, 
                );
              },
            ),
          ),

          // 2. INDIKATOR MENGETIK
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(radius: 12, backgroundColor: primaryTeal, child: const Icon(Icons.smart_toy_rounded, size: 14, color: Colors.white)),
                  const SizedBox(width: 8),
                  const Text("Sedang mengetik", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const LottieDots(),
                ],
              ),
            ),

          // 3. SUGGESTION CHIPS 
          if (!_isTyping && !_isInputLocked && MediaQuery.of(context).viewInsets.bottom == 0)
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(_suggestions[index]),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: primaryTeal.withValues(alpha: 0.3)),
                    labelStyle: TextStyle(color: primaryTeal, fontSize: 12),
                    onPressed: () => _handleSubmitted(_suggestions[index]),
                  );
                },
              ),
            ),

          // 4. INPUT AREA 
          _isInputLocked ? _buildLockedInput() : _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkTeal,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ruang Curhat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: _isInputLocked ? Colors.orange : Colors.greenAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(_isInputLocked ? "Istirahat" : "Online 24/7", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, DateTime time, {bool isError = false, bool isQuotaError = false}) {
    final String timeStr = DateFormat('HH:mm').format(time);

    // --- LOGIKA WARNA BUBBLE ---
    Color bubbleColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black87;
    Widget? iconHeader;

    if (isUser) {
      textColor = Colors.white; 
    } else if (isError) {
      if (isQuotaError) {
        // STYLE: KUOTA HABIS (Oranye/Krem)
        bubbleColor = const Color(0xFFFFF3E0); 
        borderColor = warningColor;
        iconHeader = Icon(Icons.battery_alert_rounded, size: 16, color: Colors.orange.shade900);
      } else {
        // STYLE: ERROR SISTEM (Merah)
        bubbleColor = const Color(0xFFFFEBEE);
        borderColor = errorColor;
        iconHeader = Icon(Icons.error_outline_rounded, size: 16, color: errorColor);
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? null : bubbleColor,
              gradient: (isUser && !isError) ? LinearGradient(colors: [primaryTeal, const Color(0xFF00695C)]) : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              border: isError ? Border.all(color: borderColor) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (iconHeader != null) ...[
                   Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       iconHeader,
                       const SizedBox(width: 6),
                       Text(
                         isQuotaError ? "Limit Tercapai" : "Gagal Mengirim", 
                         style: TextStyle(color: isQuotaError ? Colors.orange.shade900 : errorColor, fontWeight: FontWeight.bold, fontSize: 12)
                       ),
                     ],
                   ),
                   const SizedBox(height: 6),
                ],
                Text(text, style: TextStyle(color: textColor, fontSize: 15, height: 1.4)),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timeStr,
                    style: TextStyle(fontSize: 10, color: isUser ? Colors.white.withValues(alpha: 0.7) : Colors.grey.withValues(alpha: 0.5)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10)]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: softSurface, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1, maxLines: 4,
                  decoration: const InputDecoration(hintText: "Ceritakan di sini...", hintStyle: TextStyle(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: primaryTeal, shape: const CircleBorder(), elevation: 4, shadowColor: primaryTeal.withValues(alpha: 0.4),
              child: InkWell(
                onTap: () => _handleSubmitted(_textController.text),
                customBorder: const CircleBorder(),
                child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.send_rounded, color: Colors.white, size: 22)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              "Sesi hari ini selesai. Sampai jumpa besok! 🌙",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class LottieDots extends StatefulWidget {
  const LottieDots({super.key});
  @override
  State<LottieDots> createState() => _LottieDotsState();
}

class _LottieDotsState extends State<LottieDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            double opacity = (index == (_controller.value * 3).floor()) ? 1.0 : 0.3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: CircleAvatar(radius: 2, backgroundColor: Colors.grey.withValues(alpha: opacity)),
            );
          }),
        );
      },
    );
  }
}