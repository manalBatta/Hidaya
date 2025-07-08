// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/AskPage.dart';
import 'package:frontend/widgets/HomePage.dart';
import 'package:frontend/widgets/LessonsPage.dart';
import 'package:frontend/widgets/ProfilePage.dart';

class MainLayout extends StatefulWidget {
  final String userRole;

  const MainLayout({Key? key, this.userRole = 'user'}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List_pages = [ProfilePage(), HomePage(), AskPage(), LessonsPage()];

  final List_navigationItems = [
    NavigationItem(icon: Icons.home, label: 'Home', activeIcon: Icons.home),
    NavigationItem(
      icon: Icons.help_outline,
      label: 'Ask',
      activeIcon: Icons.help,
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      label: 'Lessons',
      activeIcon: Icons.book,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      label: 'Profile',
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.userRole == 'admin' ? _buildAdminDrawer() : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4FBF8), // islamic-green-50
              Color(0xFFF7F6F3), // islamic-cream
              Color(0xFFFCF7E8), // islamic-gold-50
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: List_pages[_currentIndex],
            ),

            // Admin drawer button
            if (widget.userRole == 'admin')
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFBFE3D5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.menu,
                          color: Color(0xFF165A3F),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: Color(0xFFBFE3D5), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          child: Row(
            children:
                List_navigationItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  NavigationItem item = entry.value;
                  bool isActive = _currentIndex == index;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _currentIndex = index),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: isActive ? 1.1 : 1.0,
                                      duration: Duration(milliseconds: 200),
                                      child: Icon(
                                        isActive ? item.activeIcon : item.icon,
                                        size: 24,
                                        color:
                                            isActive
                                                ? Color(0xFF206F4F)
                                                : Color(0xFF6BB087),
                                      ),
                                    ),
                                    if (isActive)
                                      Positioned(
                                        bottom: -2,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF206F4F),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isActive
                                          ? Color(0xFF165A3F)
                                          : Color(0xFF45A376),
                                ),
                                child: Text(item.label),
                              ),
                              if (isActive)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  width: 48,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2D8662),
                                        Color(0xFF206F4F),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D8662), Color(0xFF206F4F)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF104C34),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Color(0xFFBFE3D5)),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Admin Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to admin dashboard
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.flag,
                    title: 'Review Flagged Answers',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to flagged answers
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_add,
                    title: 'Promote Volunteers',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to promote volunteers
                    },
                  ),
                  SizedBox(height: 20),
                  Divider(color: Color(0xFFBFE3D5)),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.red[600],
                    onTap: () {
                      Navigator.pop(context);
                      // Handle logout
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              margin: EdgeInsets.all(24),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF4FBF8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFBFE3D5)),
              ),
              child: Column(
                children: [
                  Text(
                    'Hidaya Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF206F4F),
                    ),
                  ),
                  Text(
                    'Managing with wisdom',
                    style: TextStyle(fontSize: 12, color: Color(0xFF45A376)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: textColor ?? Color(0xFF206F4F)),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Color(0xFF206F4F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
