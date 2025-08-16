// lib/pages/lessons_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

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

class LessonStep {
  final String title;
  final String description;
  final String mediaType;
  final String mediaUrl;

  LessonStep({
    required this.title,
    required this.description,
    required this.mediaType,
    required this.mediaUrl,
  });
}

class LessonData {
  final String lessonTitle;
  final List<LessonStep> steps;

  LessonData({required this.lessonTitle, required this.steps});
}

class LessonPlayer extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final LessonData lessonData;

  const LessonPlayer({
    Key? key,
    required this.isOpen,
    required this.onClose,
    required this.lessonData,
  }) : super(key: key);

  @override
  _LessonPlayerState createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  int currentStep = 0;
  bool isCompleted = false;

  double get progress =>
      ((currentStep + 1) / widget.lessonData.steps.length) * 100;
  bool get isLastStep => currentStep == widget.lessonData.steps.length - 1;
  bool get isFirstStep => currentStep == 0;

  @override
  void initState() {
    super.initState();
    if (widget.isOpen) {
      _resetState();
    }
  }

  @override
  void didUpdateWidget(LessonPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _resetState();
    }
  }

  void _resetState() {
    setState(() {
      currentStep = 0;
      isCompleted = false;
    });
  }

  void _handleNext() {
    setState(() {
      if (isLastStep) {
        isCompleted = true;
      } else {
        currentStep++;
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  void _handleRestart() {
    setState(() {
      currentStep = 0;
      isCompleted = false;
    });
  }

  void _handleStepClick(int stepIndex) {
    setState(() {
      currentStep = stepIndex;
      isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return SizedBox.shrink();

    final currentStepData =
        widget.lessonData.steps.isNotEmpty
            ? widget.lessonData.steps[currentStep]
            : null;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.islamicWhite, AppColors.islamicCream],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.lessonsBorder.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lessonData.lessonTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lessonsTitle,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Step ${isCompleted ? widget.lessonData.steps.length : currentStep + 1} of ${widget.lessonData.steps.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lessonsSubtitle,
                                    ),
                                  ),
                                  Text(
                                    '${progress.round()}% Complete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lessonsSubtitle,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: AppColors.lessonsBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.lessonsHumanBadge,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: Icon(
                            Icons.close,
                            color: AppColors.lessonsSubtitle,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Row(
                  children: [
                    // Media Section
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColors.lessonsTitle,
                        child: Stack(
                          children: [
                            if (!isCompleted && currentStepData != null)
                              Center(
                                child: Container(
                                  margin: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      currentStepData.mediaUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Container(
                                            height: 300,
                                            color: AppColors.lessonsBorder,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    size: 48,
                                                    color:
                                                        AppColors
                                                            .lessonsSubtitle,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Image not available',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors
                                                              .lessonsSubtitle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                            // Navigation Overlay
                            if (!isCompleted)
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: FloatingActionButton(
                                        onPressed:
                                            isFirstStep
                                                ? null
                                                : _handlePrevious,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.2),
                                        child: Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: FloatingActionButton(
                                        onPressed: _handleNext,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.2),
                                        child: Icon(
                                          isLastStep
                                              ? Icons.check_circle
                                              : Icons.chevron_right,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Completion Screen
                            if (isCompleted)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 96,
                                      color: AppColors.askPagePrivateIcon,
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      'Excellent Work!',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'You\'ve completed this lesson. Well done!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          Icons.star,
                                          color: AppColors.askPagePrivateIcon,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: _handleRestart,
                                          icon: Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Restart Lesson',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: widget.onClose,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.askPagePrivateIcon,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            'Continue Learning',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Content Panel
                    Container(
                      width: 384,
                      decoration: BoxDecoration(
                        color: AppColors.islamicWhite,
                        border: Border(
                          left: BorderSide(
                            color: AppColors.lessonsBorder.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (!isCompleted && currentStepData != null) ...[
                            // Step Content
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentStepData.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.lessonsTitle,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      currentStepData.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.lessonsSubtitle,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Text(
                                      'Lesson Steps',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.lessonsTitle,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount:
                                            widget.lessonData.steps.length,
                                        itemBuilder: (context, index) {
                                          final step =
                                              widget.lessonData.steps[index];
                                          final isCurrentStep =
                                              index == currentStep;
                                          final isCompletedStep =
                                              index < currentStep;

                                          return Container(
                                            margin: EdgeInsets.only(bottom: 8),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap:
                                                    () =>
                                                        _handleStepClick(index),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isCurrentStep
                                                            ? AppColors
                                                                .lessonsBorder
                                                            : isCompletedStep
                                                            ? AppColors
                                                                .lessonsBorder
                                                                .withOpacity(
                                                                  0.3,
                                                                )
                                                            : AppColors
                                                                .lessonsCategoryBackground
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          isCurrentStep
                                                              ? AppColors
                                                                  .lessonsHumanBadge
                                                              : isCompletedStep
                                                              ? AppColors
                                                                  .lessonsBorder
                                                              : AppColors
                                                                  .lessonsCategoryBackground,
                                                      width:
                                                          isCurrentStep ? 2 : 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              isCompletedStep
                                                                  ? AppColors
                                                                      .lessonsHumanBadge
                                                                  : isCurrentStep
                                                                  ? AppColors
                                                                      .lessonsBorder
                                                                  : AppColors
                                                                      .lessonsCategoryBackground,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child:
                                                              isCompletedStep
                                                                  ? Icon(
                                                                    Icons.check,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    size: 16,
                                                                  )
                                                                  : Text(
                                                                    '${index + 1}',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          isCurrentStep
                                                                              ? AppColors.lessonsTitle
                                                                              : AppColors.lessonsSubtitle,
                                                                    ),
                                                                  ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          step.title,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                isCurrentStep
                                                                    ? AppColors
                                                                        .lessonsTitle
                                                                    : AppColors
                                                                        .lessonsSubtitle,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Navigation
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.lessonsBorder.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          isFirstStep ? null : _handlePrevious,
                                      icon: Icon(Icons.chevron_left),
                                      label: Text('Previous'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.lessonsTitle,
                                        side: BorderSide(
                                          color: AppColors.lessonsBorder,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleNext,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.lessonsHumanBadge,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isLastStep ? 'Complete' : 'Next',
                                          ),
                                          if (!isLastStep) ...[
                                            SizedBox(width: 4),
                                            Icon(Icons.chevron_right, size: 16),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isCompleted) ...[
                            // Completion Side Panel
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    'Lesson Summary',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lessonsTitle,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: widget.lessonData.steps.length,
                                      itemBuilder: (context, index) {
                                        final step =
                                            widget.lessonData.steps[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.lessonsBorder
                                                .withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color:
                                                    AppColors.lessonsHumanBadge,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  step.title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.lessonsTitle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
