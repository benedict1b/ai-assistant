import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  // =============================================
  // CREATE CHAT HISTORY TABLE
  // =============================================
  Future<void> initChatHistory(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        messages TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // =============================================
  // SAVE CHAT
  // =============================================
  Future<int> saveChat(String title, List<Map<String, String>> messages) async {
    final db = await DatabaseService().database;
    
    // Check if table exists
    await initChatHistory(db);
    
    final now = DateTime.now().toIso8601String();
    final messagesJson = jsonEncode(messages);
    
    // Check if chat with same title exists (update if yes)
    final existing = await db.query(
      'chat_history',
      where: 'title = ?',
      whereArgs: [title],
    );
    
    if (existing.isNotEmpty) {
      // Update existing chat
      await db.update(
        'chat_history',
        {
          'messages': messagesJson,
          'updatedAt': now,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
      // =============================================
      // FIX: Cast to int before returning
      // =============================================
      return existing.first['id'] as int;
    } else {
      // Insert new chat
      return await db.insert('chat_history', {
        'title': title,
        'messages': messagesJson,
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

  // =============================================
  // GET ALL CHATS
  // =============================================
  Future<List<Map<String, dynamic>>> getAllChats() async {
    final db = await DatabaseService().database;
    await initChatHistory(db);
    
    final results = await db.query(
      'chat_history',
      orderBy: 'updatedAt DESC',
    );
    
    return results.map((chat) {
      // Parse messages back to List<Map<String, String>>
      final messagesJson = chat['messages'] as String;
      final messages = jsonDecode(messagesJson) as List<dynamic>;
      
      return {
        'id': chat['id'],
        'title': chat['title'],
        'messages': messages.map((msg) => Map<String, String>.from(msg)).toList(),
        'createdAt': chat['createdAt'],
        'updatedAt': chat['updatedAt'],
      };
    }).toList();
  }

  // =============================================
  // GET CHAT BY ID
  // =============================================
  Future<Map<String, dynamic>?> getChatById(int id) async {
    final db = await DatabaseService().database;
    await initChatHistory(db);
    
    final results = await db.query(
      'chat_history',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) return null;
    
    final chat = results.first;
    final messagesJson = chat['messages'] as String;
    final messages = jsonDecode(messagesJson) as List<dynamic>;
    
    return {
      'id': chat['id'],
      'title': chat['title'],
      'messages': messages.map((msg) => Map<String, String>.from(msg)).toList(),
      'createdAt': chat['createdAt'],
      'updatedAt': chat['updatedAt'],
    };
  }

  // =============================================
  // SEARCH CHATS
  // =============================================
  Future<List<Map<String, dynamic>>> searchChats(String query) async {
    final db = await DatabaseService().database;
    await initChatHistory(db);
    
    final results = await db.query(
      'chat_history',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    
    return results.map((chat) {
      final messagesJson = chat['messages'] as String;
      final messages = jsonDecode(messagesJson) as List<dynamic>;
      
      return {
        'id': chat['id'],
        'title': chat['title'],
        'messages': messages.map((msg) => Map<String, String>.from(msg)).toList(),
        'createdAt': chat['createdAt'],
        'updatedAt': chat['updatedAt'],
      };
    }).toList();
  }

  // =============================================
  // DELETE CHAT
  // =============================================
  Future<void> deleteChat(int id) async {
    final db = await DatabaseService().database;
    await db.delete(
      'chat_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =============================================
  // CLEAR ALL CHATS
  // =============================================
  Future<void> clearAllChats() async {
    final db = await DatabaseService().database;
    await db.delete('chat_history');
  }

  // =============================================
  // GENERATE CHAT TITLE
  // =============================================
  String generateTitle(List<Map<String, String>> messages) {
    if (messages.isEmpty) return 'New Chat';
    
    // Use the first user message as title
    final firstUserMessage = messages.firstWhere(
      (msg) => msg['role'] == 'user',
      orElse: () => {'content': 'Chat'},
    );
    
    String title = firstUserMessage['content'] ?? 'Chat';
    if (title.length > 30) {
      title = title.substring(0, 30) + '...';
    }
    return title;
  }
}