import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _offlineMode = true;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _offlineMode = prefs.getBool('offline_mode') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_mode', _offlineMode);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setBool('notifications', _notifications);

    // =============================================
    // APPLY DARK MODE IMMEDIATELY
    // =============================================
    if (mounted) {
      // Rebuild the entire app to apply theme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Settings saved successfully'),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use dark or light theme
    final isDark = _darkMode;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 2,
        backgroundColor: isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =============================================
            // PREFERENCES CARD
            // =============================================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? AppTheme.darkCardColor : AppTheme.cardColor,
              child: Column(
                children: [
                  // Offline Mode
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          _offlineMode ? Icons.wifi_off : Icons.wifi,
                          color: _offlineMode ? Colors.orange : Colors.green,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Offline Mode',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextColor : AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _offlineMode
                          ? 'App works without internet using local database'
                          : 'AI responses require internet connection',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkSubtitleColor : AppTheme.subtitleColor,
                      ),
                    ),
                    value: _offlineMode,
                    onChanged: (value) => setState(() => _offlineMode = value),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  
                  // Dark Mode
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color: _darkMode ? Colors.purple : Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextColor : AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _darkMode ? 'Dark theme enabled' : 'Light theme enabled',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkSubtitleColor : AppTheme.subtitleColor,
                      ),
                    ),
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  
                  // Push Notifications
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: _notifications ? Colors.red : Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Push Notifications',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextColor : AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _notifications
                          ? '🔔 You will receive notifications for new news'
                          : '🔕 Notifications are disabled',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _notifications 
                            ? (isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
                            : (isDark ? AppTheme.darkSubtitleColor : AppTheme.subtitleColor),
                      ),
                    ),
                    value: _notifications,
                    onChanged: (value) => setState(() => _notifications = value),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =============================================
            // SAVE BUTTON
            // =============================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =============================================
            // ABOUT CARD
            // =============================================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? AppTheme.darkCardColor : AppTheme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school,
                            color: isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'NAUB AI',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextColor : AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                    const SizedBox(height: 12),

                    _buildInfoRow('Version', '1.0.3', isDark),
                    _buildInfoRow('University', 'Nigerian Army University Biu', isDark),
                    _buildInfoRow('Developed for', 'NAUB Students & Staff', isDark),
                    _buildInfoRow('Database', 'Offline-First Architecture', isDark),
                    _buildInfoRow(
                      'Notifications',
                      _notifications ? '✅ Enabled' : '❌ Disabled',
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'An intelligent assistant designed to support academic success and campus life at NAUB.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? AppTheme.darkSubtitleColor : AppTheme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // =============================================
            // FOOTER
            // =============================================
            Text(
              'Made with ❤️ for NAUB Community',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 NAUB AI - v1.0.3',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? AppTheme.darkSubtitleColor : AppTheme.subtitleColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isDark ? AppTheme.darkTextColor : AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}