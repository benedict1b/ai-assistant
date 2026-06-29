import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

Future<void> seedKnowledgeBase() async {
  final dbService = DatabaseService();
  final db = await dbService.database;

  final count = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM faqs')
  ) ?? 0;

  if (count == 0) {
    final initialData = [
      {'question': 'What is the minimum credit load?', 'answer': 'Full-time students must register for a minimum of 15 credit units per semester.', 'category': 'academic', 'keywords': 'credit load minimum units'},
      {'question': 'How do I calculate my GPA?', 'answer': 'GPA = Total Quality Points / Total Credit Units. Grade Points: A=5, B=4, C=3, D=2, E=1, F=0.', 'category': 'academic', 'keywords': 'gpa grade calculate cgpa'},
      {'question': 'Where is the library located?', 'answer': 'The University Main Library is located beside the Faculty of Computing and Information Technology.', 'category': 'campus', 'keywords': 'library location building'},
    ];

    for (var item in initialData) {
      await db.insert('faqs', {
        'question': item['question'],
        'answer': item['answer'],
        'category': item['category'],
        'keywords': item['keywords'],
      });
    }
    print("✅ NAUB Knowledge Base Seeded Successfully!");
  }
}
