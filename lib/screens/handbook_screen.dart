import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../services/handbook_service.dart';

class HandbookScreen extends StatefulWidget {
  const HandbookScreen({super.key});

  @override
  State<HandbookScreen> createState() => _HandbookScreenState();
}

class _HandbookScreenState extends State<HandbookScreen> {
  final HandbookService _handbookService = HandbookService();
  List<Map<String, dynamic>> _allPages = [];
  List<Map<String, dynamic>> _filteredPages = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Admissions',
    'Fees',
    'Academic',
    'Rules',
    'Campus Life',
    'Contacts',
    'Facilities',
    'About NAUB',
  ];

  @override
  void initState() {
    super.initState();
    _loadHandbook();
  }

  Future<void> _loadHandbook() async {
    setState(() => _isLoading = true);
    final data = await _handbookService.searchHandbook('');
    setState(() {
      _allPages = data;
      _filteredPages = data;
      _isLoading = false;
    });
  }

  void _filterHandbook(String query) {
    setState(() {
      _filteredPages = _allPages.where((page) {
        final title = page['title'].toString().toLowerCase();
        final content = page['content'].toString().toLowerCase();
        final category = page['category'].toString().toLowerCase();

        final matchesSearch = query.isEmpty ||
            title.contains(query.toLowerCase()) ||
            content.contains(query.toLowerCase());

        final matchesCategory = _selectedCategory == 'All' ||
            category == _selectedCategory.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterHandbook(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Student Handbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHandbook,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterHandbook,
              decoration: InputDecoration(
                hintText: 'Search handbook...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterHandbook('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (_) => _filterByCategory(cat),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No results found', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHandbook,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPages.length,
                          itemBuilder: (context, index) {
                            final page = _filteredPages[index];
                            return Card(
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    page['category'].toString().substring(0, 1),
                                    style: TextStyle(color: AppTheme.primaryColor),
                                  ),
                                ),
                                title: Text(
                                  page['title'],
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  page['category'],
                                  style: TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      page['content'],
                                      style: const TextStyle(fontSize: 15, height: 1.5),
                                    ),
                                  ),
                                ],
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