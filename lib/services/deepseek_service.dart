import 'dart:convert';
import 'package:flutter/foundation.dart'; // TAMBAHKAN INI untuk debugPrint
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekService {
  final String _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  final String _baseUrl = dotenv.env['DEEPSEEK_BASE_URL'] ?? 'https://api.deepseek.com/chat/completions';
  final String _model = dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-chat';
  
  final List<Map<String, String>> _history = [
    {
      "role": "system", 
      "content": "Kamu adalah teman curhat yang empatik dari SiniCerita. Jawab dengan singkat, hangat, dan suportif. Gunakan bahasa Indonesia gaul tapi sopan."
    }
  ];

  Future<String> sendMessage(String userMessage) async {
    if (_apiKey.isEmpty) {
      throw Exception("API_TOKEN_MISSING");
    }

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
          "temperature": 0.7,
          "max_tokens": 500,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botContent = data['choices'][0]['message']['content'];
        
        _history.add({"role": "assistant", "content": botContent});
        
        return botContent;

      } else if (response.statusCode == 402 || response.statusCode == 429) {
        throw Exception("QUOTA_EXCEEDED");

      } else {
        // PERBAIKAN 1: Ganti print dengan debugPrint
        debugPrint("API Error: ${response.body}");
        throw Exception("API_ERROR code: ${response.statusCode}");
      }

    } catch (e) {
      // PERBAIKAN 2: Ganti 'throw e' dengan 'rethrow'
      // Ini menjaga jejak error asli agar lebih mudah dilacak
      rethrow; 
    }
  }
  
  void clearHistory() {
    _history.removeRange(1, _history.length);
  }
}