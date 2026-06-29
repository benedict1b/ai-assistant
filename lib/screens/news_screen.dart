import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  List<Map<String, dynamic>> _news = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    
    // Fetch news from blog (if internet available)
    await _newsService.fetchNewsFromBlog();
    
    // Load all news
    final news = await _newsService.getAllNews();
    final unread = await _newsService.getUnreadCount();
    
    setState(() {
      _news = news;
      _unreadCount = unread;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(int id) async {
    await _newsService.markAsRead(id);
    // Update the unread count
    final unread = await _newsService.getUnreadCount();
    setState(() {
      _unreadCount = unread;
      // Update the specific item in the list
      final index = _news.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _news[index]['isRead'] = 1;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    await _newsService.markAllAsRead();
    final unread = await _newsService.getUnreadCount();
    setState(() {
      _unreadCount = unread;
      for (var item in _news) {
        item['isRead'] = 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ All news marked as read')),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('NAUB News'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
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
              ),
            ],
          ],
        ),
        elevation: 2,
        actions: [
          // Mark all as read
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
            tooltip: 'Refresh news',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                final results = await _newsService.searchNews(value);
                setState(() => _news = results);
              },
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadNews();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _news.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.newspaper, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No news found', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            Text('Pull down to refresh', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNews,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _news.length,
                          itemBuilder: (context, index) {
                            final item = _news[index];
                            final hasLink = item['link'] != null && 
                                          item['link'].toString().isNotEmpty;
                            final isRead = item['isRead'] == 1;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isRead ? Colors.white : Colors.blue[50],
                              child: InkWell(
                                onTap: () async {
                                  // Mark as read when tapped
                                  if (!isRead) {
                                    await _markAsRead(item['id']);
                                  }
                                  // Open link if available
                                  if (hasLink) {
                                    await _launchURL(item['link']);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Unread indicator (blue dot)
                                          if (!isRead)
                                            Container(
                                              width: 10,
                                              height: 10,
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          Chip(
                                            label: Text(item['category'] ?? 'General'),
                                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                            labelStyle: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            item['date'] ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        item['title'],
                                        style: GoogleFonts.poppins(
                                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                                          fontSize: 16,
                                          color: isRead ? Colors.grey[700] : AppTheme.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['summary'],
                                        style: TextStyle(
                                          height: 1.4,
                                          color: isRead ? Colors.grey[600] : Colors.black87,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (hasLink)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Read full story',
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 14,
                                                color: Colors.blue[700],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}