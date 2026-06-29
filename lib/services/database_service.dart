import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'news_service.dart';
import 'chat_history_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/naub_ai.db';
    return await openDatabase(
      path,
      version: 5, // Increased version to add Chat History table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // =============================================
    // 1. FAQs TABLE
    // =============================================
    await db.execute('''
      CREATE TABLE faqs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        category TEXT,
        keywords TEXT,
        upvotes INTEGER DEFAULT 0
      )
    ''');

    // =============================================
    // 2. SETTINGS TABLE
    // =============================================
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'key': 'notifications', 'value': 'true'});
    await db.insert('settings', {'key': 'offline_mode', 'value': 'true'});
    await db.insert('settings', {'key': 'dark_mode', 'value': 'false'});

    // =============================================
    // 3. CHAT HISTORY TABLE
    // =============================================
    final chatHistoryService = ChatHistoryService();
    await chatHistoryService.initChatHistory(db);

    // =============================================
    // 4. NEWS TABLE (via NewsService)
    // =============================================
    final newsService = NewsService();
    await newsService.initNews(db);

    // =============================================
    // 5. SEED FAQs
    // =============================================
    await _seedFAQs(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // =============================================
    // ADD CHAT HISTORY TABLE (Version 5)
    // =============================================
    if (oldVersion < 5) {
      final chatHistoryService = ChatHistoryService();
      await chatHistoryService.initChatHistory(db);
    }

    // =============================================
    // ADD SETTINGS TABLE (Version 4)
    // =============================================
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings(
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      
      await db.rawInsert(
        'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)',
        ['notifications', 'true']
      );
      await db.rawInsert(
        'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)',
        ['offline_mode', 'true']
      );
      await db.rawInsert(
        'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)',
        ['dark_mode', 'false']
      );
    }
    
    // =============================================
    // ADD NEWS TABLE (Version 3)
    // =============================================
    if (oldVersion < 3) {
      final newsService = NewsService();
      await newsService.initNews(db);
      
      await db.delete('faqs');
      await _seedFAQs(db);
    }
  }

  // =============================================
  // SETTINGS METHODS
  // =============================================
  
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)',
      [key, value]
    );
  }

  Future<bool> getBoolSetting(String key, {bool defaultValue = true}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  Future<void> setBoolSetting(String key, bool value) async {
    await setSetting(key, value ? 'true' : 'false');
  }

  // =============================================
  // FAQ METHODS
  // =============================================

  Future<void> _seedFAQs(Database db) async {
    final List<Map<String, dynamic>> faqs = [
      {
        'question': 'What is the UTME cut-off mark for NAUB?',
        'answer': 'The minimum UTME cut-off mark is 180. Candidates with 160 and above are eligible for Post-UTME screening in 2026/2027.',
        'category': 'admissions',
        'keywords': 'cut off mark utme jamb admission'
      },
      {
        'question': 'How do I apply for Post-UTME?',
        'answer': 'Go to https://my.naub.edu.ng/utme/ and register. Screening fee is ₦2,000. Upload required documents.',
        'category': 'admissions',
        'keywords': 'post utme screening apply'
      },
      {
        'question': 'What are the school fees for new students?',
        'answer': 'Science Programmes: ₦84,500\nArts & Social Sciences: ₦64,500\nAcceptance Fee: ₦5,000\nCheck official portal for latest updates.',
        'category': 'fees',
        'keywords': 'school fees charges tuition'
      },
      {
        'question': 'When is the academic calendar for 2025/2026?',
        'answer': 'First Semester registration: Feb 3–14, Lectures: Feb 24 – May 16, Matriculation: Feb 25, Exams: June.',
        'category': 'academic',
        'keywords': 'calendar registration matriculation'
      },
      {
        'question': 'Where is NAUB located?',
        'answer': 'No. 1 Gombe Road, PMB 1500, Biu, Borno State, Nigeria.',
        'category': 'campus',
        'keywords': 'location address biu'
      },
      {
        'question': 'What faculties and courses does NAUB offer?',
        'answer': 'Faculties: FAMSS, Computing, Engineering, Environmental Sciences, Natural & Applied Sciences. Courses include Computer Science, Cyber Security, Engineering, Criminology, Accounting, etc.',
        'category': 'academic',
        'keywords': 'courses programs faculties'
      },
      {
        'question': 'How do I pay school fees?',
        'answer': 'Pay through the student portal https://my.naub.edu.ng/ using Remita platform.',
        'category': 'fees',
        'keywords': 'pay fees portal remita'
      },
      {
        'question': 'What is the mission of NAUB?',
        'answer': 'To develop highly skilled military and civilian manpower with distinctive competence in technological solutions for the Nigerian Army and the nation.',
        'category': 'about',
        'keywords': 'mission vision'
      },
      {
        'question': 'Is NAUB strike-free?',
        'answer': 'Yes. NAUB is known for academic stability, no strikes, and strong focus on innovation and practical training.',
        'category': 'about',
        'keywords': 'strike asuu'
      },
      {
        'question': 'When is the next matriculation?',
        'answer': 'The 2025/2026 session matriculated 1,166 students. Check news or academic calendar for 2026/2027 dates.',
        'category': 'events',
        'keywords': 'matriculation'
      },
    ];

    for (var faq in faqs) {
      await db.insert('faqs', faq, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> searchFAQs(String query) async {
    final db = await database;
    return await db.query(
      'faqs',
      where: 'question LIKE ? OR answer LIKE ? OR keywords LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      limit: 15,
    );
  }

  Future<void> insertFAQ(String question, String answer, String category, String keywords) async {
    final db = await database;
    await db.insert('faqs', {
      'question': question,
      'answer': answer,
      'category': category,
      'keywords': keywords,
    });
  }

  Future<void> upvoteFAQ(int id) async {
    final db = await database;
    await db.rawUpdate('UPDATE faqs SET upvotes = upvotes + 1 WHERE id = ?', [id]);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
