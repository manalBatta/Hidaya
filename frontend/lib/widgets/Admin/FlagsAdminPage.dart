import 'package:flutter/material.dart';

class FlagData {
  final String flagId;
  final String itemId;
  final String itemType; // "question" or "answer"
  final String reportedBy;
  final String reason;
  final String status; // "pending", "resolved", "dismissed"
  final DateTime createdAt;
  final String? itemContent;
  final String? itemAuthor;

  FlagData({
    required this.flagId,
    required this.itemId,
    required this.itemType,
    required this.reportedBy,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.itemContent,
    this.itemAuthor,
  });
}

class FlagsAdminPage extends StatefulWidget {
  const FlagsAdminPage({Key? key}) : super(key: key);

  @override
  State<FlagsAdminPage> createState() => _FlagsAdminPageState();
}

class _FlagsAdminPageState extends State<FlagsAdminPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  FlagData? _selectedFlag;

  // Islamic Color Palette - Exact match from design
  static const Color islamicGreen50 = Color(0xFFF4FBF7);
  static const Color islamicGreen100 = Color(0xFFE6F4ED);
  static const Color islamicGreen200 = Color(0xFFCCE8D8);
  static const Color islamicGreen300 = Color(0xFFB3DCC3);
  static const Color islamicGreen400 = Color(0xFF7AC09A);
  static const Color islamicGreen500 = Color(0xFF2D7A47);
  static const Color islamicGreen600 = Color(0xFF235831);
  static const Color islamicGreen700 = Color(0xFF1A4025);
  static const Color islamicGreen800 = Color(0xFF142E1C);
  static const Color islamicGreen900 = Color(0xFF0C1C12);
  static const Color islamicCream = Color(0xFFFDF8F0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock data for flags
  final List<FlagData> _flags = [
    FlagData(
      flagId: "FLAG001",
      itemId: "Q123",
      itemType: "question",
      reportedBy: "user@example.com",
      reason:
          "This question contains inappropriate language and offensive content that violates community guidelines.",
      status: "pending",
      createdAt: DateTime.parse("2024-06-20T10:30:00Z"),
      itemContent:
          "Is music haram in Islam? Some people say it's forbidden but I listen to music all the time.",
      itemAuthor: "Omar Khan",
    ),
    FlagData(
      flagId: "FLAG002",
      itemId: "Q124",
      itemType: "question",
      reportedBy: "moderator@hidaya.com",
      reason:
          "Spam content - same question posted multiple times by the same user.",
      status: "resolved",
      createdAt: DateTime.parse("2024-06-19T15:45:00Z"),
      itemContent: "How to perform wudu correctly?",
      itemAuthor: "Ahmad Hassan",
    ),
    FlagData(
      flagId: "FLAG003",
      itemId: "Q125",
      itemType: "question",
      reportedBy: "volunteer@hidaya.com",
      reason:
          "Question contains misinformation about Islamic practices that could mislead users.",
      status: "pending",
      createdAt: DateTime.parse("2024-06-18T20:15:00Z"),
      itemContent: "Can I pray while listening to music?",
      itemAuthor: "Fatima Al-Zahra",
    ),
    FlagData(
      flagId: "FLAG004",
      itemId: "A001",
      itemType: "answer",
      reportedBy: "user2@example.com",
      reason:
          "Answer provides incorrect religious guidance that contradicts established Islamic teachings.",
      status: "pending",
      createdAt: DateTime.parse("2024-06-17T09:20:00Z"),
      itemContent:
          "Yes, you can pray while listening to music, it's completely fine and doesn't affect your prayer.",
      itemAuthor: "Unknown Volunteer",
    ),
    FlagData(
      flagId: "FLAG005",
      itemId: "A002",
      itemType: "answer",
      reportedBy: "imam@mosque.org",
      reason:
          "Answer contains hate speech and discriminatory language against certain groups.",
      status: "resolved",
      createdAt: DateTime.parse("2024-06-16T14:10:00Z"),
      itemContent: "The correct way to perform ablution is...",
      itemAuthor: "Certified Imam",
    ),
    FlagData(
      flagId: "FLAG006",
      itemId: "A003",
      itemType: "answer",
      reportedBy: "admin@hidaya.com",
      reason:
          "Plagiarized content copied from external sources without attribution.",
      status: "dismissed",
      createdAt: DateTime.parse("2024-06-15T11:30:00Z"),
      itemContent: "Prayer times vary by location and season...",
      itemAuthor: "Scholar Ahmad",
    ),
  ];

  List<FlagData> get _filteredFlags {
    final currentType = _tabController.index == 0 ? "question" : "answer";
    return _flags.where((flag) {
      final matchesType = flag.itemType == currentType;
      final matchesSearch =
          flag.flagId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          flag.itemId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          flag.reportedBy.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          flag.reason.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == 'All Status' ||
          flag.status == _selectedStatus.toLowerCase();
      return matchesType && matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: islamicCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flags / Reports',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: islamicGreen800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review and moderate user-reported content',
                        style: TextStyle(fontSize: 16, color: islamicGreen600),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: const Text('View Analytics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: islamicGreen600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tab Navigation
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabButton(
                      'Questions (${_flags.where((f) => f.itemType == "question").length})',
                      0,
                    ),
                    _buildTabButton(
                      'Answers (${_flags.where((f) => f.itemType == "answer").length})',
                      1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsCards(),
              const SizedBox(height: 24),

              // Content Card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Section Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _tabController.index == 0
                                  ? 'Question Flags'
                                  : 'Answer Flags',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: islamicGreen800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search and Filters
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: _buildSearchAndFilters(),
                      ),

                      // Results Info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Showing 1 to ${_filteredFlags.length} of ${_filteredFlags.length} results',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: _buildTableHeader(),
                      ),

                      // Table Content
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredFlags.length,
                          itemBuilder: (context, index) {
                            return _buildFlagRow(_filteredFlags[index], index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tabController.index = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? islamicGreen600 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = [
      {
        'title': 'Total Flags',
        'value': _flags.length.toString(),
        'icon': Icons.flag_outlined,
        'color': Colors.red,
      },
      {
        'title': 'Pending',
        'value': _flags.where((f) => f.status == "pending").length.toString(),
        'icon': Icons.access_time,
        'color': Colors.orange,
      },
      {
        'title': 'Resolved',
        'value': _flags.where((f) => f.status == "resolved").length.toString(),
        'icon': Icons.shield_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Dismissed',
        'value': _flags.where((f) => f.status == "dismissed").length.toString(),
        'icon': Icons.warning_outlined,
        'color': Colors.grey,
      },
    ];

    return Row(
      children:
          stats.asMap().entries.map((entry) {
            final stat = entry.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: entry.key < stats.length - 1 ? 16 : 0,
                ),
                child: _buildStatCard(stat),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(stat['icon'], size: 32, color: stat['color']),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: islamicGreen800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText:
                  _tabController.index == 0
                      ? 'Search questions flags...'
                      : 'Search answers flags...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: islamicGreen600),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Status Filter
        _buildFilterButton('All Status', Icons.filter_list),
      ],
    );
  }

  Widget _buildFilterButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildHeaderCell('Flag ID')),
        Expanded(flex: 2, child: _buildHeaderCell('Item ID')),
        Expanded(flex: 3, child: _buildHeaderCell('Reported By')),
        Expanded(flex: 4, child: _buildHeaderCell('Reason')),
        Expanded(flex: 2, child: _buildHeaderCell('Status')),
        Expanded(flex: 2, child: _buildHeaderCell('Created At')),
        const SizedBox(width: 40), // Actions column
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFlagRow(FlagData flag, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : const Color(0xFFFAFAFA),
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: InkWell(
        onTap: () => _showFlagDetails(flag),
        child: Row(
          children: [
            // Flag ID Column
            Expanded(
              flex: 2,
              child: Text(
                flag.flagId,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Item ID Column
            Expanded(
              flex: 2,
              child: Text(
                flag.itemId,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),

            // Reported By Column
            Expanded(
              flex: 3,
              child: Text(
                flag.reportedBy,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Reason Column
            Expanded(
              flex: 4,
              child: Text(
                flag.reason,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Status Column
            Expanded(flex: 2, child: _buildStatusBadge(flag.status)),

            // Created At Column
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(flag.createdAt),
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) => _handleFlagAction(value, flag),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(
                      value: 'resolve',
                      child: Text('Approve Resolution'),
                    ),
                    const PopupMenuItem(
                      value: 'dismiss',
                      child: Text('Dismiss Flag'),
                    ),
                  ],
              child: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String displayText;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        displayText = 'pending';
        break;
      case 'resolved':
        color = Colors.green;
        displayText = 'resolved';
        break;
      case 'dismissed':
        color = Colors.red;
        displayText = 'dismissed';
        break;
      default:
        color = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleFlagAction(String action, FlagData flag) {
    switch (action) {
      case 'view':
        _showFlagDetails(flag);
        break;
      case 'resolve':
        _showSnackbar('Flag ${flag.flagId} has been marked as resolved.');
        break;
      case 'dismiss':
        _showSnackbar('Flag ${flag.flagId} has been dismissed.');
        break;
    }
  }

  void _showFlagDetails(FlagData flag) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 800,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Flag Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Flag Information
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Flag Information',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: islamicGreen800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                            'Flag ID:',
                                            flag.flagId,
                                          ),
                                          _buildDetailRow(
                                            'Item ID:',
                                            flag.itemId,
                                          ),
                                          _buildDetailRow(
                                            'Item Type:',
                                            flag.itemType,
                                          ),
                                          _buildDetailRow(
                                            'Status:',
                                            flag.status,
                                          ),
                                          _buildDetailRow(
                                            'Reported By:',
                                            flag.reportedBy,
                                          ),
                                          _buildDetailRow(
                                            'Created:',
                                            _formatDateTime(flag.createdAt),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Flagged Content',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: islamicGreen800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                            'Author:',
                                            flag.itemAuthor ?? 'Unknown',
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Content:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: const Color(0xFFE5E7EB),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              flag.itemContent ??
                                                  'No content available',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Report Reason
                          Text(
                            'Report Reason',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: islamicGreen800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              flag.reason,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSnackbar(
                                    'Flag ${flag.flagId} has been marked as resolved.',
                                  );
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Resolve Flag'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSnackbar(
                                    'Flag ${flag.flagId} has been dismissed.',
                                  );
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Dismiss Flag'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSnackbar(
                                    'Content ${flag.itemId} has been removed and flag resolved.',
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Remove Content'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: islamicGreen600),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
