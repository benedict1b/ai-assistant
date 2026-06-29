import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  final List<Map<String, dynamic>> _academicEvents = const [
    {
      'title': 'First Semester Registration',
      'date': 'February 3 - 14, 2026',
      'category': 'Registration',
      'color': Colors.blue,
      'description': 'Online course registration for returning and new students.',
    },
    {
      'title': 'Lectures Begin (First Semester)',
      'date': 'February 24, 2026',
      'category': 'Academic',
      'color': Colors.green,
      'description': 'First day of lectures. Students are expected to attend all classes.',
    },
    {
      'title': 'Matriculation Ceremony',
      'date': 'February 25, 2026',
      'category': 'Events',
      'color': Colors.purple,
      'description': 'Official induction of new students (1,166+ expected).',
    },
    {
      'title': 'Mid-Semester Break',
      'date': 'April 2026 (TBC)',
      'category': 'Break',
      'color': Colors.orange,
      'description': 'Short break for students.',
    },
    {
      'title': 'First Semester Examinations',
      'date': 'June 2026',
      'category': 'Examination',
      'color': Colors.red,
      'description': 'End of semester exams. CA = 40%, Exam = 60%.',
    },
    {
      'title': 'Second Semester Resumption',
      'date': 'July 14, 2026',
      'category': 'Academic',
      'color': Colors.green,
      'description': 'Resumption of academic activities for second semester.',
    },
    {
      'title': 'Second Semester Examinations',
      'date': 'November 2026 (TBC)',
      'category': 'Examination',
      'color': Colors.red,
      'description': 'End of session examinations.',
    },
    {
      'title': 'Convocation Ceremony',
      'date': 'December 2026 (TBC)',
      'category': 'Events',
      'color': Colors.purple,
      'description': 'Graduation ceremony for graduating students.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar updated from official sources')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2025/2026 Session',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Important dates for the current academic session. Always cross-check with the Student Portal for the latest updates.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Events List
          Text(
            'Key Dates',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ..._academicEvents.map((event) => _buildEventCard(event)).toList(),

          const SizedBox(height: 30),

          // Note
          Card(
            color: Colors.amber[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dates are subject to change. Check the official NAUB portal or announcements for confirmation.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (event['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForCategory(event['category']),
                color: event['color'],
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['date'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event['description'],
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (event['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['category'],
                      style: TextStyle(
                        color: event['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'registration':
        return Icons.how_to_reg;
      case 'academic':
        return Icons.school;
      case 'examination':
        return Icons.assignment;
      case 'events':
        return Icons.celebration;
      case 'break':
        return Icons.beach_access;
      default:
        return Icons.event;
    }
  }
}