import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/constants/colors.dart';

// Story Data Models
enum ContentType { video, image, text }

enum Language { english, arabic, french, spanish, urdu }

enum Gender { male, female, preferNotToSay }

class Story {
  final String id;
  final String title;
  final StoryContent content;
  final Author author;
  final StoryMetadata metadata;
  final Quote? quote;
  final FullStory fullStory;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.metadata,
    this.quote,
    required this.fullStory,
  });
}

class StoryContent {
  final ContentType type;
  final String? url;
  final String? text;
  final String? thumbnail;

  StoryContent({required this.type, this.url, this.text, this.thumbnail});
}

class Author {
  final String name;
  final String location;
  final String country;
  final Gender gender;
  final String? profileImage;

  Author({
    required this.name,
    required this.location,
    required this.country,
    required this.gender,
    this.profileImage,
  });
}

class StoryMetadata {
  final int likes;
  final int saves;
  final int? duration;
  final List<String> tags;
  final Language language;
  final DateTime dateShared;

  StoryMetadata({
    required this.likes,
    required this.saves,
    this.duration,
    required this.tags,
    required this.language,
    required this.dateShared,
  });
}

class Quote {
  final String text;
  final QuotePosition position;

  Quote({required this.text, required this.position});
}

enum QuotePosition { top, center, bottom }

class FullStory {
  final String? background;
  final String testimonial;
  final String? beforeIslam;
  final String? journey;
  final String? afterIslam;

  FullStory({
    this.background,
    required this.testimonial,
    this.beforeIslam,
    this.journey,
    this.afterIslam,
  });
}

// Islamic Theme Colors
class IslamicTheme {
  static const Color primary = Color(0xFF16A085);
  static const Color primaryLight = Color(0xFF48C9B0);
  static const Color primaryDark = Color(0xFF138D75);
  static const Color accent = Color(0xFF27AE60);
  static const Color background = Color(0xFFF5FFFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF161D1B);
  static const Color textSecondary = Color(0xFF5A7269);
  static const Color border = Color(0xFFD1E0DA);

  static const List<Color> gradientColors = [
    Color(0xFF16A085),
    Color(0xFF27AE60),
  ];
}

// Mock Data
List<Story> mockStories = [
  Story(
    id: '1',
    title: 'Finding Peace in Prayer',
    content: StoryContent(
      type: ContentType.video,
      url: 'assets/StoryImages/story2vid.mp4',
      thumbnail: 'assets/StoryImages/story1.jpg',
    ),
    author: Author(
      name: 'Sarah Johnson',
      location: 'London, UK',
      country: 'United Kingdom',
      gender: Gender.female,
      profileImage: 'assets/StoryImages/profile.jpg',
    ),
    metadata: StoryMetadata(
      likes: 1247,
      saves: 834,
      duration: 45,
      tags: ['prayer', 'peace', 'spirituality', 'london'],
      language: Language.english,
      dateShared: DateTime(2024, 1, 15),
    ),
    quote: Quote(
      text: 'Islam gave me the peace I was searching for my entire life',
      position: QuotePosition.center,
    ),
    fullStory: FullStory(
      background:
          'Raised in a Christian family, always felt something was missing',
      testimonial:
          'After years of searching for spiritual fulfillment, I discovered Islam through a university friend.',
      beforeIslam:
          'I was struggling with anxiety and depression, feeling lost in modern society',
      journey:
          'Started reading the Quran, attending mosque, learning Arabic prayers',
      afterIslam:
          'Found inner peace, stronger sense of community, and clear life purpose',
    ),
  ),
  Story(
    id: '2',
    title: 'Journey to Understanding',
    content: StoryContent(
      type: ContentType.video,
      url: 'assets/StoryImages/story1vid.mp4',
      thumbnail: 'assets/StoryImages/story2.jpg',
    ),
    author: Author(
      name: 'Marcus Thompson',
      location: 'New York, USA',
      country: 'United States',
      gender: Gender.male,
      profileImage: 'assets/StoryImages/profile.jpg',
    ),
    metadata: StoryMetadata(
      likes: 892,
      saves: 445,
      tags: ['knowledge', 'quran', 'study', 'newyork'],
      language: Language.english,
      dateShared: DateTime(2024, 1, 10),
    ),
    quote: Quote(
      text: 'The Quran answered questions I didn\'t even know I had',
      position: QuotePosition.bottom,
    ),
    fullStory: FullStory(
      background:
          'College professor of philosophy, always questioned existence',
      testimonial:
          'Through academic study of world religions, I became fascinated by Islamic philosophy and theology.',
      beforeIslam: 'Agnostic, believed only in what science could prove',
      journey:
          'Started with academic interest, progressed to personal spiritual journey',
      afterIslam: 'Combined intellectual understanding with spiritual practice',
    ),
  ),
  Story(
    id: '3',
    title: 'From Darkness to Light',
    content: StoryContent(
      type: ContentType.video,
      url: 'assets/StoryImages/story1vid.mp4',
      thumbnail: 'assets/StoryImages/story3.jpg',
    ),
    author: Author(
      name: 'Ahmed (formerly David) Williams',
      location: 'Toronto, Canada',
      country: 'Canada',
      gender: Gender.male,
      profileImage: 'assets/StoryImages/profile.jpg',
    ),
    metadata: StoryMetadata(
      likes: 2156,
      saves: 1289,
      tags: ['recovery', 'addiction', 'community', 'strength'],
      language: Language.english,
      dateShared: DateTime(2024, 1, 8),
    ),
    quote: Quote(
      text: 'Islam saved my life when I had nowhere else to turn',
      position: QuotePosition.top,
    ),
    fullStory: FullStory(
      background:
          'Struggled with substance abuse, lost job and family relationships',
      testimonial:
          'When I hit rock bottom, a Muslim friend invited me to the mosque.',
      beforeIslam: 'Felt hopeless, isolated, controlled by addiction',
      journey:
          'Gradual healing through prayer, community support, Islamic counseling',
      afterIslam:
          'Rebuilt life, repaired relationships, now helping others in recovery',
    ),
  ),
];

// Main Stories Page
class StoriesPage extends StatefulWidget {
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  String _searchQuery = '';
  bool _showFilters = false;
  Set<String> _likedStories = {};
  Set<String> _savedStories = {};
  String? _expandedStory;
  List<Story> _filteredStories = mockStories;

  // Filter states
  Set<ContentType> _contentTypeFilters = {};
  Set<Language> _languageFilters = {};
  Set<Gender> _genderFilters = {};

  late AnimationController _heartAnimController;
  late AnimationController _bookmarkAnimController;
  late Animation<double> _heartScale;
  late Animation<double> _bookmarkScale;
  final FocusNode _focusNode = FocusNode();

  // --- Blur control ---
  Map<String, DateTime?> _lastCollapsedTime = {};
  Map<String, bool> _keepUnblurred = {};

  // Add a map to hold controllers for each story
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, Future<void>> _videoInitFutures = {};

  // Add state for mobile details toggle
  Map<String, bool> _showMobileDetails = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _heartAnimController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _bookmarkAnimController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimController, curve: Curves.elasticOut),
    );
    _bookmarkScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _bookmarkAnimController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartAnimController.dispose();
    _bookmarkAnimController.dispose();
    _focusNode.dispose();
    // Dispose all video controllers
    _videoControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _filterStories() {
    setState(() {
      _filteredStories =
          mockStories.where((story) {
            bool matchesSearch =
                _searchQuery.isEmpty ||
                story.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                story.author.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                story.author.location.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                story.fullStory.testimonial.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );

            bool matchesContentType =
                _contentTypeFilters.isEmpty ||
                _contentTypeFilters.contains(story.content.type);

            bool matchesLanguage =
                _languageFilters.isEmpty ||
                _languageFilters.contains(story.metadata.language);

            bool matchesGender =
                _genderFilters.isEmpty ||
                _genderFilters.contains(story.author.gender);

            return matchesSearch &&
                matchesContentType &&
                matchesLanguage &&
                matchesGender;
          }).toList();
    });
  }

  void _toggleLike(String storyId) {
    setState(() {
      if (_likedStories.contains(storyId)) {
        _likedStories.remove(storyId);
      } else {
        _likedStories.add(storyId);
        _heartAnimController.forward().then(
          (_) => _heartAnimController.reverse(),
        );
      }
    });
  }

  void _toggleSave(String storyId) {
    setState(() {
      if (_savedStories.contains(storyId)) {
        _savedStories.remove(storyId);
      } else {
        _savedStories.add(storyId);
        _bookmarkAnimController.forward().then(
          (_) => _bookmarkAnimController.reverse(),
        );
      }
    });
  }

  void _handleCardTap(String storyId, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        // Collapsing: dispose controller
        if (_videoControllers.containsKey(storyId)) {
          _videoControllers[storyId]!.dispose();
          _videoControllers.remove(storyId);
          _videoInitFutures.remove(storyId);
        }
        _expandedStory = null;
        // Start timer to keep image unblurred for 1.5 minutes
        _keepUnblurred[storyId] = true;
        _lastCollapsedTime[storyId] = DateTime.now();
        Future.delayed(Duration(seconds: 90), () {
          if (mounted && _expandedStory != storyId) {
            setState(() {
              _keepUnblurred[storyId] = false;
            });
          }
        });
      } else {
        // Expanding: dispose previous, create new
        if (_expandedStory != null &&
            _videoControllers.containsKey(_expandedStory)) {
          _videoControllers[_expandedStory]!.dispose();
          _videoControllers.remove(_expandedStory);
          _videoInitFutures.remove(_expandedStory);
        }
        _expandedStory = storyId;
        // Find the story object by ID
        final story = _filteredStories.firstWhere((s) => s.id == storyId);
        final controller = VideoPlayerController.asset(story.content.url!);
        _videoControllers[storyId] = controller;
        _videoInitFutures[storyId] = controller.initialize().then((_) {
          controller.setLooping(true);
          controller.play();
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (_currentIndex < _filteredStories.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (_currentIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // IslamicStoriesPage-style background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.islamicGreen300.withOpacity(0.08),
                    AppColors.islamicCream,
                    AppColors.islamicGold300.withOpacity(0.08),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Radial gradients for depth
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.25, 0.25),
                          radius: 0.4,
                          colors: [
                            AppColors.islamicGreen300.withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.75, 0.75),
                          radius: 0.4,
                          colors: [
                            AppColors.islamicGold300.withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Stack(
              children: [
                // Stories PageView
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _expandedStory =
                          null; // Close expanded story when changing pages
                    });
                  },
                  itemCount: _filteredStories.length,
                  itemBuilder: (context, index) {
                    return _buildStoryPage(_filteredStories[index]);
                  },
                ),
                // Search Header
                _buildSearchHeader(),
                // Filter Panel
                if (_showFilters) _buildFilterPanel(),
                // Page Indicators
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.islamicCream.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.islamicGreen300.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey900.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterStories();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search stories...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.islamicGreen700,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.islamicGreen700.withOpacity(0.7),
                    ),
                  ),
                  style: TextStyle(color: AppColors.islamicGreen900),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _showFilters
                          ? AppColors.islamicGreen300.withOpacity(0.2)
                          : AppColors.islamicCream.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.islamicGreen300.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey900.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.filter_list,
                  color: AppColors.islamicGreen700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Positioned(
      top: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IslamicTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IslamicTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Content Type', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  ContentType.values.map((type) {
                    bool isSelected = _contentTypeFilters.contains(type);
                    return FilterChip(
                      label: Text(type.toString().split('.').last),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _contentTypeFilters.add(type);
                          } else {
                            _contentTypeFilters.remove(type);
                          }
                        });
                        _filterStories();
                      },
                      selectedColor: IslamicTheme.primary,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : IslamicTheme.textPrimary,
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  Language.values.map((lang) {
                    bool isSelected = _languageFilters.contains(lang);
                    return FilterChip(
                      label: Text(lang.toString().split('.').last),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _languageFilters.add(lang);
                          } else {
                            _languageFilters.remove(lang);
                          }
                        });
                        _filterStories();
                      },
                      selectedColor: IslamicTheme.primary,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : IslamicTheme.textPrimary,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /*   Widget _buildPageIndicators() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_filteredStories.length, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: index == _currentIndex ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  index == _currentIndex
                      ? IslamicTheme.primary
                      : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  } */

  Widget _buildStoryPage(Story story) {
    final isExpanded = _expandedStory == story.id;
    final keepUnblurred = _keepUnblurred[story.id] == true;
    // Ensure details are shown by default when expanded on mobile
    if (isExpanded && (_showMobileDetails[story.id] == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showMobileDetails[story.id] = true;
          });
        }
      });
    }
    return GestureDetector(
      onTap: () {
        _handleCardTap(story.id, isExpanded);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.only(
          top: kToolbarHeight + 32, // or adjust as needed
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLargeScreen = constraints.maxWidth > 800;
                  if (isExpanded) {
                    if (isLargeScreen) {
                      // Large screen: horizontal layout with fixed-width side panel
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 700),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.98,
                                end: 1.0,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          key: ValueKey(isExpanded),
                          children: [
                            // Story content (image/video) with quote overlay
                            Expanded(
                              flex: 2,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: double.infinity,
                                    child: _buildStoryContent(
                                      story,
                                      isExpanded,
                                    ),
                                  ),
                                  if (story.quote != null)
                                    _buildQuoteOverlay(
                                      story.quote!,
                                      isExpanded: true,
                                    ),
                                ],
                              ),
                            ),
                            // Details panel (fixed width, not overlapping)
                            Container(
                              width: 400,
                              height: double.infinity,
                              color: Colors.black.withOpacity(0.7),
                              padding: const EdgeInsets.all(24),
                              child: SingleChildScrollView(
                                child: _buildExpandedDetailsPanel(
                                  story,
                                  useLightText: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Small screen: show video, then show/hide details as a bottom panel
                      return Stack(
                        children: [
                          // Video always fills the available space
                          Positioned.fill(
                            child: _buildStoryContent(story, isExpanded),
                          ),
                          // Show More button at the bottom if details are hidden
                          if (!(_showMobileDetails[story.id] ?? false))
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 16,
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showMobileDetails[story.id] = true;
                                    });
                                  },
                                  child: Text(
                                    'Show Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black.withOpacity(
                                      0.3,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Bottom panel for details if toggled
                          if (_showMobileDetails[story.id] ?? false)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: FractionallySizedBox(
                                widthFactor: 1.0,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                        0.4,
                                  ),
                                  color: Colors.black.withOpacity(0.7),
                                  child: Stack(
                                    children: [
                                      // Hide Details button at top right of panel
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _showMobileDetails[story.id] =
                                                  false;
                                            });
                                          },
                                          child: Text(
                                            'Hide Details',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 4,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.black
                                                .withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Details content
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 48,
                                          left: 16,
                                          right: 16,
                                          bottom: 16,
                                        ),
                                        child: SingleChildScrollView(
                                          child: _buildExpandedDetailsPanel(
                                            story,
                                            useLightText: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  } else {
                    // Collapsed state: keep existing stack layout
                    return Stack(
                      children: [
                        // Story Content with animated blur
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: (isExpanded || keepUnblurred) ? 0.0 : 5.0,
                              sigmaY: (isExpanded || keepUnblurred) ? 0.0 : 5.0,
                            ),
                            child: _buildStoryContent(story, isExpanded),
                          ),
                        ),
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                        // Video Controls (if video)
                        if (story.content.type == ContentType.video)
                          _buildVideoControls(),
                        // Story Info
                        _buildStoryInfo(story),
                        // Action Buttons
                        _buildActionButtons(story),
                        // Quote overlay (collapsed state)
                        if (story.quote != null)
                          _buildQuoteOverlay(
                            story.quote!,
                            isExpanded: !isLargeScreen,
                          ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent(Story story, bool isExpanded) {
    if (story.content.type == ContentType.video) {
      if (isExpanded && _videoControllers.containsKey(story.id)) {
        final controller = _videoControllers[story.id]!;
        return FutureBuilder(
          future: _videoInitFutures[story.id],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Set your desired radius
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(controller),
                        _buildVideoControlOverlay(controller, story.id),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      }
      // Show thumbnail
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child:
            story.content.thumbnail != null
                ? CachedNetworkImage(
                  imageUrl: story.content.thumbnail!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: IslamicTheme.primary.withOpacity(0.2),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              IslamicTheme.primary,
                            ),
                          ),
                        ),
                      ),
                )
                : Container(
                  color: IslamicTheme.primary.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
      );
    }
    // ... existing code for image and text ...
    switch (story.content.type) {
      case ContentType.image:
        return CachedNetworkImage(
          imageUrl: story.content.url!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder:
              (context, url) => Container(
                color: IslamicTheme.primary.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      IslamicTheme.primary,
                    ),
                  ),
                ),
              ),
        );
      case ContentType.text:
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: IslamicTheme.gradientColors,
            ),
          ),
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              story.content.text!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildQuoteOverlay(Quote quote, {required bool isExpanded}) {
    final verticalPosition =
        isExpanded ? 10.0 : MediaQuery.of(context).size.height * 0.35;
    final leftPostison = isExpanded ? 0.0 : 16.0;
    final textAlign = isExpanded ? TextAlign.left : TextAlign.center;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      top: verticalPosition,
      left: leftPostison,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          textAlign: textAlign,
          style: TextStyle(
            color: Colors.white,
            fontSize: isExpanded ? 16 : 22,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text('"${quote.text}"'),
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.pause, color: Colors.white, size: 20),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.volume_up, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryInfo(Story story) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 80,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                if (story.author.profileImage != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: story.author.profileImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.author.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        story.author.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_expandedStory != story.id) ...[
              SizedBox(height: 8),
              Text(
                story.fullStory.testimonial,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (_expandedStory == story.id) _buildExpandedDetails(story),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(Story story) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (story.fullStory.background != null) ...[
                Text(
                  'Background',
                  style: TextStyle(
                    color: IslamicTheme.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  story.fullStory.background!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
              ],
              Text(
                'Journey to Islam',
                style: TextStyle(
                  color: IslamicTheme.primaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                story.fullStory.testimonial,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              if (story.fullStory.beforeIslam != null) ...[
                SizedBox(height: 12),
                Text(
                  'Before Islam',
                  style: TextStyle(
                    color: IslamicTheme.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  story.fullStory.beforeIslam!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
              if (story.fullStory.afterIslam != null) ...[
                SizedBox(height: 12),
                Text(
                  'After Islam',
                  style: TextStyle(
                    color: IslamicTheme.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  story.fullStory.afterIslam!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
              SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    story.metadata.tags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: IslamicTheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: IslamicTheme.primaryLight,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update helper for expanded details panel to support light text for overlay
  Widget _buildExpandedDetailsPanel(Story story, {bool useLightText = false}) {
    final textColor = useLightText ? Colors.white : Colors.black;
    final secondaryColor =
        useLightText ? Colors.white70 : Colors.black.withOpacity(0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and author
        Text(
          story.title,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            if (story.author.profileImage != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: textColor, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: story.author.profileImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.author.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    story.author.location,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildExpandedDetails(story),
        // Action Buttons (like/save)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Like Button
              AnimatedBuilder(
                animation: _heartScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartScale.value,
                    child: GestureDetector(
                      onTap: () => _toggleLike(story.id),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              useLightText
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _likedStories.contains(story.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              _likedStories.contains(story.id)
                                  ? Colors.red
                                  : textColor,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8),
              Text(
                '${story.metadata.likes + (_likedStories.contains(story.id) ? 1 : 0)}',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
              SizedBox(width: 24),
              // Save Button
              AnimatedBuilder(
                animation: _bookmarkScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bookmarkScale.value,
                    child: GestureDetector(
                      onTap: () => _toggleSave(story.id),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              useLightText
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _savedStories.contains(story.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color:
                              _savedStories.contains(story.id)
                                  ? IslamicTheme.primary
                                  : textColor,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8),
              Text(
                '${story.metadata.saves + (_savedStories.contains(story.id) ? 1 : 0)}',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Story story) {
    return Positioned(
      bottom: 80,
      right: 16,
      child: Column(
        children: [
          // Like Button
          AnimatedBuilder(
            animation: _heartScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _heartScale.value,
                child: GestureDetector(
                  onTap: () => _toggleLike(story.id),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _likedStories.contains(story.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          _likedStories.contains(story.id)
                              ? Colors.red
                              : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 4),
          Text(
            '${story.metadata.likes + (_likedStories.contains(story.id) ? 1 : 0)}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 16),

          // Save Button
          AnimatedBuilder(
            animation: _bookmarkScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _bookmarkScale.value,
                child: GestureDetector(
                  onTap: () => _toggleSave(story.id),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _savedStories.contains(story.id)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color:
                          _savedStories.contains(story.id)
                              ? IslamicTheme.primary
                              : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 4),
          Text(
            '${story.metadata.saves + (_savedStories.contains(story.id) ? 1 : 0)}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Add a helper for video controls overlay
  Widget _buildVideoControlOverlay(
    VideoPlayerController controller,
    String storyId,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Play/Pause button
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                },
              ),
              // Mute/Unmute button
              IconButton(
                icon: Icon(
                  controller.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    if (controller.value.volume > 0) {
                      controller.setVolume(0);
                    } else {
                      controller.setVolume(1);
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
