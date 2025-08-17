// lib/pages/lessons_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'LessonsPlayer.dart';

class LessonsPage extends StatefulWidget {
  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedLevel = 'all';
  bool _isLessonPlayerOpen = false;
  LessonData? _selectedLessonData;

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

  // Sample lesson data structure - this would come from your server
  final Map<String, LessonData> _sampleLessonData = {
    'Understanding Salah (Prayer)': LessonData(
      lessonTitle: 'Understanding Salah (Prayer)',
      steps: [
        LessonStep(
          title: 'Step 1: Facing the Qibla',
          description:
              'Stand upright facing the direction of the Kaaba (Qibla). This is the first requirement for prayer and ensures we are oriented towards the sacred direction.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Step+1:+Facing+the+Qibla',
        ),
        LessonStep(
          title: 'Step 2: Making the Niyyah',
          description:
              'Internally intend which prayer you are going to perform. No need to say it aloud. This intention is made in your heart and is essential for the validity of the prayer.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Step+2:+Making+the+Niyyah',
        ),
        LessonStep(
          title: 'Step 3: Raising Hands (Takbeer)',
          description:
              'Raise your hands to shoulder level and say \'Allahu Akbar\' to begin the prayer. This marks the official start of your connection with Allah.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Step+3:+Raising+Hands+(Takbeer)',
        ),
        LessonStep(
          title: 'Step 4: Reciting Al-Fatiha',
          description:
              'Recite the opening chapter of the Quran, Al-Fatiha, which is required in every unit of prayer.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Step+4:+Reciting+Al-Fatiha',
        ),
      ],
    ),
    'The Five Pillars of Islam': LessonData(
      lessonTitle: 'The Five Pillars of Islam',
      steps: [
        LessonStep(
          title: 'The Importance of the Five Pillars',
          description:
              'Learn why the Five Pillars are the foundation of Islamic faith and practice, and how they guide a Muslim\'s spiritual journey.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=The+Importance+of+the+Five+Pillars',
        ),
        LessonStep(
          title: 'Shahada - Declaration of Faith',
          description:
              'Understanding the first pillar: bearing witness that there is no god but Allah and Muhammad is His messenger.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Shahada+-+Declaration+of+Faith',
        ),
        LessonStep(
          title: 'Salah - Prayer',
          description:
              'The second pillar: performing the five daily prayers as a means of connection with Allah.',
          mediaType: 'image',
          mediaUrl:
              'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Salah+-+Prayer',
        ),
      ],
    ),
  };

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
        return AppColors.lessonsBorder;
      case 'intermediate':
        return AppColors.lessonsPrivateBorder;
      case 'advanced':
        return AppColors.lessonsErrorBorder;
      default:
        return AppColors.lessonsGreyBorder;
    }
  }

  Color _getLevelTextColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.lessonsUrgent;
      case 'intermediate':
        return AppColors.lessonsPrivacyText;
      case 'advanced':
        return AppColors.lessonsError;
      default:
        return AppColors.lessonsGrey;
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

  void _handleStartLesson(String lessonTitle) {
    final lessonData = _sampleLessonData[lessonTitle];
    if (lessonData != null) {
      setState(() {
        _selectedLessonData = lessonData;
        _isLessonPlayerOpen = true;
      });
    } else {
      // Fallback lesson data
      setState(() {
        _selectedLessonData = LessonData(
          lessonTitle: lessonTitle,
          steps: [
            LessonStep(
              title: 'Introduction',
              description:
                  'Welcome to this Islamic lesson. This is a demo of the interactive lesson player.',
              mediaType: 'image',
              mediaUrl:
                  'https://via.placeholder.com/800x450/2E7D32/FFFFFF?text=Introduction',
            ),
          ],
        );
        _isLessonPlayerOpen = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _filteredLessons;

    return Stack(
      children: [
        SingleChildScrollView(
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
                        color: AppColors.lessonsTitle,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Learn and grow in your Islamic knowledge',
                      style: TextStyle(color: AppColors.lessonsSubtitle),
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
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.lessonsSearchIcon,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.lessonsCategoryBackground,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.lessonsCategoryBackground,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.lessonsHumanBadge,
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
                                  color: AppColors.lessonsSearchIcon,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.lessonsCategoryBackground,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.lessonsCategoryBackground,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.lessonsHumanBadge,
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
                                  color: AppColors.lessonsSearchIcon,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.lessonsCategoryBackground,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.lessonsCategoryBackground,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.lessonsHumanBadge,
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
                    style: TextStyle(color: AppColors.lessonsSubtitle),
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
                                            AppColors.lessonsHumanBadge,
                                            AppColors.lessonsSubtitle,
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
                                                    color:
                                                        AppColors.lessonsTitle,
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
                                                          ? AppColors
                                                              .askPagePrivateIcon
                                                          : AppColors
                                                              .lessonsSearchIcon,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Text(
                                            lesson['description'],
                                            style: TextStyle(
                                              color: AppColors.lessonsSubtitle,
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
                                                  color:
                                                      AppColors.lessonsBorder,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  lesson['category'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.lessonsUrgent,
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
                                                    color:
                                                        AppColors
                                                            .lessonsSubtitle,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    lesson['duration'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors
                                                              .lessonsSubtitle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              /*  Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color:
                                                    AppColors
                                                        .askPagePrivateIcon,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                lesson['rating'].toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.lessonsSubtitle,
                                                ),
                                              ),
                                            ],
                                          ), */
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.people,
                                                    size: 16,
                                                    color:
                                                        AppColors
                                                            .lessonsSubtitle,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    lesson['students']
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors
                                                              .lessonsSubtitle,
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
                                              color: AppColors.lessonsSubtitle,
                                            ),
                                          ),
                                          SizedBox(height: 16),

                                          ElevatedButton(
                                            onPressed:
                                                () => _handleStartLesson(
                                                  lesson['title'],
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.lessonsHumanBadge,
                                              foregroundColor:
                                                  AppColors.islamicWhite,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.play_arrow,
                                                  size: 16,
                                                ),
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
                    side: BorderSide(
                      color: AppColors.lessonsCategoryBackground,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: AppColors.lessonsPrivacyBorder,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No lessons found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lessonsTitle,
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
                            foregroundColor: AppColors.lessonsUrgent,
                            side: BorderSide(
                              color: AppColors.lessonsPrivacyBorder,
                            ),
                          ),
                          child: Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Lesson Player Modal
        if (_selectedLessonData != null)
          LessonPlayer(
            isOpen: _isLessonPlayerOpen,
            onClose: () {
              setState(() {
                _isLessonPlayerOpen = false;
                _selectedLessonData = null;
              });
            },
            lessonData: _selectedLessonData!,
          ),
      ],
    );
  }
  
}
