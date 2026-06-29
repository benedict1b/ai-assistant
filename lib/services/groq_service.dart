import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      return "⚠️ API key not configured. Please check your .env file.";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'You are NAUB AI, a helpful assistant for students of Nigerian Army University Biu. Provide clear, accurate answers.'
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'];
        return text?.toString().trim() ?? "Sorry, I couldn't generate a response.";
      } else {
        return "⚠️ Error ${response.statusCode}. Please try again.";
      }
    } catch (e) {
      print('Groq Error: $e');
      return "⚠️ Connection error. Please check your internet.";
    }
  }

  static String getOfflineResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('fee') || q.contains('school')) return 'New Science: ₦84,500 | Arts: ₦64,500';
    if (q.contains('cut off') || q.contains('admission')) return 'Minimum UTME cut-off is 180.';
    if (q.contains('gpa')) return 'GPA = Σ(Grade Points × Credit Units) / Σ(Credit Units)';
    if (q.contains('library')) return 'The library is in Block A, Main Academic Building.';
    if (q.contains('hostel')) return 'Hostel rules: No visitors after 10PM, no cooking in rooms.';
    return "I'm in offline mode. Connect to the internet for full answers.";
  }
}
