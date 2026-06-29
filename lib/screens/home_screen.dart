import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import 'chat_screen.dart';  // ← Import the chat screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================================
              // HEADER
              // =============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'NAUB Student',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // =============================================
              // SEARCH BAR
              // =============================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Ask anything about NAUB...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onTap: () {
                          // Navigate to Chat when search is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // =============================================
              // QUICK ACTIONS
              // =============================================
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  // ===== CHAT =====
                  _buildAction(
                    context,
                    emoji: '💬',
                    label: 'Chat',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // ===== GPA =====
                  _buildAction(
                    context,
                    emoji: '📊',
                    label: 'GPA',
                    color: Colors.green,
                    onTap: () {
                      _showComingSoon(context, 'GPA Calculator');
                    },
                  ),
                  
                  // ===== HANDBOOK =====
                  _buildAction(
                    context,
                    emoji: '📖',
                    label: 'Handbook',
                    color: Colors.orange,
                    onTap: () {
                      _showComingSoon(context, 'Handbook');
                    },
                  ),
                  
                  // ===== CAMPUS =====
                  _buildAction(
                    context,
                    emoji: '📍',
                    label: 'Campus',
                    color: Colors.purple,
                    onTap: () {
                      _showComingSoon(context, 'Campus Guide');
                    },
                  ),
                  
                  // ===== CALENDAR =====
                  _buildAction(
                    context,
                    emoji: '📅',
                    label: 'Calendar',
                    color: Colors.red,
                    onTap: () {
                      _showComingSoon(context, 'Academic Calendar');
                    },
                  ),
                  
                  // ===== PLANNER =====
                  _buildAction(
                    context,
                    emoji: '📝',
                    label: 'Planner',
                    color: Colors.teal,
                    onTap: () {
                      _showComingSoon(context, 'Study Planner');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // =============================================
              // POPULAR QUESTIONS
              // =============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Chat when "See All" is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // FAQ Cards - each opens Chat with a pre-filled question
              _buildFAQ(
                context,
                question: 'How do I calculate my GPA?',
                onTap: () {
                  _navigateToChatWithQuestion(context, 'How do I calculate my GPA?');
                },
              ),
              _buildFAQ(
                context,
                question: 'What is the minimum credit load?',
                onTap: () {
                  _navigateToChatWithQuestion(context, 'What is the minimum credit load?');
                },
              ),
              _buildFAQ(
                context,
                question: 'Where is the library located?',
                onTap: () {
                  _navigateToChatWithQuestion(context, 'Where is the library located?');
                },
              ),
              _buildFAQ(
                context,
                question: 'When does registration start?',
                onTap: () {
                  _navigateToChatWithQuestion(context, 'When does registration start?');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================
  // Helper: Build Quick Action Button
  // =============================================
  Widget _buildAction(
    BuildContext context, {
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // Helper: Build FAQ Card
  // =============================================
  Widget _buildFAQ(
    BuildContext context, {
    required String question,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.help_outline, color: AppTheme.primaryColor),
        ),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // =============================================
  // Helper: Show "Coming Soon" Message
  // =============================================
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚀 $feature coming soon!'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  // =============================================
  // Helper: Navigate to Chat with Pre-filled Question
  // =============================================
  void _navigateToChatWithQuestion(BuildContext context, String question) {
    // This will be implemented when we add the ability to pre-fill messages
    // For now, just go to chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  }
}