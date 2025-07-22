import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';

// Story Model
class Story {
  final String id;
  final String quote;
  final String author;
  final String title;
  final String content;
  final String backgroundImage;
  final String? image;
  final String? videoUrl;
  final String mediaType;
  final int likeCount;
  final int saveCount;
  final bool isLiked;
  final bool isSaved;
  final String category;
  final String storyType;
  final String authorBackground;
  final String duration;
  final String location;
  final String shahadaDate;

  Story({
    required this.id,
    required this.quote,
    required this.author,
    required this.title,
    required this.content,
    required this.backgroundImage,
    this.image,
    this.videoUrl,
    this.mediaType = 'image',
    required this.likeCount,
    required this.saveCount,
    this.isLiked = false,
    this.isSaved = false,
    required this.category,
    required this.storyType,
    required this.authorBackground,
    required this.duration,
    required this.location,
    required this.shahadaDate,
  });
}

// Main Stories Page
class IslamicStoriesPage extends StatefulWidget {
  @override
  _IslamicStoriesPageState createState() => _IslamicStoriesPageState();
}

class _IslamicStoriesPageState extends State<IslamicStoriesPage>
    with TickerProviderStateMixin {
  late AnimationController _floatAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  PageController _pageController = PageController();
  TextEditingController _searchController = TextEditingController();

  bool _isFilterOpen = false;
  String _selectedCategory = 'all';
  String _selectedStoryType = 'all';
  String _selectedAuthorBackground = 'all';

  @override
  void initState() {
    super.initState();

    // Float animation for icons
    _floatAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _floatAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation for glow effects
    _pulseAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatAnimationController.dispose();
    _pulseAnimationController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.islamicCream,
      body: Stack(
        children: [
          // Arabesque Pattern Background
          _buildArabesqueBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(),

                // Search and Filters
                _buildSearchSection(),

                // Stories Container
                Expanded(child: _buildStoriesContainer()),
              ],
            ),
          ),

          // Gradient Overlays
          _buildGradientOverlays(),
        ],
      ),
    );
  }

  Widget _buildArabesqueBackground() {
    return Container(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Icons and Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heart Icon
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.islamicCream.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColors.islamicGreen300.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey900.withOpacity(0.08),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_outline,
                        color: AppColors.islamicGreen300,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(width: 16),

              // Title Section
              Column(
                children: [
                  // Arabic Title
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          AppColors.islamicGreen300,
                          AppColors.islamicGold300,
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'قصص الإيمان',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  // English Title
                  Text(
                    'Stories of Faith',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 16),

              // Sparkles Icon
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value * -1),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.islamicCream.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColors.islamicGold300.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey900.withOpacity(0.08),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.islamicGold300,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 24),

          // Description Text
          Column(
            children: [
              Text(
                'Discover inspiring journeys of those who found peace, purpose, and truth in Islam.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey600,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 12),

              Text(
                'Each story is a testament to Allah\'s guidance and mercy • كل قصة شاهد على هداية الله ورحمته',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.islamicGreen300,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Search Bar
          Container(
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
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'البحث في القصص الإسلامية • Search Islamic stories...',
                hintStyle: TextStyle(color: AppColors.grey600, fontSize: 16),
                prefixIcon: Icon(Icons.search, color: AppColors.grey600),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFilterOpen = !_isFilterOpen;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.islamicGreen300.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.islamicGreen300.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: AppColors.islamicGreen300,
                      size: 20,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Results count
          Text(
            'Showing all 5 stories',
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStoriesContainer() {
    return Container(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _getSampleStories().length,
        itemBuilder: (context, index) {
          final story = _getSampleStories()[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: IslamicStoryCard(
              story: story,
              onLike: () => _handleLike(story.id),
              onSave: () => _handleSave(story.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Left gradient
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.islamicGreen700.withOpacity(0.3),
                      AppColors.islamicGreen300.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Right gradient
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppColors.islamicGreen700.withOpacity(0.3),
                      AppColors.islamicGreen300.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Top gradient
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.islamicGreen700.withOpacity(0.3),
                      AppColors.islamicGreen300.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.islamicGreen700.withOpacity(0.3),
                      AppColors.islamicGreen300.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLike(String storyId) {
    HapticFeedback.lightImpact();
    // Implement like functionality
  }

  void _handleSave(String storyId) {
    HapticFeedback.lightImpact();
    // Implement save functionality
  }

  List<Story> _getSampleStories() {
    return [
      Story(
        id: '1',
        quote:
            'I found the peace I was searching for my whole life when I discovered Islam.',
        author: 'Sarah Johnson - New Muslim from California',
        title: 'From Anxiety to Peace: My Journey to Islam',
        content:
            'Growing up in a Christian household, I always felt something was missing...',
        backgroundImage:
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176',
        image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        mediaType: 'image',
        likeCount: 3247,
        saveCount: 2892,
        isLiked: false,
        isSaved: true,
        category: 'conversion',
        storyType: 'personal',
        authorBackground: 'christian',
        duration: '5 min read',
        location: 'California, USA',
        shahadaDate: 'March 15, 2023',
      ),
      // Add more stories...
    ];
  }
}

// Islamic Story Card Widget
class IslamicStoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback onLike;
  final VoidCallback onSave;

  IslamicStoryCard({
    required this.story,
    required this.onLike,
    required this.onSave,
  });

  @override
  _IslamicStoryCardState createState() => _IslamicStoryCardState();
}

class _IslamicStoryCardState extends State<IslamicStoryCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }

    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleFlip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey900.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isShowingFront ? _buildFrontCard() : _buildBackCard(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.story.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.islamicCream.withOpacity(0.2),
                      AppColors.overlayMedium,
                      AppColors.grey900.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Quote Container
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.islamicCream.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.islamicGreen300.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey900.withOpacity(0.15),
                          blurRadius: 30,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Decorative line
                        Container(
                          width: 64,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.islamicGreen300,
                                AppColors.islamicGold300,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Quote
                        Text(
                          '"${widget.story.quote}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 24),

                        // Author
                        Text(
                          '— ${widget.story.author}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.islamicGreen300,
                          ),
                        ),

                        SizedBox(height: 24),

                        // Decorative line
                        Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.islamicGold300,
                                AppColors.islamicGreen300,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flip hint
          Positioned(
            top: 32,
            right: 32,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.islamicCream.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppColors.islamicGold300.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.refresh,
                color: AppColors.islamicGold300,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.islamicCream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Media section
            if (widget.story.image != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(widget.story.image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.story.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),

                    SizedBox(height: 8),

                    // Author
                    Text(
                      widget.story.author,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.islamicGreen300,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Metadata row
                    Row(
                      children: [
                        _buildMetadataChip(
                          Icons.schedule,
                          widget.story.duration,
                        ),
                        SizedBox(width: 8),
                        _buildMetadataChip(
                          Icons.location_on,
                          widget.story.location,
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Content (scrollable)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.story.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey600,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Engagement footer
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.islamicCream.withOpacity(0.8),
                border: Border(
                  top: BorderSide(
                    color: AppColors.islamicGreen300.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: widget.onLike,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.islamicCream.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.islamicGreen300.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.story.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: AppColors.islamicGreen300,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.story.likeCount.toString(),
                                style: TextStyle(
                                  color: AppColors.islamicGreen300,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Save button
                      GestureDetector(
                        onTap: widget.onSave,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.islamicCream.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.islamicGold300.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.story.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                color: AppColors.islamicGold300,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.story.saveCount.toString(),
                                style: TextStyle(
                                  color: AppColors.islamicGold300,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Additional actions
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.comment_outlined,
                          color: AppColors.grey600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share_outlined,
                          color: AppColors.grey600,
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
    );
  }

  Widget _buildMetadataChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.islamicCream.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.islamicGreen300.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.islamicGreen300),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}

// Main App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic Stories',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Inter'),
      home: IslamicStoriesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}
