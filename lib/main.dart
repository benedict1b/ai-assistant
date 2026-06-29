import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_theme.dart';
import 'screens/chat_assistant_screen.dart';
import 'screens/gpa_screen.dart';
import 'screens/handbook_screen.dart';
import 'screens/news_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/campus_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'services/news_service.dart';
import 'services/database_service.dart';
import 'services/knowledge_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  print("✅ API Key loaded: ${dotenv.env['GROQ_API_KEY'] != null}");
  
  // Initialize database
  try {
    final db = DatabaseService();
    await db.database;
    await seedKnowledgeBase();
    print("✅ Database initialized");
  } catch (e) {
    print("❌ Database error: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAUB AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isOnline = true;
  bool _isDarkMode = false;
  int _currentIndex = 0;
  int _unreadCount = 0;
  Timer? _timer;
  final NewsService _newsService = NewsService();

  // Lazy loading: screens are created only when needed
  final List<Widget Function()> _screenBuilders = [
    () => const ChatAssistantScreen(),
    () => const GPAScreen(),
    () => const HandbookScreen(),
    () => const NewsScreen(),
    () => const PlannerScreen(),
    () => const CampusScreen(),
    () => const CalendarScreen(),
    () => const SettingsScreen(),
  ];

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _updateUnreadCount();
    _startNotificationTimer();
    _initializeScreens();
  }

  void _initializeScreens() {
    // Only create the first screen initially (lazy loading)
    _screens = List.generate(_screenBuilders.length, (index) {
      if (index == 0) {
        return _screenBuilders[index](); // Load first screen immediately
      } else {
        return Container(); // Placeholder for other screens
      }
    });
  }

  void _loadScreen(int index) {
    if (index < _screens.length && _screens[index] is Container) {
      setState(() {
        _screens[index] = _screenBuilders[index]();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOnline = prefs.getBool('offline_mode') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _updateUnreadCount() async {
    try {
      final count = await _newsService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Error getting unread count: $e');
    }
  }

  void _startNotificationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications') ?? true;
      
      if (notificationsEnabled) {
        final added = await _newsService.fetchNewsFromBlog();
        if (added > 0) {
          await _updateUnreadCount();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📰 $added new news articles!'),
                duration: const Duration(seconds: 3),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          }
        } else {
          await _updateUnreadCount();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    
    return MaterialApp(
      title: 'NAUB AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.school, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'NAUB AI',
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          elevation: 2,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3;
                      _loadScreen(3);
                    });
                    Navigator.pop(context);
                  },
                  tooltip: 'News & Announcements',
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('👤 Profile coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens.map((screen) => screen).toList(),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: _isDarkMode ? AppTheme.darkCardColor : Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.school,
                      color: AppTheme.primaryColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NAUB AI',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Official Student Assistant',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildDrawerItem(Icons.chat_bubble_outline, 'Chat Assistant', 0),
            _buildDrawerItem(Icons.calculate_outlined, 'GPA Calculator', 1),
            _buildDrawerItem(Icons.book_outlined, 'Student Handbook', 2),
            _buildDrawerItem(
              Icons.newspaper,
              'News & Announcements',
              3,
              trailing: _unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            _buildDrawerItem(Icons.event_note_outlined, 'Study Planner', 4),
            _buildDrawerItem(Icons.location_on_outlined, 'Campus Guide', 5),
            _buildDrawerItem(Icons.calendar_today_outlined, 'Academic Calendar', 6),
            const Divider(),
            _buildDrawerItem(Icons.settings_outlined, 'Settings', 7),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    color: _isOnline ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isOnline ? 'Online Mode' : 'Offline Mode',
                    style: GoogleFonts.poppins(
                      color: _isDarkMode ? Colors.white70 : Colors.grey[700],
                      fontSize: 13,
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

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int index, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: _isDarkMode ? Colors.white70 : Colors.grey[700]),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: trailing,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _currentIndex = index;
          _loadScreen(index);
        });
      },
    );
  }
}
