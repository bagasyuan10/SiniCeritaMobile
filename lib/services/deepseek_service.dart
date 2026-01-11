import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekService {
  final String _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  final String _baseUrl = dotenv.env['DEEPSEEK_BASE_URL'] ?? 'https://api.deepseek.com/chat/completions';
  final String _model = dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-chat';
  
  // History chat agar bot punya konteks percakapan
  final List<Map<String, String>> _history = [
    {
      "role": "system", 
      "content": "Kamu adalah teman curhat yang empatik dari SiniCerita. Jawab dengan singkat, hangat, dan suportif. Gunakan bahasa Indonesia gaul tapi sopan."
    }
  ];

  Future<String> sendMessage(String userMessage) async {
    // 1. Cek API Key sebelum request
    if (_apiKey.isEmpty) {
      throw Exception("API_TOKEN_MISSING");
    }

    // 2. Tambahkan pesan user ke history
    _history.add({"role": "user", "content": userMessage});

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": _model,
          "messages": _history,
          "temperature": 0.7, // Kreativitas (0.0 - 1.0)
          "max_tokens": 500,  // Batas panjang jawaban
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // 3. Decode jawaban (Penting untuk Emoji & Unicode)
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botContent = data['choices'][0]['message']['content'];
        
        // Simpan jawaban bot ke history
        _history.add({"role": "assistant", "content": botContent});
        
        return botContent;

      } else if (response.statusCode == 402 || response.statusCode == 429) {
        // Error khusus untuk ditangkap UI (Kuota Habis)
        throw Exception("QUOTA_EXCEEDED");

      } else {
        debugPrint("API Error: ${response.body}");
        throw Exception("API_ERROR code: ${response.statusCode}");
      }

    } catch (e) {
      // Jika request gagal, hapus pesan user terakhir agar tidak merusak flow history berikutnya
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      
      rethrow; // Lempar error ke UI
    }
  }
  
  // Reset percakapan
  void clearHistory() {
    // Hapus semua kecuali System Prompt (index 0)
    if (_history.length > 1) {
      _history.removeRange(1, _history.length);
    }
  }
}