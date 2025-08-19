// lib/pages/admin/admin_lessons_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class AdminLessonsPage extends StatefulWidget {
  @override
  _AdminLessonsPageState createState() => _AdminLessonsPageState();
}

class _AdminLessonsPageState extends State<AdminLessonsPage> {
  final _searchController = TextEditingController();
  String _categoryFilter = 'all';
  String _statusFilter = 'all';
  bool _isViewDialogOpen = false;
  bool _isEditDialogOpen = false;
  Lesson? _selectedLesson;

  final _formData = {
    'title': '',
    'description': '',
    'category': '',
    'mediaType': 'text',
    'language': 'English',
  };

  // Mock data matching React implementation
  final List<Lesson> _lessons = [
    Lesson(
      id: '1',
      title: 'Understanding Prayer Times',
      description:
          'Learn about the five daily prayers and their significance in Islam. This comprehensive lesson covers the timing, preparation, and spiritual aspects of each prayer.',
      category: 'Prayer',
      rating: 4.8,
      ratingCount: 245,
      createdAt: '2024-01-15T10:00:00Z',
      updatedAt: '2024-06-01T14:30:00Z',
      author: 'Imam Abdullah',
      duration: '25 min',
      enrollments: 1250,
      mediaType: 'video',
      mediaUrl: '/videos/prayer-times.mp4',
      status: 'published',
      language: 'English',
    ),
    Lesson(
      id: '2',
      title: 'The Art of Wudu',
      description:
          'Step-by-step guide to performing ablution correctly according to Islamic teachings.',
      category: 'Purification',
      rating: 4.7,
      ratingCount: 189,
      createdAt: '2024-02-10T09:00:00Z',
      updatedAt: '2024-05-15T11:20:00Z',
      author: 'Sheikh Ahmad',
      duration: '15 min',
      enrollments: 890,
      mediaType: 'video',
      mediaUrl: '/videos/wudu-guide.mp4',
      status: 'published',
      language: 'English',
    ),
    Lesson(
      id: '3',
      title: 'Ramadan Preparation',
      description:
          'Prepare spiritually and physically for the holy month of Ramadan.',
      category: 'Fasting',
      rating: 4.6,
      ratingCount: 156,
      createdAt: '2024-03-01T08:00:00Z',
      updatedAt: '2024-03-20T16:45:00Z',
      author: 'Dr. Fatima',
      duration: '30 min',
      enrollments: 567,
      mediaType: 'audio',
      mediaUrl: '/audio/ramadan-prep.mp3',
      status: 'published',
      language: 'English',
    ),
    Lesson(
      id: '4',
      title: 'Islamic Ethics in Business',
      description:
          'Understanding halal business practices and ethical considerations in commerce.',
      category: 'Business Ethics',
      rating: 4.5,
      ratingCount: 98,
      createdAt: '2024-04-05T12:00:00Z',
      updatedAt: '2024-06-10T09:15:00Z',
      author: 'Professor Omar',
      duration: '45 min',
      enrollments: 234,
      mediaType: 'text',
      status: 'draft',
      language: 'English',
    ),
  ];

  List<Lesson> get _filteredLessons {
    return _lessons.where((lesson) {
      final matchesSearch =
          lesson.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          lesson.author.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesCategory =
          _categoryFilter == 'all' || lesson.category == _categoryFilter;
      final matchesStatus =
          _statusFilter == 'all' || lesson.status == _statusFilter;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Widget _getStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'published':
        backgroundColor = AppColors.islamicGreen100;
        textColor = AppColors.islamicGreen800;
        break;
      case 'draft':
        backgroundColor = AppColors.islamicGold100;
        textColor = AppColors.islamicGold800;
        break;
      case 'archived':
        backgroundColor = AppColors.grey100;
        textColor = AppColors.grey800;
        break;
      default:
        backgroundColor = AppColors.grey100;
        textColor = AppColors.grey800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.substring(0, 1).toUpperCase() + status.substring(1),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getMediaIcon(String mediaType) {
    switch (mediaType) {
      case 'video':
        return Icons.play_arrow;
      case 'audio':
        return Icons.audiotrack;
      case 'image':
        return Icons.image;
      case 'text':
      default:
        return Icons.book;
    }
  }

  List<Widget> _getRatingStars(double rating) {
    return List.generate(5, (index) {
      return Icon(
        Icons.star,
        size: 16,
        color:
            index < rating.floor()
                ? AppColors.islamicGold400
                : AppColors.grey300,
      );
    });
  }

  void _handleViewLesson(Lesson lesson) {
    setState(() {
      _selectedLesson = lesson;
      _isViewDialogOpen = true;
    });
  }

  void _handleEditLesson(Lesson lesson) {
    setState(() {
      _selectedLesson = lesson;
      _formData['title'] = lesson.title;
      _formData['description'] = lesson.description;
      _formData['category'] = lesson.category;
      _formData['mediaType'] = lesson.mediaType;
      _formData['language'] = lesson.language;
      _isEditDialogOpen = true;
    });
  }

  void _handleDeleteLesson(Lesson lesson) {
    print('Deleting lesson: ${lesson.id}');
  }

  void _navigateToAddLesson() {
    Navigator.pushNamed(context, '/admin/lessons/add');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _filteredLessons;
    final totalEnrollments = _lessons.fold(
      0,
      (sum, lesson) => sum + lesson.enrollments,
    );
    final averageRating =
        _lessons.fold(0.0, (sum, lesson) => sum + lesson.rating) /
        _lessons.length;
    final publishedCount =
        _lessons.where((lesson) => lesson.status == 'published').length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lessons Management',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lessonsTitle,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create, edit, and manage educational content',
                      style: TextStyle(
                        color: AppColors.lessonsSubtitle,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToAddLesson,
                icon: Icon(Icons.add, size: 16),
                label: Text('Add Lesson'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lessonsHumanBadge,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Stats Cards
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.book,
                iconColor: AppColors.lessonsHumanBadge,
                title: 'Total Lessons',
                value: _lessons.length.toString(),
              ),
              _buildStatCard(
                icon: Icons.people,
                iconColor: AppColors.infoBlue,
                title: 'Total Enrollments',
                value: totalEnrollments.toString(),
              ),
              _buildStatCard(
                icon: Icons.star,
                iconColor: AppColors.islamicGold400,
                title: 'Average Rating',
                value: averageRating.toStringAsFixed(1),
              ),
              _buildStatCard(
                icon: Icons.schedule,
                iconColor: AppColors.adminPanelGreen400,
                title: 'Published',
                value: publishedCount.toString(),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Filters Card
          Card(
            color: AppColors.islamicWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.lessonsBorder),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Lessons',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lessonsTitle,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      // Search
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search lessons or authors...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.grey500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.grey300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.grey300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.lessonsHumanBadge,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Category Filter
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: _categoryFilter,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Categories'),
                            ),
                            DropdownMenuItem(
                              value: 'Prayer',
                              child: Text('Prayer'),
                            ),
                            DropdownMenuItem(
                              value: 'Purification',
                              child: Text('Purification'),
                            ),
                            DropdownMenuItem(
                              value: 'Fasting',
                              child: Text('Fasting'),
                            ),
                            DropdownMenuItem(
                              value: 'Business Ethics',
                              child: Text('Business Ethics'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _categoryFilter = value ?? 'all';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      // Status Filter
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: _statusFilter,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'published',
                              child: Text('Published'),
                            ),
                            DropdownMenuItem(
                              value: 'draft',
                              child: Text('Draft'),
                            ),
                            DropdownMenuItem(
                              value: 'archived',
                              child: Text('Archived'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _statusFilter = value ?? 'all';
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

          SizedBox(height: 24),

          // Lessons Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: filteredLessons.length,
            itemBuilder: (context, index) {
              final lesson = filteredLessons[index];
              return Card(
                color: AppColors.islamicWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.lessonsBorder),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getMediaIcon(lesson.mediaType),
                                size: 16,
                                color: AppColors.grey500,
                              ),
                              SizedBox(width: 8),
                              _getStatusBadge(lesson.status),
                              Spacer(),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_horiz, size: 16),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'view':
                                      _handleViewLesson(lesson);
                                      break;
                                    case 'edit':
                                      _handleEditLesson(lesson);
                                      break;
                                    case 'delete':
                                      _handleDeleteLesson(lesson);
                                      break;
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility, size: 16),
                                            SizedBox(width: 8),
                                            Text('View Details'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16),
                                            SizedBox(width: 8),
                                            Text('Edit Lesson'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuDivider(),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 16,
                                              color: AppColors.errorRed,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete Lesson',
                                              style: TextStyle(
                                                color: AppColors.errorRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lessonsTitle,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            lesson.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.lessonsSubtitle,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'By ${lesson.author}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.lessonsSubtitle,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.grey300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    lesson.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.lessonsSubtitle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            // Rating
                            Row(
                              children: [
                                ..._getRatingStars(lesson.rating),
                                SizedBox(width: 8),
                                Text(
                                  lesson.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '(${lesson.ratingCount})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.lessonsSubtitle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            // Duration and Enrollments
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lesson.duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.lessonsSubtitle,
                                  ),
                                ),
                                Text(
                                  '${lesson.enrollments} enrolled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.lessonsSubtitle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _handleViewLesson(lesson),
                                    icon: Icon(Icons.visibility, size: 16),
                                    label: Text('View'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.lessonsTitle,
                                      side: BorderSide(
                                        color: AppColors.lessonsBorder,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _handleEditLesson(lesson),
                                    icon: Icon(Icons.edit, size: 16),
                                    label: Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.lessonsHumanBadge,
                                      foregroundColor: AppColors.islamicWhite,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),

          // View Dialog
          if (_isViewDialogOpen && _selectedLesson != null) _buildViewDialog(),

          // Edit Dialog
          if (_isEditDialogOpen && _selectedLesson != null) _buildEditDialog(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Card(
      color: AppColors.islamicWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.lessonsBorder),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32, color: iconColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.lessonsSubtitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lessonsTitle,
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

  Widget _buildViewDialog() {
    return Dialog(
      child: Container(
        width: 800,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.lessonsTitle,
              ),
            ),
            SizedBox(height: 24),
            // Dialog content here
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isViewDialogOpen = false;
                    });
                  },
                  child: Text('Close'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isViewDialogOpen = false;
                    });
                    _handleEditLesson(_selectedLesson!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lessonsHumanBadge,
                  ),
                  child: Text(
                    'Edit Lesson',
                    style: TextStyle(color: AppColors.islamicWhite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditDialog() {
    return Dialog(
      child: Container(
        width: 600,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Lesson',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.lessonsTitle,
              ),
            ),
            SizedBox(height: 24),
            // Form fields here
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditDialogOpen = false;
                    });
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditDialogOpen = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lessonsHumanBadge,
                  ),
                  child: Text(
                    'Update Lesson',
                    style: TextStyle(color: AppColors.islamicWhite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final double rating;
  final int ratingCount;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String duration;
  final int enrollments;
  final String mediaType;
  final String? mediaUrl;
  final String status;
  final String language;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.duration,
    required this.enrollments,
    required this.mediaType,
    this.mediaUrl,
    required this.status,
    required this.language,
  });
}
