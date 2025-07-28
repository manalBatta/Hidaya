import 'package:flutter/material.dart';

// Islamic Theme Colors matching the web design
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

  static const Color cream = Color(0xFFFAF9F6);
  static const Color white = Color(0xFFFFFFFF);
}

// User Model
class User {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String country;
  final String language;
  final DateTime joinedAt;
  final bool isActive;
  final int questionsAsked;
  final int? questionsAnswered;
  final double? rating;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.country,
    required this.language,
    required this.joinedAt,
    required this.isActive,
    required this.questionsAsked,
    this.questionsAnswered,
    this.rating,
  });
}

// Volunteer Application Model
class VolunteerApplication {
  final String id;
  final String name;
  final String email;
  final String country;
  final List<String> languages;
  final String bio;
  final String status;
  final DateTime appliedAt;

  VolunteerApplication({
    required this.id,
    required this.name,
    required this.email,
    required this.country,
    required this.languages,
    required this.bio,
    required this.status,
    required this.appliedAt,
  });
}

// Main Users Management Page
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _countryFilter = 'all';
  String _languageFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock Data
  final List<User> users = [
    User(
      id: "1",
      displayName: "Ahmad Hassan",
      email: "ahmad.hassan@email.com",
      role: "certified_volunteer",
      country: "Saudi Arabia",
      language: "Arabic",
      joinedAt: DateTime(2024, 1, 15),
      isActive: true,
      questionsAsked: 12,
      questionsAnswered: 245,
      rating: 4.8,
    ),
    User(
      id: "2",
      displayName: "Fatima Al-Zahra",
      email: "fatima.zahra@email.com",
      role: "user",
      country: "Lebanon",
      language: "Arabic",
      joinedAt: DateTime(2024, 2, 20),
      isActive: true,
      questionsAsked: 8,
    ),
    User(
      id: "3",
      displayName: "Muhammad Khan",
      email: "muhammad.khan@email.com",
      role: "certified_volunteer",
      country: "Pakistan",
      language: "Urdu",
      joinedAt: DateTime(2024, 1, 10),
      isActive: true,
      questionsAsked: 15,
      questionsAnswered: 189,
      rating: 4.6,
    ),
    User(
      id: "4",
      displayName: "Sarah Johnson",
      email: "sarah.johnson@email.com",
      role: "user",
      country: "United States",
      language: "English",
      joinedAt: DateTime(2024, 3, 5),
      isActive: true,
      questionsAsked: 22,
    ),
    User(
      id: "5",
      displayName: "Ali Rahman",
      email: "ali.rahman@email.com",
      role: "admin",
      country: "Malaysia",
      language: "English",
      joinedAt: DateTime(2023, 12, 1),
      isActive: true,
      questionsAsked: 5,
    ),
    User(
      id: "6",
      displayName: "Omar Ibrahim",
      email: "omar.ibrahim@email.com",
      role: "user",
      country: "Egypt",
      language: "Arabic",
      joinedAt: DateTime(2024, 4, 12),
      isActive: true,
      questionsAsked: 16,
    ),
    User(
      id: "7",
      displayName: "Zainab Ahmed",
      email: "zainab.ahmed@email.com",
      role: "certified_volunteer",
      country: "Morocco",
      language: "Arabic",
      joinedAt: DateTime(2024, 2, 28),
      isActive: true,
      questionsAsked: 9,
      questionsAnswered: 156,
      rating: 4.7,
    ),
    User(
      id: "8",
      displayName: "Abdullah Malik",
      email: "abdullah.malik@email.com",
      role: "user",
      country: "Turkey",
      language: "Turkish",
      joinedAt: DateTime(2024, 5, 15),
      isActive: false,
      questionsAsked: 3,
    ),
  ];

  final List<VolunteerApplication> applications = [
    VolunteerApplication(
      id: "app1",
      name: "Yasmin Al-Rashid",
      email: "yasmin.rashid@email.com",
      country: "Jordan",
      languages: ["Arabic", "English"],
      bio: "Islamic studies graduate with 5 years teaching experience.",
      status: "pending",
      appliedAt: DateTime(2024, 6, 20),
    ),
    VolunteerApplication(
      id: "app2",
      name: "Ibrahim Yusuf",
      email: "ibrahim.yusuf@email.com",
      country: "Nigeria",
      languages: ["English", "Hausa"],
      bio: "Community imam with expertise in Islamic jurisprudence.",
      status: "pending",
      appliedAt: DateTime(2024, 6, 18),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IslamicColors.green50,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              IslamicColors.green50,
              IslamicColors.cream,
              Color(0xFFFFFBEB), // Islamic gold 50
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildNavigationTabs(),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildContentArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: IslamicColors.green800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage all users, volunteers, and administrators',
              style: TextStyle(fontSize: 16, color: IslamicColors.green600),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export Users'),
              style: OutlinedButton.styleFrom(
                foregroundColor: IslamicColors.green700,
                side: const BorderSide(color: IslamicColors.green300),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: IslamicColors.green600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: IslamicColors.green600,
          borderRadius: BorderRadius.circular(6),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[700],
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(text: 'All Users'),
          const Tab(text: 'Volunteers'),
          Tab(
            text:
                'Applications (${applications.where((app) => app.status == "pending").length})',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Users',
          '${users.length}',
          Icons.people,
          IslamicColors.green600,
        ),
        _buildStatCard(
          'Volunteers',
          '${users.where((u) => u.role == "certified_volunteer").length}',
          Icons.verified_user,
          Colors.green[600]!,
        ),
        _buildStatCard(
          'Admins',
          '${users.where((u) => u.role == "admin").length}',
          Icons.star,
          Colors.red[600]!,
        ),
        _buildStatCard(
          'Pending Applications',
          '${applications.where((app) => app.status == "pending").length}',
          Icons.people,
          Colors.blue[600]!,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
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
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: IslamicColors.green800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: IslamicColors.green100)),
            ),
            child: Row(
              children: [
                Text(
                  _getTabTitle(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: IslamicColors.green800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSearchAndFilters(),
                const SizedBox(height: 24),
                SizedBox(
                  height: 500, // Set a fixed height for TabBarView
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsersTable(),
                      _buildVolunteersTable(),
                      _buildApplicationsTable(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0:
        return 'All Users';
      case 1:
        return 'Certified Volunteers';
      case 2:
        return 'Volunteer Applications';
      default:
        return 'All Users';
    }
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: IslamicColors.green200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterDropdown('Role', _roleFilter, [
                'all',
                'user',
                'certified_volunteer',
                'admin',
              ], (value) => setState(() => _roleFilter = value)),
              const SizedBox(width: 16),
              _buildFilterDropdown(
                'Country',
                _countryFilter,
                [
                  'all',
                  'Saudi Arabia',
                  'Lebanon',
                  'Pakistan',
                  'United States',
                  'Malaysia',
                  'Egypt',
                  'Morocco',
                  'Turkey',
                ],
                (value) => setState(() => _countryFilter = value),
              ),
              const SizedBox(width: 16),
              _buildFilterDropdown(
                'Language',
                _languageFilter,
                ['all', 'English', 'Arabic', 'Urdu', 'Turkish'],
                (value) => setState(() => _languageFilter = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: IslamicColors.green200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: (newValue) => onChanged(newValue!),
          icon: const Icon(Icons.filter_list, size: 16),
          items:
              options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option == 'all' ? 'All $label' : _formatOption(option),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  String _formatOption(String option) {
    if (option == 'certified_volunteer') return 'Volunteer';
    return option.split('_').map((word) => word.capitalize()).join(' ');
  }

  Widget _buildUsersTable() {
    final filteredUsers = _getFilteredUsers();

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: IslamicColors.green100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(IslamicColors.green50),
            columns: const [
              DataColumn(
                label: Text(
                  'User',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Role',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Country',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Language',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Joined',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Activity',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            rows: filteredUsers.map((user) => _buildUserRow(user)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteersTable() {
    final volunteers =
        users.where((u) => u.role == "certified_volunteer").toList();

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: IslamicColors.green100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(IslamicColors.green50),
            columns: const [
              DataColumn(
                label: Text(
                  'Volunteer',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Country',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Language',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Rating',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Answers',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            rows: volunteers.map((user) => _buildVolunteerRow(user)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsTable() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: IslamicColors.green100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(IslamicColors.green50),
            columns: const [
              DataColumn(
                label: Text(
                  'Applicant',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Country',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Languages',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Applied',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            rows: applications.map((app) => _buildApplicationRow(app)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildUserRow(User user) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: IslamicColors.green100,
                child: Text(
                  user.displayName.split(' ').map((n) => n[0]).join(''),
                  style: const TextStyle(
                    color: IslamicColors.green700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(_buildRoleBadge(user.role)),
        DataCell(Text(user.country)),
        DataCell(Text(user.language)),
        DataCell(Text(_formatDate(user.joinedAt))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Questions: ${user.questionsAsked}',
                style: const TextStyle(fontSize: 12),
              ),
              if (user.questionsAnswered != null)
                Text(
                  'Answers: ${user.questionsAnswered}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              if (user.rating != null)
                Text(
                  'Rating: ${user.rating}/5',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
            ],
          ),
        ),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                  if (user.role == 'user')
                    const PopupMenuItem(
                      value: 'upgrade',
                      child: Text('Upgrade to Volunteer'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete User',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
          ),
        ),
      ],
    );
  }

  DataRow _buildVolunteerRow(User user) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green[100],
                child: Text(
                  user.displayName.split(' ').map((n) => n[0]).join(''),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(user.country)),
        DataCell(Text(user.language)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.yellow),
              const SizedBox(width: 4),
              Text('${user.rating}/5'),
            ],
          ),
        ),
        DataCell(Text('${user.questionsAnswered}')),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Volunteer'),
                  ),
                ],
          ),
        ),
      ],
    );
  }

  DataRow _buildApplicationRow(VolunteerApplication app) {
    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                app.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                app.email,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        DataCell(Text(app.country)),
        DataCell(Text(app.languages.join(', '))),
        DataCell(_buildStatusBadge(app.status)),
        DataCell(Text(_formatDate(app.appliedAt))),
        DataCell(
          ElevatedButton(
            onPressed: () => _reviewApplication(app),
            style: ElevatedButton.styleFrom(
              backgroundColor: IslamicColors.green600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Review', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (role) {
      case 'user':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'User';
        break;
      case 'certified_volunteer':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Volunteer';
        break;
      case 'admin':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Admin';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.yellow[100]!;
        textColor = Colors.yellow[800]!;
        break;
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.capitalize(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<User> _getFilteredUsers() {
    return users.where((user) {
      final matchesSearch =
          user.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'all' || user.role == _roleFilter;
      final matchesCountry =
          _countryFilter == 'all' || user.country == _countryFilter;
      final matchesLanguage =
          _languageFilter == 'all' || user.language == _languageFilter;

      return matchesSearch && matchesRole && matchesCountry && matchesLanguage;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'upgrade':
        _upgradeUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('User Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.displayName}'),
                Text('Email: ${user.email}'),
                Text('Role: ${user.role}'),
                Text('Country: ${user.country}'),
                Text('Language: ${user.language}'),
                Text('Joined: ${_formatDate(user.joinedAt)}'),
                Text('Questions Asked: ${user.questionsAsked}'),
                if (user.questionsAnswered != null)
                  Text('Questions Answered: ${user.questionsAnswered}'),
                if (user.rating != null) Text('Rating: ${user.rating}/5'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _editUser(User user) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${user.displayName}')));
  }

  void _upgradeUser(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upgraded ${user.displayName} to volunteer')),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete ${user.displayName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${user.displayName}')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _reviewApplication(VolunteerApplication app) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Review Application'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${app.name}'),
                Text('Email: ${app.email}'),
                Text('Country: ${app.country}'),
                Text('Languages: ${app.languages.join(', ')}'),
                const SizedBox(height: 8),
                Text('Bio: ${app.bio}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rejected ${app.name}\'s application'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Reject',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Approved ${app.name}\'s application'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: IslamicColors.green600,
                ),
                child: const Text(
                  'Approve',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
