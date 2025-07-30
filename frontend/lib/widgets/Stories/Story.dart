import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config.dart';
import 'package:frontend/utils/auth_utils.dart';
import 'dart:ui';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/constants/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:frontend/providers/UserProvider.dart';

// Story Data Models

enum StoryType { video, image }

class Story {
  final String id;
  final String title;
  final String? background;
  final String? journeyToIslam;
  final String? afterIslam;
  final StoryType type;
  final String mediaUrl;
  final String? quote;
  int saveCount;
  int likeCount;
  final int views;
  final String name;
  final String country;
  final List<String> tags;
  final DateTime createdAt;
  final String? description;

  Story({
    required this.id,
    required this.title,
    this.background,
    this.journeyToIslam,
    this.afterIslam,
    required this.type,
    required this.mediaUrl,
    this.quote,
    required this.saveCount,
    required this.likeCount,
    required this.views,
    required this.name,
    required this.country,
    required this.tags,
    required this.createdAt,
    this.description,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'],
      title: json['title'],
      background: json['background'],
      journeyToIslam: json['journeyToIslam'],
      afterIslam: json['afterIslam'],
      type: json['type'] == 'video' ? StoryType.video : StoryType.image,
      mediaUrl: json['mediaUrl'],
      quote: json['quote'],
      saveCount: int.tryParse(json['SaveCount'] ?? '0') ?? 0,
      likeCount: int.tryParse(json['likeCount'] ?? '0') ?? 0,
      views: int.tryParse(json['views'] ?? '0') ?? 0,
      name: json['name'],
      country: json['country'],
      tags: (json['tags'] as List<dynamic>).map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
    );
  }
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

// Fetch stories from API
Future<List<Story>> fetchStories() async {
  final response = await http.get(Uri.parse('$storyUrl?page=1&limit=5'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> storiesJson = data['data']['stories'];
    return storiesJson.map((json) => Story.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load stories');
  }
}

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
  List<Story> _filteredStories = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchingMore = false;

  // Filter states
  // Removed ContentType, Language, Gender filter states as they are not used with API data

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
    // Initialize _savedStories from UserProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _savedStories = Set<String>.from(userProvider.savedStories);
      });
    });
    // Initialize _likedStories from UserProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _likedStories = Set<String>.from(userProvider.likedStories);
      });
    });
    _fetchAndSetStories();
  }

  Future<void> _fetchAndSetStories({int page = 1, bool append = false}) async {
    if (_isFetchingMore) return;
    if (append && (page > _totalPages)) return;
    setState(() {
      if (!append) _isLoading = true;
      _error = null;
      _isFetchingMore = append;
    });
    try {
      final response = await http.get(
        Uri.parse('$storyUrl?page=$page&limit=5'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> storiesJson = data['data']['stories'];
        final List<Story> newStories =
            storiesJson.map((json) => Story.fromJson(json)).toList();
        final pagination = data['data']['pagination'];
        setState(() {
          if (append) {
            _filteredStories.addAll(newStories);
          } else {
            _filteredStories = newStories;
          }
          _isLoading = false;
          _isFetchingMore = false;
          _currentPage = pagination['page'] ?? page;
          _totalPages = pagination['totalPages'] ?? 1;
        });
      } else {
        throw Exception('Failed to load stories');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void _preinitializeNextVideo(int currentIndex) {
    if (currentIndex + 1 < _filteredStories.length) {
      final nextStory = _filteredStories[currentIndex + 1];
      if (nextStory.type == StoryType.video &&
          !_videoControllers.containsKey(nextStory.id)) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(nextStory.mediaUrl),
        );
        _videoControllers[nextStory.id] = controller;
        _videoInitFutures[nextStory.id] = controller.initialize();
      }
    }
  }

  void _saveStory() async {
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        return;
      }

      var response = await http.post(
        Uri.parse(saveStoryUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"id": _filteredStories[_currentIndex].id}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        print("response from saving= $data");
        final user = data["data"];
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        if (mounted) {
          setState(() {
            _toggleSave(_filteredStories[_currentIndex].id);
          });
        }
      }
    } catch (e) {
      print("error saving story: $e");
    }
  }

  void _likeStory() async {
    print("like story");
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        return;
      }

      var response = await http.post(
        Uri.parse(likeStoryUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"id": _filteredStories[_currentIndex].id}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        print("response from like = $data");
        final user = data["data"];
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        if (mounted) {
          setState(() {
            _toggleLike(_filteredStories[_currentIndex].id);
          });
        }
      }
    } catch (e) {
      print("error saving story: $e");
    }
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
          _filteredStories.where((story) {
            bool matchesSearch =
                _searchQuery.isEmpty ||
                story.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                story.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                story.country.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (story.background?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (story.journeyToIslam?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (story.afterIslam?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
            return matchesSearch;
          }).toList();
    });
  }

  void _toggleLike(String storyId) {
    setState(() {
      if (_likedStories.contains(storyId)) {
        _likedStories.remove(storyId);
        _filteredStories[_currentIndex].likeCount =
            _filteredStories[_currentIndex].likeCount - 1;
      } else {
        _filteredStories[_currentIndex].likeCount =
            _filteredStories[_currentIndex].likeCount + 1;
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
        _filteredStories[_currentIndex].saveCount =
            _filteredStories[_currentIndex].saveCount - 1;
      } else {
        _filteredStories[_currentIndex].saveCount =
            _filteredStories[_currentIndex].saveCount + 1;
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
        final story = _filteredStories.firstWhere((s) => s.id == storyId);
        // Only create a video controller for video stories!
        if (story.type == StoryType.video) {
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(story.mediaUrl),
          );
          _videoControllers[storyId] = controller;
          _videoInitFutures[storyId] = controller.initialize().then((_) {
            controller.setLooping(true);
            controller.play();
            setState(() {});
          });
        }
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
          if (_currentIndex < _filteredStories.length - 1 &&
              event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            return KeyEventResult.handled;
          } else if (_currentIndex > 0 &&
              event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
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
                if (_isLoading) Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Center(
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  ),
                if (!_isLoading && _error == null)
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _expandedStory =
                            null; // Close expanded story when changing pages
                      });
                      // If user reaches the last card, fetch more if available
                      if (index == _filteredStories.length - 1 &&
                          !_isFetchingMore &&
                          _currentPage < _totalPages) {
                        _fetchAndSetStories(
                          page: _currentPage + 1,
                          append: true,
                        );
                      }
                      // Pre-initialize next video
                      _preinitializeNextVideo(index);
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
                // (Page indicators removed as requested)
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
            // Removed ContentType and Language filter chips as they are not used with API data
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
                                  if (story.quote != null &&
                                      story.quote!.isNotEmpty)
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
                        // Removed ContentType.video check for _buildVideoControls()
                        // Story Info
                        _buildStoryInfo(story),
                        // Action Buttons
                        _buildActionButtons(story),
                        // Removed Quote overlay widget and all references as Quote is not used in API data
                        // Quote overlay (collapsed state)
                        if (story.quote != null && story.quote!.isNotEmpty)
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
    if (story.type == StoryType.video) {
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
                    borderRadius: BorderRadius.circular(20),
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
      // Show paused video with semi-transparent overlay and play icon as thumbnail
      if (_videoControllers.containsKey(story.id)) {
        final controller = _videoControllers[story.id]!;
        return FutureBuilder(
          future: _videoInitFutures[story.id],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              controller.pause();
              return Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        VideoPlayer(controller),
                        Container(color: Colors.black.withOpacity(0.7)),
                        Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
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
      } else {
        // Initialize controller for thumbnail if not already
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(story.mediaUrl),
        );
        _videoControllers[story.id] = controller;
        _videoInitFutures[story.id] = controller.initialize();
        return FutureBuilder(
          future: _videoInitFutures[story.id],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              controller.pause();
              return Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        VideoPlayer(controller),
                        Container(color: Colors.black.withOpacity(0.5)),
                        Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
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
    }
    // For images
    if (story.type == StoryType.image) {
      if (isExpanded) {
        // Show image at actual size if smaller than container, else fit
        return Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: story.mediaUrl,
                fit:
                    BoxFit
                        .contain, // This will always fit the image inside the box
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
              ),
            ),
          ),
        );
      } else {
        // Collapsed: keep current logic (cover)
        return CachedNetworkImage(
          imageUrl: story.mediaUrl,
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
      }
    }
    return SizedBox.shrink();
  }

  // Add this helper widget for quote overlay
  Widget _buildQuoteOverlay(String quote, {required bool isExpanded}) {
    final verticalPosition =
        isExpanded ? 10.0 : MediaQuery.of(context).size.height * 0.35;
    final leftPosition = isExpanded ? 0.0 : 16.0;
    final textAlign = isExpanded ? TextAlign.left : TextAlign.center;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      top: verticalPosition,
      left: leftPosition,
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
          child: Text('"$quote"'),
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
            if (story.description != null && story.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text(
                  story.description!,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                if (story.name != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: "assets/StoryImages/profile.jpg",
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
                        story.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        story.country,
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
                story.background ?? '',
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

  // Helper to extract description sections
  Map<String, String> extractDescriptionParts(String description) {
    final parts = <String, String>{};
    // Match 'Background' and 'Journey to Islam' sections, even if no blank lines between
    final regex = RegExp(
      r'(Background|Journey to Islam)\s*([\s\S]*?)(?=Background|Journey to Islam|\$)',
      multiLine: true,
    );
    for (final match in regex.allMatches(description)) {
      final key = match.group(1)!;
      final value = match.group(2)!.trim();
      parts[key] = value;
    }
    return parts;
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
              if (story.description != null &&
                  story.description!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    story.description!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (story.background != null && story.background!.isNotEmpty) ...[
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
                  story.background!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
              ],
              if (story.journeyToIslam != null &&
                  story.journeyToIslam!.isNotEmpty) ...[
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
                  story.journeyToIslam!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
              ],
              if (story.afterIslam != null && story.afterIslam!.isNotEmpty) ...[
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
                  story.afterIslam!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
              ],
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    story.tags.map((tag) {
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
        if (story.description != null && story.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
            child: Text(
              story.description!,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: 8),
        Row(
          children: [
            if (story.name != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: textColor, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: "assets/StoryImages/profile.jpg",
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
                    story.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    story.country,
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
                      onTap: _likeStory,
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
                '${story.likeCount}',
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
                      onTap: _saveStory,
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
                '${story.saveCount}',
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
                  onTap: _likeStory,
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
            '${story.likeCount}',
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
                  onTap: _saveStory,
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
            '${story.saveCount}',
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
