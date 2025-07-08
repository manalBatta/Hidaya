// lib/pages/lessons_page.dart
import 'package:flutter/material.dart';

class LessonsPage extends StatefulWidget {
  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedLevel = 'all';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'All Categories'},
    {'id': 'fundamentals', 'name': 'Islamic Fundamentals'},
    {'id': 'worship', 'name': 'Worship & Prayer'},
    {'id': 'quran', 'name': 'Quran Studies'},
    {'id': 'hadith', 'name': 'Hadith & Sunnah'},
    {'id': 'history', 'name': 'Islamic History'},
    {'id': 'ethics', 'name': 'Islamic Ethics'},
    {'id': 'family', 'name': 'Family & Marriage'},
    {'id': 'finance', 'name': 'Islamic Finance'},
  ];

  final List<Map<String, String>> _levels = [
    {'id': 'all', 'name': 'All Levels'},
    {'id': 'beginner', 'name': 'Beginner'},
    {'id': 'intermediate', 'name': 'Intermediate'},
    {'id': 'advanced', 'name': 'Advanced'},
  ];

  final List<Map<String, dynamic>> _lessons = [
    {
      'id': 1,
      'title': 'The Five Pillars of Islam',
      'description':
          'A comprehensive guide to the fundamental pillars of Islamic faith and practice.',
      'category': 'Islamic Fundamentals',
      'level': 'Beginner',
      'duration': '25 min',
      'rating': 4.9,
      'students': 1247,
      'instructor': 'Sheikh Ahmad Ali',
      'isBookmarked': false,
      'image': '🕌',
    },
    {
      'id': 2,
      'title': 'Understanding Salah (Prayer)',
      'description':
          'Learn the proper way to perform the five daily prayers with detailed explanations.',
      'category': 'Worship & Prayer',
      'level': 'Beginner',
      'duration': '18 min',
      'rating': 4.8,
      'students': 892,
      'instructor': 'Sister Aisha Rahman',
      'isBookmarked': true,
      'image': '🤲',
    },
    {
      'id': 3,
      'title': 'Quranic Arabic Basics',
      'description':
          'Start your journey in understanding the Quran in its original language.',
      'category': 'Quran Studies',
      'level': 'Intermediate',
      'duration': '32 min',
      'rating': 4.7,
      'students': 654,
      'instructor': 'Dr. Mohamed Hassan',
      'isBookmarked': false,
      'image': '📖',
    },
    {
      'id': 4,
      'title': 'Islamic Ethics in Business',
      'description':
          'Apply Islamic principles in modern business and financial dealings.',
      'category': 'Islamic Ethics',
      'level': 'Advanced',
      'duration': '28 min',
      'rating': 4.6,
      'students': 423,
      'instructor': 'Prof. Omar Malik',
      'isBookmarked': true,
      'image': '💼',
    },
    {
      'id': 5,
      'title': 'History of the Prophet (PBUH)',
      'description':
          'Explore the life and teachings of Prophet Muhammad (Peace Be Upon Him).',
      'category': 'Islamic History',
      'level': 'Intermediate',
      'duration': '45 min',
      'rating': 4.9,
      'students': 1456,
      'instructor': 'Dr. Fatima Al-Zahra',
      'isBookmarked': false,
      'image': '🌟',
    },
    {
      'id': 6,
      'title': 'Islamic Marriage and Family',
      'description':
          'Understanding the Islamic perspective on marriage, family, and relationships.',
      'category': 'Family & Marriage',
      'level': 'Beginner',
      'duration': '22 min',
      'rating': 4.8,
      'students': 789,
      'instructor': 'Sister Khadija Ibrahim',
      'isBookmarked': false,
      'image': '👨‍👩‍👧‍👦',
    },
  ];

  List<Map<String, dynamic>> get _filteredLessons {
    return _lessons.where((lesson) {
      final matchesSearch =
          lesson['title'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          lesson['description'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'all' ||
          lesson['category'].toLowerCase().contains(_selectedCategory);
      final matchesLevel =
          _selectedLevel == 'all' ||
          lesson['level'].toLowerCase() == _selectedLevel;

      return matchesSearch && matchesCategory && matchesLevel;
    }).toList();
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Color(0xFFE6F3ED);
      case 'intermediate':
        return Color(0xFFF8EDCF);
      case 'advanced':
        return Color(0xFFFFE6E6);
      default:
        return Color(0xFFE5E7EB);
    }
  }

  Color _getLevelTextColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Color(0xFF165A3F);
      case 'intermediate':
        return Color(0xFF7F7556);
      case 'advanced':
        return Color(0xFFDC2626);
      default:
        return Color(0xFF6B7280);
    }
  }

  void _toggleBookmark(int lessonId) {
    setState(() {
      final index = _lessons.indexWhere((lesson) => lesson['id'] == lessonId);
      if (index != -1) {
        _lessons[index]['isBookmarked'] = !_lessons[index]['isBookmarked'];
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'all';
      _selectedLevel = 'all';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _filteredLessons;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 60), // Account for admin button
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  'Islamic Lessons',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF104C34),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Learn and grow in your Islamic knowledge',
                  style: TextStyle(color: Color(0xFF206F4F)),
                ),
              ],
            ),
          ),

          // Search and Filters
          Card(
            color: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFBFE3D5)),
            ),
            elevation: 8,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search lessons...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF45A376)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFBFE3D5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFBFE3D5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF2D8662),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 16),

                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.filter_alt,
                              color: Color(0xFF45A376),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFF2D8662),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category['id'],
                                  child: Text(
                                    category['name']!,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value ?? 'all';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _selectedLevel,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.military_tech,
                              color: Color(0xFF45A376),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFF2D8662),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _levels.map((level) {
                                return DropdownMenuItem(
                                  value: level['id'],
                                  child: Text(
                                    level['name']!,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value ?? 'all';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Results Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredLessons.length} lesson${filteredLessons.length != 1 ? 's' : ''} found',
                style: TextStyle(color: Color(0xFF206F4F)),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Lessons List
          if (filteredLessons.isNotEmpty)
            ...filteredLessons
                .map(
                  (lesson) => Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0xFFBFE3D5)),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Lesson Icon
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2D8662),
                                        Color(0xFF206F4F),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      lesson['image'],
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Lesson Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lesson['title'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF104C34),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed:
                                                () => _toggleBookmark(
                                                  lesson['id'],
                                                ),
                                            icon: Icon(
                                              lesson['isBookmarked']
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border,
                                              color:
                                                  lesson['isBookmarked']
                                                      ? Color(0xFFD4A574)
                                                      : Color(0xFF45A376),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Text(
                                        lesson['description'],
                                        style: TextStyle(
                                          color: Color(0xFF206F4F),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 12),

                                      // Badges
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE6F3ED),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              lesson['category'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF165A3F),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getLevelColor(
                                                lesson['level'],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              lesson['level'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getLevelTextColor(
                                                  lesson['level'],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      // Stats
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 4,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Color(0xFF206F4F),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                lesson['duration'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF206F4F),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Color(0xFFD4A574),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                lesson['rating'].toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF206F4F),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 16,
                                                color: Color(0xFF206F4F),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                lesson['students'].toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF206F4F),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),

                                      Text(
                                        'By ${lesson['instructor']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF206F4F),
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      ElevatedButton(
                                        onPressed: () {
                                          // Handle start lesson
                                          print(
                                            'Starting lesson: ${lesson['title']}',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF2D8662),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.play_arrow, size: 16),
                                            SizedBox(width: 4),
                                            Text('Start Lesson'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList()
          else
            // Empty State
            Card(
              color: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(0xFFBFE3D5)),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Color(0xFF93C5AE),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No lessons found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF104C34),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filter criteria',
                      style: TextStyle(color: Color(0xFF206F4F)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF165A3F),
                        side: BorderSide(color: Color(0xFF93C5AE)),
                      ),
                      child: Text('Clear Filters'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
