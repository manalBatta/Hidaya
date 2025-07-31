import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/Admin/AdminDashboard.dart';
import 'package:frontend/widgets/Admin/AdminQuestions.dart';
import 'package:frontend/widgets/Admin/AdminUsersPage.dart';

// Islamic Theme Colors
class IslamicColors {
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF059669);
  static const Color green600 = Color(0xFF047857);
  static const Color green700 = Color(0xFF065F46);
  static const Color green800 = Color(0xFF064E3B);
  static const Color green900 = Color(0xFF022C22);

  static const Color gold50 = Color(0xFFFFFBEB);
  static const Color gold100 = Color(0xFFFEF3C7);
  static const Color gold200 = Color(0xFFFDE68A);
  static const Color gold300 = Color(0xFFFCD34D);
  static const Color gold400 = Color(0xFFFBBF24);
  static const Color gold500 = Color(0xFFF59E0B);

  static const Color cream = Color(0xFFFAF9F6);
  static const Color white = Color(0xFFFFFFFF);
}

// Navigation Item Model
class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final String? route;
  final List<NavigationItem>? subItems;

  NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.subItems,
  });
}

// Main Admin Panel Widget
class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentRoute = '/admin/dashboard';
  final Set<String> _expandedItems = {};

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      id: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/admin/dashboard',
    ),
    NavigationItem(
      id: 'users',
      label: 'Users',
      icon: Icons.people_outline,
      route: '/admin/users',
    ),
    NavigationItem(
      id: 'questions',
      label: 'Questions & Answers',
      icon: Icons.help_outline,
      route: '/admin/questions',
    ),
    /*  NavigationItem(
      id: 'lessons',
      label: 'Lessons',
      icon: Icons.menu_book_outlined,
      subItems: [
        NavigationItem(
          id: 'all-lessons',
          label: 'All Lessons',
          icon: Icons.book,
          route: '/admin/lessons',
        ),
        NavigationItem(
          id: 'add-lesson',
          label: 'Add Lesson',
          icon: Icons.add_box,
          route: '/admin/lessons/add',
        ),
      ],
    ), */
    NavigationItem(
      id: 'stories',
      label: 'Revert Stories',
      icon: Icons.bookmark_outline,
      subItems: [
        NavigationItem(
          id: 'all-stories',
          label: 'All Stories',
          icon: Icons.bookmark,
          route: '/admin/stories',
        ),
        NavigationItem(
          id: 'add-story',
          label: 'Add New',
          icon: Icons.add,
          route: '/admin/stories/add',
        ),
      ],
    ),
    /* NavigationItem(
      id: 'mosques',
      label: 'Mosques',
      icon: Icons.location_city,
      route: '/admin/mosques',
    ), */
    NavigationItem(
      id: 'flags',
      label: 'Flags / Reports',
      icon: Icons.flag_outlined,
      route: '/admin/flags',
    ),
    /*  NavigationItem(
      id: 'notifications',
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      route: '/admin/notifications',
    ), */
    /*  NavigationItem(
      id: 'ai-insights',
      label: 'AI Insights',
      icon: Icons.psychology_outlined,
      subItems: [
        NavigationItem(
          id: 'user-interests',
          label: 'User Interests',
          icon: Icons.interests,
          route: '/admin/ai-insights/interests',
        ),
        NavigationItem(
          id: 'related-content',
          label: 'Related Content',
          icon: Icons.link,
          route: '/admin/ai-insights/content',
        ),
        NavigationItem(
          id: 'user-matching',
          label: 'User Matching',
          icon: Icons.people_alt,
          route: '/admin/ai-insights/matching',
        ),
      ],
    ), */
    /* NavigationItem(
      id: 'analytics',
      label: 'Analytics',
      icon: Icons.analytics_outlined,
      subItems: [
        NavigationItem(
          id: 'user-analytics',
          label: 'Users',
          icon: Icons.bar_chart,
          route: '/admin/analytics/users',
        ),
        NavigationItem(
          id: 'question-analytics',
          label: 'Questions',
          icon: Icons.bar_chart,
          route: '/admin/analytics/questions',
        ),
        NavigationItem(
          id: 'lesson-analytics',
          label: 'Lessons',
          icon: Icons.bar_chart,
          route: '/admin/analytics/lessons',
        ),
        NavigationItem(
          id: 'story-analytics',
          label: 'Stories',
          icon: Icons.bar_chart,
          route: '/admin/analytics/stories',
        ),
      ],
    ),
    NavigationItem(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: '/admin/settings',
    ), */
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: IslamicColors.green50,
      drawer: _buildMobileDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1024;

          if (isMobile) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IslamicColors.green50,
            IslamicColors.cream,
            IslamicColors.gold50,
          ],
        ),
      ),
      child: Row(
        children: [
          // Fixed Sidebar
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: IslamicColors.white.withOpacity(0.95),
              border: const Border(
                right: BorderSide(color: IslamicColors.green200, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildSidebarContent(),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [_buildTopBar(), Expanded(child: _buildMainContent())],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IslamicColors.green50,
            IslamicColors.cream,
            IslamicColors.gold50,
          ],
        ),
      ),
      child: Column(
        children: [_buildTopBar(), Expanded(child: _buildMainContent())],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: IslamicColors.green200, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [IslamicColors.green500, IslamicColors.green600],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: IslamicColors.green200,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: IslamicColors.green800,
                      ),
                    ),
                    Text(
                      'Hidaya Management',
                      style: TextStyle(
                        fontSize: 14,
                        color: IslamicColors.green600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Navigation
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            children: _navigationItems.map(_buildNavigationTile).toList(),
          ),
        ),
        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: IslamicColors.green200, width: 1),
            ),
          ),
          child: _buildLogoutButton(),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: IslamicColors.white,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: IslamicColors.white.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: IslamicColors.green200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Mobile menu button
            if (MediaQuery.of(context).size.width < 1024)
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: IslamicColors.green700),
              ),
            const SizedBox(width: 16),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: IslamicColors.green800,
              ),
            ),
            const Spacer(),
            // User menu
            _buildUserMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: IslamicColors.green500,
              child: const Text(
                'AD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Admin',
              style: TextStyle(
                color: IslamicColors.green700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: IslamicColors.green600,
              size: 16,
            ),
          ],
        ),
      ),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 16),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
      onSelected: _handleUserMenuAction,
    );
  }

  Widget _buildNavigationTile(NavigationItem item) {
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.id);
    final isActive = _isItemActive(item);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleNavigationTap(item),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    isActive && !hasSubItems
                        ? IslamicColors.green500
                        : isActive
                        ? IslamicColors.green100
                        : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color:
                        isActive && !hasSubItems
                            ? Colors.white
                            : isActive
                            ? IslamicColors.green800
                            : IslamicColors.green700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            isActive && !hasSubItems
                                ? Colors.white
                                : isActive
                                ? IslamicColors.green800
                                : IslamicColors.green700,
                      ),
                    ),
                  ),
                  if (hasSubItems) ...[
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 16,
                      color:
                          isActive && !hasSubItems
                              ? Colors.white
                              : IslamicColors.green600,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (hasSubItems && isExpanded) ...[
          const SizedBox(height: 4),
          ...item.subItems!.map((subItem) => _buildSubNavigationTile(subItem)),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubNavigationTile(NavigationItem item) {
    final isActive = _currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNavigationTap(item),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive ? IslamicColors.green500 : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive ? Colors.white : IslamicColors.green700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : IslamicColors.green700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleLogout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: _getContentForRoute(_currentRoute),
    );
  }

  Widget _getContentForRoute(String route) {
    switch (route) {
      case '/admin/dashboard':
        return AdminDashboard();
      case '/admin/users':
        return AdminUsersPage();
      case '/admin/questions':
        return AdminQuestions();
      case '/admin/lessons':
        return _buildLessonsPage();
      case '/admin/stories':
        return _buildStoriesPage();
      case '/admin/stories/add':
        return _buildAddStoryPage();
      default:
        return _buildPlaceholderPage(route);
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: IslamicColors.green800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Welcome back! Here\'s what\'s happening with your platform.',
                    style: TextStyle(
                      fontSize: 16,
                      color: IslamicColors.green600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: IslamicColors.green300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateTime.now().toString().split(' ')[0],
                  style: const TextStyle(
                    color: IslamicColors.green700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Stats Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              final crossAxisCount =
                  cardWidth > 1200
                      ? 4
                      : cardWidth > 800
                      ? 2
                      : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Users',
                    '12,547',
                    Icons.people,
                    '+12% from last month',
                    IslamicColors.green600,
                  ),
                  _buildStatCard(
                    'Certified Volunteers',
                    '127',
                    Icons.verified_user,
                    '+3 this week',
                    IslamicColors.green600,
                  ),
                  _buildStatCard(
                    'Pending Applications',
                    '23',
                    Icons.person_add,
                    '+5 new today',
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Questions',
                    '8,934',
                    Icons.help,
                    '+32 today',
                    IslamicColors.green600,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          // Today's Highlights
          Row(
            children: [
              Expanded(child: _buildHighlightsCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildTopContentCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    String change,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IslamicColors.green100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: IslamicColors.green800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 12, color: Colors.green[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  change,
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IslamicColors.green100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: IslamicColors.green600,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Today\'s Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: IslamicColors.green800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHighlightItem('New Users', '18'),
          _buildHighlightItem('New Questions', '32'),
          _buildHighlightItem('Content Flagged', '3', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWarning ? Colors.red[100] : IslamicColors.green100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWarning ? Colors.red[800] : IslamicColors.green800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopContentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IslamicColors.green100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: IslamicColors.green600, size: 20),
              SizedBox(width: 8),
              Text(
                'Top Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: IslamicColors.green800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Rated Lesson',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Understanding Prayer Times',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: IslamicColors.green700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Most Saved Question',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'How to perform Wudu correctly?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: IslamicColors.green700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsPage() {
    return _buildPlaceholderPage('/admin/questions');
  }

  Widget _buildLessonsPage() {
    return _buildPlaceholderPage('/admin/lessons');
  }

  Widget _buildStoriesPage() {
    return _buildPlaceholderPage('/admin/stories');
  }

  Widget _buildAddStoryPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Story',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: IslamicColors.green800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Create a new revert story to inspire others',
                    style: TextStyle(
                      fontSize: 16,
                      color: IslamicColors.green600,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _navigateToRoute('/admin/stories'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: IslamicColors.green600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16),
                    SizedBox(width: 8),
                    Text('Back to Stories'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IslamicColors.green100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Story Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: IslamicColors.green800,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Story Title',
                        'Enter a compelling title',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown('Language', [
                        'English',
                        'Arabic',
                        'Urdu',
                        'Turkish',
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Author Name',
                        'Enter author name',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField('Author Country', 'Enter country'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Story Content',
                  'Share the inspiring journey...',
                  maxLines: 6,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Tags',
                        'conversion, faith, journey (comma-separated)',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown('Media Type', [
                        'Text',
                        'Audio',
                        'Video',
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _navigateToRoute('/admin/stories'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: IslamicColors.green700,
                        side: const BorderSide(color: IslamicColors.green300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _handleSaveStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IslamicColors.green600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Create Story'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: IslamicColors.green700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: IslamicColors.green200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: IslamicColors.green200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: IslamicColors.green500),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: IslamicColors.green700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: IslamicColors.green200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: IslamicColors.green200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: IslamicColors.green500),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              options
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildPlaceholderPage(String route) {
    final routeName = route.split('/').last.replaceAll('-', ' ').toUpperCase();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: IslamicColors.green100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.construction,
              size: 48,
              color: IslamicColors.green600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            routeName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: IslamicColors.green800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This page is under construction',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToRoute('/admin/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: IslamicColors.green600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  bool _isItemActive(NavigationItem item) {
    if (item.route == _currentRoute) return true;
    if (item.subItems != null) {
      return item.subItems!.any((subItem) => subItem.route == _currentRoute);
    }
    return false;
  }

  void _handleNavigationTap(NavigationItem item) {
    if (item.subItems != null && item.subItems!.isNotEmpty) {
      setState(() {
        if (_expandedItems.contains(item.id)) {
          _expandedItems.remove(item.id);
        } else {
          _expandedItems.add(item.id);
        }
      });
    } else if (item.route != null) {
      _navigateToRoute(item.route!);
    }

    // Close mobile drawer if open
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  void _handleUserMenuAction(String action) {
    switch (action) {
      case 'settings':
        _navigateToRoute('/admin/settings');
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle logout logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _handleSaveStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story created successfully!'),
        backgroundColor: IslamicColors.green600,
      ),
    );
    _navigateToRoute('/admin/stories');
  }
}
