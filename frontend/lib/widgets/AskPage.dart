// lib/pages/ask_page.dart
import 'package:flutter/material.dart';

class AskPage extends StatefulWidget {
  @override
  _AskPageState createState() => _AskPageState();
}

class _AskPageState extends State {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  String _selectedCategory = '';
  bool _isUrgent = false;

  final List_categories = [
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
    },
    {
      'id': 2,
      'question': 'Can I pray while traveling?',
      'category': 'Prayer',
      'askedBy': 'Brother Omar',
      'timeAgo': '4 hours ago',
      'answered': true,
      'answers': 2,
    },
    {
      'id': 3,
      'question': 'What are the etiquettes of visiting a mosque?',
      'category': 'Etiquette',
      'askedBy': 'Sister Fatima',
      'timeAgo': '6 hours ago',
      'answered': false,
      'answers': 0,
    },
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _submitQuestion() {
    if (_formKey.currentState!.validate()) {
      // Handle question submission
      print('Question: ${_questionController.text}');
      print('Category: $_selectedCategory');
      print('Urgent: $_isUrgent');

      // Reset form
      _questionController.clear();
      setState(() {
        _selectedCategory = '';
        _isUrgent = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question submitted successfully!'),
          backgroundColor: Color(0xFF2D8662),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  'Ask Your Question',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF104C34),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Get guidance from certified Islamic scholars and volunteers',
                  style: TextStyle(color: Color(0xFF206F4F)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Submit Question Form
          Card(
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
                      Icon(
                        Icons.help_outline,
                        color: Color(0xFF104C34),
                        size: 20,
                      ),
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

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Selection
                        Text(
                          'Category',
                          style: TextStyle(
                            color: Color(0xFF165A3F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField(
                          value:
                              _selectedCategory.isEmpty
                                  ? null
                                  : _selectedCategory,
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
                              borderSide: BorderSide(
                                color: Color(0xFF2D8662),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items:
                              List_categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
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
                        SizedBox(height: 20),

                        // Question Text
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
                              borderSide: BorderSide(
                                color: Color(0xFF2D8662),
                                width: 2,
                              ),
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
                        SizedBox(height: 20),

                        // Urgency Checkbox
                        Row(
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
                                style: TextStyle(color: Color(0xFF165A3F)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _selectedCategory.isNotEmpty &&
                                        _questionController.text
                                            .trim()
                                            .isNotEmpty
                                    ? _submitQuestion
                                    : null,
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Guidelines
          Card(
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
          ),

          SizedBox(height: 24),

          // Recent Questions
          Card(
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
                      Icon(
                        Icons.question_answer,
                        color: Color(0xFF104C34),
                        size: 20,
                      ),
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
                      .map(
                        (question) => Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF4FBF8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFFE6F3ED)),
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
                                        color: Color(0xFF104C34),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    question['answered']
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    color:
                                        question['answered']
                                            ? Color(0xFF206F4F)
                                            : Color(0xFFD4A574),
                                    size: 20,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFBFE3D5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.tag,
                                          size: 12,
                                          color: Color(0xFF165A3F),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          question['category'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF165A3F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 12,
                                        color: Color(0xFF206F4F),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        question['askedBy'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF206F4F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Color(0xFF206F4F),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        question['timeAgo'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF206F4F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${question['answers']} ${question['answers'] == 1 ? 'answer' : 'answers'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF206F4F),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          question['answered']
                                              ? Color(0xFF2D8662)
                                              : Color(0xFFE8C181),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      question['answered']
                                          ? 'Answered'
                                          : 'Pending',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            question['answered']
                                                ? Colors.white
                                                : Color(0xFF7F7556),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
