import 'package:naub_ai_new/services/database_service.dart';

class ChatService {
  final DatabaseService _db = DatabaseService();

  Future<String> processQuery(String query) async {
    try {
      final results = await _db.searchFAQs(query);
      
      if (results.isNotEmpty) {
        return results.first['answer'];
      }
      
      return "I don't have an answer to that yet. 🤔\n\nTry rephrasing your question or check the student handbook.\n\nSome things I can help with:\n• GPA calculation\n• Registration dates\n• Campus locations\n• Hostel rules";
    } catch (e) {
      return "Sorry, I encountered an error. Please try again.";
    }
  }
}
