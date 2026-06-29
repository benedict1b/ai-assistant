import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';
import 'database_service.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  // Your Blogger RSS/Atom feed URL
  static const String FEED_URL = 'https://naubnewshub.blogspot.com/feeds/posts/default';

  Future<void> initNews(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS news(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        date TEXT,
        category TEXT,
        link TEXT,
        isRead INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT
      )
    ''');

    // Seed default news if empty
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM news')
    ) ?? 0;

    if (count == 0) {
      await _seedDefaultNews(db);
    }
  }

  Future<void> _seedDefaultNews(Database db) async {
    final List<Map<String, dynamic>> defaultNews = [
      {
        'title': 'Welcome to NAUB AI News',
        'summary': 'Stay updated with the latest news from Nigerian Army University Biu.',
        'date': DateTime.now().toString(),
        'category': 'General',
        'link': '',
        'isRead': 0,
        'isFavorite': 0,
        'createdAt': DateTime.now().toIso8601String()
      },
    ];

    for (var news in defaultNews) {
      await db.insert('news', news, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // =============================================
  // FETCH NEWS FROM BLOGGER RSS/ATOM FEED
  // =============================================
  Future<int> fetchNewsFromBlog() async {
    try {
      final response = await http.get(Uri.parse(FEED_URL));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final entries = document.findAllElements('entry');
        final db = await DatabaseService().database;
        int addedCount = 0;

        for (var entry in entries) {
          // Get title
          final titleElement = entry.findElements('title').firstOrNull;
          final title = titleElement?.text ?? 'Untitled';

          // Get summary
          final summaryElement = entry.findElements('summary').firstOrNull;
          final summary = summaryElement?.text ?? '';

          // Get date
          final dateElement = entry.findElements('published').firstOrNull;
          final date = dateElement?.text ?? DateTime.now().toIso8601String();

          // Get link
          final linkElement = entry.findElements('link').firstOrNull;
          final link = linkElement?.getAttribute('href') ?? '';

          // Check if news already exists
          final existing = await db.query(
            'news',
            where: 'title = ?',
            whereArgs: [title],
          );

          if (existing.isEmpty && title != 'Untitled') {
            await db.insert('news', {
              'title': title,
              'summary': summary,
              'date': date,
              'category': 'Blog Post',
              'link': link,
              'isRead': 0,
              'isFavorite': 0,
              'createdAt': DateTime.now().toIso8601String(),
            });
            addedCount++;
          }
        }

        return addedCount;
      } else {
        print('Failed to fetch news: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching news: $e');
      return 0;
    }
  }

  // =============================================
  // GET NEWS
  // =============================================
  Future<List<Map<String, dynamic>>> getAllNews() async {
    final db = await DatabaseService().database;
    return await db.query(
      'news',
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnreadNews() async {
    final db = await DatabaseService().database;
    return await db.query(
      'news',
      where: 'isRead = 0',
      orderBy: 'date DESC',
    );
  }

  Future<int> getUnreadCount() async {
    final db = await DatabaseService().database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM news WHERE isRead = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getFavoriteNews() async {
    final db = await DatabaseService().database;
    return await db.query(
      'news',
      where: 'isFavorite = 1',
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchNews(String query) async {
    final db = await DatabaseService().database;
    return await db.query(
      'news',
      where: 'title LIKE ? OR summary LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getNewsByCategory(String category) async {
    final db = await DatabaseService().database;
    return await db.query(
      'news',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
  }

  Future<List<String>> getCategories() async {
    final db = await DatabaseService().database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM news');
    return result.map((row) => row['category'] as String).toList();
  }

  // =============================================
  // ACTIONS
  // =============================================
  Future<void> markAsRead(int id) async {
    final db = await DatabaseService().database;
    await db.update(
      'news',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsRead() async {
    final db = await DatabaseService().database;
    await db.update('news', {'isRead': 1});
  }

  Future<void> toggleFavorite(int id) async {
    final db = await DatabaseService().database;
    final news = await db.query('news', where: 'id = ?', whereArgs: [id]);
    if (news.isNotEmpty) {
      final current = news.first['isFavorite'] as int;
      await db.update(
        'news',
        {'isFavorite': current == 1 ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> addNews(String title, String summary, String category, {String? link}) async {
    final db = await DatabaseService().database;
    await db.insert('news', {
      'title': title,
      'summary': summary,
      'date': DateTime.now().toString(),
      'category': category,
      'link': link ?? '',
      'isRead': 0,
      'isFavorite': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // =============================================
  // SYNC
  // =============================================
  Future<int> syncNews() async {
    try {
      final added = await fetchNewsFromBlog();
      return added;
    } catch (e) {
      print('Sync error: $e');
      return 0;
    }
  }

  Future<void> deleteNews(int id) async {
    final db = await DatabaseService().database;
    await db.delete('news', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllNews() async {
    final db = await DatabaseService().database;
    await db.delete('news');
  }
}
