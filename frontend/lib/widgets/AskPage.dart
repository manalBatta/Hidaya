// lib/pages/ask_page.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AskPage extends StatefulWidget {
  @override
  _AskPageState createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;

  String _selectedCategory = '';
  bool _isUrgent = false;
  bool _isPublic = true;
  bool _showSuccessMessage = false;

  final List<String> _categories = [
    'Worship',
    'Prayer',
    'Fasting',
    'Hajj & Umrah',
    'Islamic Finance',
    'Family & Marriage',
    'Daily Life',
    'Quran & Sunnah',
    'Islamic History',
    'Etiquette',
    'Other',
  ];

  final List<Map<String, dynamic>> _recentQuestions = [
    {
      'id': 1,
      'question': 'What is the correct way to perform Wudu?',
      'category': 'Worship',
      'askedBy': 'Sister Aisha',
      'timeAgo': '2 hours ago',
      'answered': true,
      'answers': 3,
      'isPublic': true,
      'responseType': 'human',
      'aiResponse': null,
    },
    {
      'id': 2,
      'question': 'Can I pray while traveling?',
      'category': 'Prayer',
      'askedBy': 'Brother Omar',
      'timeAgo': '4 hours ago',
      'answered': true,
      'answers': 1,
      'isPublic': true,
      'responseType': 'ai',
      'aiResponse':
          'Yes, you can pray while traveling. Islam provides accommodations for travelers including shortening prayers (Qasr) and combining certain prayers. The Quran mentions this in verse 4:101. However, it\'s recommended to seek guidance from a certified scholar for your specific travel circumstances.',
    },
    {
      'id': 3,
      'question': 'What are the etiquettes of visiting a mosque?',
      'category': 'Etiquette',
      'askedBy': 'Sister Fatima',
      'timeAgo': '6 hours ago',
      'answered': false,
      'answers': 0,
      'isPublic': true,
      'responseType': 'none',
      'aiResponse': null,
    },
    {
      'id': 4,
      'question': 'Personal family guidance needed',
      'category': 'Family & Marriage',
      'askedBy': 'Anonymous',
      'timeAgo': '8 hours ago',
      'answered': true,
      'answers': 1,
      'isPublic': false,
      'responseType': 'human',
      'aiResponse': null,
    },
    {
      'id': 5,
      'question':
          'How should I handle conflicts with Islamic principles at work?',
      'category': 'Daily Life',
      'askedBy': 'Brother Ahmed',
      'timeAgo': '1 day ago',
      'answered': true,
      'answers': 0,
      'isPublic': true,
      'responseType': 'ai',
      'aiResponse':
          'Balancing Islamic principles with workplace requirements can be challenging. The key is open communication with your employer about your religious needs, seeking halal alternatives when possible, and consulting with Islamic scholars for guidance on specific situations. Remember that Islam emphasizes both fulfilling your obligations and maintaining your faith.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _successAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _successAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _submitQuestion() {
    if (_formKey.currentState!.validate() && _selectedCategory.isNotEmpty) {
      print('Question submitted: ${_questionController.text}');
      print('Category: $_selectedCategory');
      print('Urgent: $_isUrgent');
      print('Public: $_isPublic');

      // Reset form
      _questionController.clear();
      setState(() {
        _selectedCategory = '';
        _isUrgent = false;
        _isPublic = true;
        _showSuccessMessage = true;
      });

      // Animate success message
      _successAnimationController.forward();

      // Hide success message after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessMessage = false;
          });
          _successAnimationController.reset();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: 24),

          // Submit Question Form
          _buildSubmissionForm(),
          SizedBox(height: 24),

          // Guidelines
          _buildGuidelines(),
          SizedBox(height: 24),

          // Recent Questions
          _buildRecentQuestions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            'Ask Your Question',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.askPageTitle,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Get guidance from certified Islamic scholars and volunteers',
            style: TextStyle(color: AppColors.askPageSubtitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFBFE3D5)),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.help_outline, color: Color(0xFF104C34), size: 20),
                SizedBox(width: 8),
                Text(
                  'Submit Your Question',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF104C34),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Success Message
            if (_showSuccessMessage)
              AnimatedBuilder(
                animation: _successAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _successAnimation.value,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4FBF8),
                        border: Border.all(color: Color(0xFFBFE3D5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.askPageSubtitle,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Question submitted successfully!',
                            style: TextStyle(
                              color: Color(0xFF104C34),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Public/Private Toggle
                  _buildVisibilityToggle(),
                  SizedBox(height: 20),

                  // Category Selection
                  _buildCategoryDropdown(),
                  SizedBox(height: 20),

                  // Question Input
                  _buildQuestionInput(),
                  SizedBox(height: 20),

                  // Urgency Checkbox
                  _buildUrgencyCheckbox(),
                  SizedBox(height: 24),

                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Visibility',
          style: TextStyle(
            color: Color(0xFF165A3F),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF4FBF8),
            border: Border.all(color: Color(0xFFBFE3D5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _isPublic ? Icons.lock_open : Icons.lock,
                color: Color(0xFF206F4F),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPublic ? 'Public Question' : 'Private Question',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF104C34),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isPublic
                          ? 'Visible to the community and may receive AI responses'
                          : 'Only certified volunteers can view your question',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.askPageSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                activeColor: Color(0xFF2D8662),
              ),
            ],
          ),
        ),
        if (!_isPublic)
          Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFCF7E8),
              border: Border.all(color: Color(0xFFE8C181)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: Color(0xFFD4A574), size: 16),
                SizedBox(width: 8),
                Text(
                  'Only certified volunteers can view your question.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F7556),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: Color(0xFF165A3F),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select a category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2D8662), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items:
              _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuestionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Question',
          style: TextStyle(
            color: Color(0xFF165A3F),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _questionController,
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            hintText:
                'Please describe your question in detail. Include context if relevant.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFBFE3D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2D8662), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your question';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUrgencyCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isUrgent,
          onChanged: (value) {
            setState(() {
              _isUrgent = value ?? false;
            });
          },
          activeColor: Color(0xFF2D8662),
        ),
        Expanded(
          child: Text(
            'This is urgent and needs priority attention',
            style: TextStyle(color: AppColors.askPageUrgent),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    bool isValid =
        _selectedCategory.isNotEmpty &&
        _questionController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _submitQuestion : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2D8662),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 16),
            SizedBox(width: 8),
            Text(
              'Submit Question',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelines() {
    return Card(
      color: Color(0xFFFCF7E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFE8C181)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guidelines for Asking Questions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF104C34),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            ...[
                  'Be specific and clear in your question',
                  'Provide context if your situation is unique',
                  'Choose the most appropriate category',
                  'Be respectful and patient for responses',
                ]
                .map(
                  (guideline) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFF45A376),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            guideline,
                            style: TextStyle(
                              color: Color(0xFF165A3F),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentQuestions() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFBFE3D5)),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.question_answer, color: Color(0xFF104C34), size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Community Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF104C34),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            ..._recentQuestions
                .map((question) => _buildQuestionCard(question))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  question['isPublic']
                      ? AppColors.askPageBackground
                      : AppColors.askPagePrivateBackground,
              border: Border.all(
                color:
                    question['isPublic']
                        ? AppColors.askPageBorder
                        : AppColors.askPagePrivateBorder,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        question['question'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.askPageTitle,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          question['isPublic'] ? Icons.lock_open : Icons.lock,
                          size: 16,
                          color:
                              question['isPublic']
                                  ? AppColors.askPageSubtitle
                                  : AppColors.askPagePrivateIcon,
                        ),
                        SizedBox(width: 4),
                        _buildResponseTypeIcon(question['responseType']),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),

                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _buildCategoryChip(question['category']),
                    _buildInfoChip(Icons.person, question['askedBy']),
                    _buildInfoChip(Icons.access_time, question['timeAgo']),
                  ],
                ),
                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${question['answers']} ${question['answers'] == 1 ? 'answer' : 'answers'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.askPageSubtitle,
                          ),
                        ),
                        SizedBox(width: 12),
                        _buildPrivacyChip(question['isPublic']),
                      ],
                    ),
                    _buildResponseBadge(question['responseType']),
                  ],
                ),
              ],
            ),
          ),

          // AI Response Card
          if (question['responseType'] == 'ai' &&
              question['aiResponse'] != null)
            Container(
              margin: EdgeInsets.only(left: 16, top: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.askPageAIBackground,
                border: Border.all(color: AppColors.askPageAIBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.askPageAIBox,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.smart_toy,
                          size: 16,
                          color: AppColors.askPageAIBlue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI Response',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.askPageAIDarkBlue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.askPageAIBlue,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    question['aiResponse'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.askPageAIText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.askPageAIBox,
                      border: Border.all(color: AppColors.askPageAIBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'This response was generated by trusted AI and may be reviewed later by a volunteer.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.askPageAINote,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponseTypeIcon(String responseType) {
    switch (responseType) {
      case 'human':
        return Icon(
          Icons.verified_user,
          size: 20,
          color: AppColors.askPageSubtitle,
        );
      case 'ai':
        return Icon(Icons.smart_toy, size: 20, color: AppColors.askPageAIBlue);
      default:
        return Icon(
          Icons.access_time,
          size: 20,
          color: AppColors.askPagePrivateIcon,
        );
    }
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.askPageCategoryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag, size: 12, color: AppColors.askPageCategoryText),
          SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.askPageCategoryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.askPageSubtitle),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: AppColors.askPageSubtitle),
        ),
      ],
    );
  }

  Widget _buildPrivacyChip(bool isPublic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isPublic
                  ? AppColors.askPagePrivacyBorder
                  : AppColors.askPagePrivateBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPublic ? '🔓 Public' : '🔒 Private',
        style: TextStyle(
          fontSize: 10,
          color:
              isPublic
                  ? AppColors.askPageCategoryText
                  : AppColors.askPagePrivacyText,
        ),
      ),
    );
  }

  Widget _buildResponseBadge(String responseType) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (responseType) {
      case 'human':
        backgroundColor = AppColors.askPageHumanBadge;
        textColor = AppColors.islamicWhite;
        text = '✅ Human';
        break;
      case 'ai':
        backgroundColor = AppColors.askPageAIBox;
        textColor = AppColors.askPageAIText;
        text = '🤖 AI';
        break;
      default:
        backgroundColor = AppColors.askPagePrivateBorder;
        textColor = AppColors.askPagePrivacyText;
        text = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
