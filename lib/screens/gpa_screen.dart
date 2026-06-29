import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class GPAScreen extends StatefulWidget {
  const GPAScreen({super.key});

  @override
  State<GPAScreen> createState() => _GPAScreenState();
}

class _GPAScreenState extends State<GPAScreen> {
  final List<Map<String, dynamic>> _courses = [];
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();

  String _selectedGrade = 'A';
  double _gpa = 0.0;
  double _cgpa = 0.0;
  int _totalCredits = 0;

  final Map<String, double> _gradePoints = {
    'A': 5.0, 'B': 4.0, 'C': 3.0, 'D': 2.0, 'F': 0.0,
  };

  final Map<String, String> _gradeMeaning = {
    'A': 'Excellent (70-100%)',
    'B': 'Very Good (60-69%)',
    'C': 'Good (50-59%)',
    'D': 'Pass (45-49%)',
    'F': 'Fail (Below 45%)',
  };

  void _addCourse() {
    if (_courseController.text.trim().isEmpty || _creditController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final credit = int.tryParse(_creditController.text.trim());
    if (credit == null || credit < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credit unit must be a valid number')),
      );
      return;
    }

    setState(() {
      _courses.add({
        'name': _courseController.text.trim().toUpperCase(),
        'credit': credit,
        'grade': _selectedGrade,
        'points': _gradePoints[_selectedGrade]! * credit,
      });
      _courseController.clear();
      _creditController.clear();
      _calculateGPA();
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      _calculateGPA();
    });
  }

  void _calculateGPA() {
    if (_courses.isEmpty) {
      setState(() {
        _gpa = 0.0;
        _cgpa = 0.0;
        _totalCredits = 0;
      });
      return;
    }

    double totalPoints = 0;
    int totalCredits = 0;

    for (var course in _courses) {
      totalPoints += course['points'] as double;
      totalCredits += course['credit'] as int;
    }

    setState(() {
      _gpa = totalPoints / totalCredits;
      _cgpa = _gpa;
      _totalCredits = totalCredits;
    });
  }

  String _getClassification(double cgpa) {
    if (cgpa >= 4.50) return 'First Class Honours 🏆';
    if (cgpa >= 3.50) return 'Second Class Upper 🥈';
    if (cgpa >= 2.50) return 'Second Class Lower 🥉';
    if (cgpa >= 2.00) return 'Third Class Honours 📜';
    if (cgpa >= 1.00) return 'Pass ✅';
    return 'Fail ❌';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('GPA Calculator'),
        elevation: 2,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Card - Improved
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Add New Course",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course Code',
                        hintText: 'e.g. CSC 101',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _creditController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Credit Units',
                              hintText: 'e.g. 3',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedGrade,
                            decoration: const InputDecoration(
                              labelText: 'Grade',
                              border: OutlineInputBorder(),
                            ),
                            items: _gradePoints.keys.map((grade) {
                              return DropdownMenuItem(
                                value: grade,
                                child: Row(
                                  children: [
                                    Text(
                                      grade,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _gradeMeaning[grade] ?? '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedGrade = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addCourse,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Course', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Course List - Improved
            if (_courses.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Added Courses (${_courses.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            course['grade'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        course['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textColor,
                        ),
                      ),
                      subtitle: Text(
                        '${course['credit']} Credits',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${course['points'].toStringAsFixed(1)} pts',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                            onPressed: () => _removeCourse(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Results Section - Improved
            if (_courses.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: AppTheme.primaryColor.withOpacity(0.06),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildResultColumn('GPA', _gpa.toStringAsFixed(2)),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey[300],
                          ),
                          _buildResultColumn('CGPA', _cgpa.toStringAsFixed(2)),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey[300],
                          ),
                          _buildResultColumn('Credits', _totalCredits.toString()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getClassification(_cgpa),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_courses.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calculate_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No courses added yet',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add courses above to calculate GPA',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.subtitleColor,
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

  Widget _buildResultColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.subtitleColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
