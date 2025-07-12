import 'package:flutter/material.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config.dart';
import 'package:provider/provider.dart';
import '../utils/auth_utils.dart';

import '../constants/colors.dart';
import 'AIResponseCard.dart';
import '../providers/UserProvider.dart';

class QuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;

  const QuestionCard({Key? key, required this.question}) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool isSaved = false;
  bool isSaving = false;
  // Add state variables for hover and click effects
  bool isHovered = false;
  bool isPressed = false;
  // Add state for showing all answers
  bool showAllAnswers = false;
  List<Map<String, dynamic>> allAnswers = [];
  bool isLoadingAnswers = false;
  String? upvotedAnswerId; // Track which answer is upvoted by the user
  bool isUpvoting = false;

  // Add state variables for answer form
  bool showAnswerForm = false;
  bool isSubmittingAnswer = false;
  final TextEditingController _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still mounted
      //Todo : make sure saved questions icon is filled with color
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final savedQuestions =
          userProvider
              .savedQuestions; // Adjust this if your property is named differently
      if (savedQuestions.contains(widget.question['questionId'])) {
        setState(() {
          isSaved = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> saveQuestion() async {
    setState(() {
      isSaving = true;
    });

    final questionId = widget.question['questionId']; // assuming there's an ID
    final url = Uri.parse(saveQuestionUrl);

    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        // User was logged out due to expired token
        setState(() {
          isSaving = false;
        });
        return;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'questionId': questionId}),
      );

      //Todo: make sure the endpoint is working
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            isSaved = true;
          });

          // Add the saved question to savedQuestion array in the user provider
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.toggleSavedQuestion(widget.question["questionId"]);
        } else {
          // handle failure
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save question')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  // Function to handle "Show all answers" button click
  Future<void> _handleShowAllAnswers() async {
    if (showAllAnswers) {
      // Collapse answers
      setState(() {
        showAllAnswers = false;
        allAnswers.clear();
      });
    } else {
      // Show answers
      setState(() {
        showAllAnswers = true;
        isLoadingAnswers = true;
      });

      // Fetch answers from API
      await _fetchAllAnswers();
    }
  }

  // Function to fetch all answers for the question
  Future<void> _fetchAllAnswers() async {
    setState(() {
      allAnswers = _getMockAnswers();
      isLoadingAnswers = false;
    });
    return;
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        setState(() {
          isLoadingAnswers = false;
        });
        return;
      }

      final questionId = widget.question['questionId'];
      final apiUrl = Uri.parse('$questions/$questionId');

      final response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      //Todo: check the response as expected
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          allAnswers = List<Map<String, dynamic>>.from(data['answers'] ?? []);
          isLoadingAnswers = false;
        });
      } else {
        // If API call fails, show mock data for demonstration
        setState(() {
          allAnswers = _getMockAnswers();
          isLoadingAnswers = false;
        });
      }
    } catch (e) {
      // Show mock data if there's an error
      setState(() {
        allAnswers = _getMockAnswers();
        isLoadingAnswers = false;
      });
    }
  }

  // Mock data for demonstration purposes
  List<Map<String, dynamic>> _getMockAnswers() {
    return [
      {
        'id': '1',
        'text':
            'This is a detailed answer from a certified volunteer explaining the Islamic perspective on this matter.',
        'answeredBy': {'displayName': 'Ahmed Hassan'},
        'upvotesCount': 15,
        'createdAt': '2024-01-15T10:30:00Z',
      },
      {
        'id': '2',
        'text':
            'Another comprehensive answer providing additional insights and references from Islamic scholars.',
        'answeredBy': {'displayName': 'Fatima Ali'},
        'upvotesCount': 8,
        'createdAt': '2024-01-15T11:45:00Z',
      },
      {
        'id': '3',
        'text':
            'A third answer offering a different perspective on the same question.',
        'answeredBy': {'displayName': 'Omar Khalil'},
        'upvotesCount': 12,
        'createdAt': '2024-01-15T14:20:00Z',
      },
    ];
  }

  // Function to handle upvoting an answer
  Future<void> _handleUpvote(String answerId) async {
    //Todo: make sure volunteer can upvote one answer only
    if (isUpvoting || upvotedAnswerId == answerId) return;
    setState(() {
      isUpvoting = true;
    });
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        setState(() {
          isUpvoting = false;
        });
        return;
      }
      final apiUrl = Uri.parse('$answers/$answerId/upvote');
      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          upvotedAnswerId = answerId;
          // Optionally update the upvotes count in allAnswers
          for (var ans in allAnswers) {
            if (ans['id'] == answerId) {
              ans['upvotesCount'] = (ans['upvotesCount'] ?? 0) + 1;
            }
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upvote answer')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isUpvoting = false;
      });
    }
  }

  // Function to handle submitting an answer
  Future<void> _handleSubmitAnswer() async {
    //Todo: make sure the submit request is linked correctly
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmittingAnswer = true;
    });

    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        setState(() {
          isSubmittingAnswer = false;
        });
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      final language = user?['language'] ?? 'English';

      final response = await http.post(
        Uri.parse(submitAnswerUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'questionId': widget.question['questionId'],
          'text': _answerController.text.trim(),
          'language': language,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Clear the form and hide it
          _answerController.clear();
          setState(() {
            showAnswerForm = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Answer submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh the answers list if it's currently shown
          if (showAllAnswers) {
            await _fetchAllAnswers();
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to submit answer')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isSubmittingAnswer = false;
      });
    }
  }

  // Function to toggle answer form visibility
  void _toggleAnswerForm() {
    setState(() {
      showAnswerForm = !showAnswerForm;
      if (!showAnswerForm) {
        _answerController.clear();
      }
    });
  }

  // Helper function to check if current user is a certified volunteer
  bool _isCertifiedVolunteer() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return user != null && user['role'] == 'certified_volunteer';
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  (question['isPublic'] ?? true)
                      ? AppColors.askPageBackground
                      : AppColors.askPagePrivateBackground,
              border: Border.all(
                color:
                    (question['isPublic'] ?? true)
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
                        question['text']?.toString() ?? 'No question text',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.askPageTitle,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          (question['isPublic'] ?? true)
                              ? Icons.lock_open
                              : Icons.lock,
                          size: 16,
                          color:
                              (question['isPublic'] ?? true)
                                  ? AppColors.askPageSubtitle
                                  : AppColors.askPagePrivateIcon,
                        ),
                        SizedBox(width: 4),
                        _buildResponseTypeIcon(
                          question['responseType']?.toString(),
                        ),
                        SizedBox(width: 4),

                        /// 🔽 Save Icon Button
                        MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => isPressed = true),
                            onTapUp: (_) => setState(() => isPressed = false),
                            onTapCancel:
                                () => setState(() => isPressed = false),
                            onTap: isSaving || isSaved ? null : saveQuestion,
                            child: AnimatedScale(
                              scale:
                                  isPressed ? 0.85 : (isHovered ? 1.15 : 1.0),
                              duration: Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20,
                                color:
                                    isSaved
                                        ? Colors.green
                                        : (isHovered
                                            ? Colors.blue
                                            : AppColors.askPageSubtitle),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _buildCategoryChip(question['category']?.toString()),
                    _buildInfoChip(
                      Icons.person,
                      (question['askedBy'] is Map &&
                              question['askedBy']['displayName'] != null)
                          ? question['askedBy']['displayName'].toString()
                          : (question['askedBy']?.toString() ?? ''),
                    ),
                    _buildInfoChip(
                      Icons.access_time,
                      question['timeAgo']?.toString(),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${question['answers'] as int} ${question['answers'] == 1 ? 'answer' : 'answers'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.askPageSubtitle,
                          ),
                        ),
                        SizedBox(width: 12),
                        _buildPrivacyChip(question['isPublic'] ?? true),
                      ],
                    ),
                    _buildResponseBadge(question['responseType']?.toString()),
                  ],
                ),
                // Show "Show/Hide all answers" button for certified volunteers
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    spacing: 5,
                    children: [
                      if (_isCertifiedVolunteer() &&
                          question['responseType'] == 'ai')
                      //Todo:change ai to 'human'
                      ...[
                        SizedBox(height: 16),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: _handleShowAllAnswers,
                            icon: Icon(
                              showAllAnswers
                                  ? Icons.visibility_off
                                  : Icons.list_alt,
                              size: 16,
                            ),
                            label: Text(
                              showAllAnswers
                                  ? 'Hide all answers'
                                  : 'Show all answers',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.islamicGreen500,
                              side: BorderSide(
                                color: AppColors.islamicGreen500,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Show "Answer Question" button for certified volunteers
                      if (_isCertifiedVolunteer()) ...[
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _toggleAnswerForm,
                            icon: Icon(
                              showAnswerForm ? Icons.close : Icons.edit,
                              size: 16,
                            ),
                            label: Text(
                              showAnswerForm ? 'Cancel' : 'Answer Question',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.islamicGreen500,
                              foregroundColor: AppColors.islamicWhite,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Show all answers in scrollable container
          if (showAllAnswers)
            Container(
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.askPageBackground,
                border: Border.all(color: AppColors.askPageBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.islamicGreen50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  // Answers list
                  Container(
                    constraints: BoxConstraints(maxHeight: 400),
                    child:
                        isLoadingAnswers
                            ? Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.islamicGreen500,
                                ),
                              ),
                            )
                            : allAnswers.isEmpty
                            ? Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No answers available',
                                  style: TextStyle(
                                    color: AppColors.askPageSubtitle,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: allAnswers.length,
                              itemBuilder: (context, index) {
                                final answer = allAnswers[index];
                                return _buildAnswerCard(answer);
                              },
                            ),
                  ),
                ],
              ),
            ),

          // Answer form for certified volunteers
          if (showAnswerForm && _isCertifiedVolunteer())
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.askPageBackground,
                border: Border.all(color: AppColors.askPageBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.islamicGreen500,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Your Answer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.askPageTitle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _answerController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write your answer here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.askPageBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.islamicGreen500,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your answer';
                        }
                        if (value.trim().length < 10) {
                          return 'Answer must be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _toggleAnswerForm,
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.askPageSubtitle),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed:
                              isSubmittingAnswer ? null : _handleSubmitAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.islamicGreen500,
                            foregroundColor: AppColors.islamicWhite,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              isSubmittingAnswer
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.islamicWhite,
                                      ),
                                    ),
                                  )
                                  : Text('Submit Answer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          if (question['responseType'] == 'ai' &&
              ((question['aiAnswer'] != null &&
                      question['aiAnswer'].toString().isNotEmpty) ||
                  (question['aiResponse'] != null &&
                      question['aiResponse'].toString().isNotEmpty)))
            AIResponseCard(
              aiAnswer:
                  question['aiAnswer']?.toString() ??
                  question['aiResponse']?.toString() ??
                  '',
            ),

          // Display top answer for human-answered questions
          if (question['responseType'] == 'human' &&
              question['topAnswer'] != null)
            _buildTopAnswerCard(question['topAnswer']),
        ],
      ),
    );
  }

  Widget _buildResponseTypeIcon(String? responseType) {
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

  Widget _buildCategoryChip(String? category) {
    if (category == null) return SizedBox.shrink();
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

  Widget _buildInfoChip(IconData icon, String? text) {
    if (text == null) return SizedBox.shrink();
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

  Widget _buildResponseBadge(String? responseType) {
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

  // Helper function to extract display name from answeredBy object
  String _getAnswererDisplayName(Map<String, dynamic>? answeredBy) {
    if (answeredBy == null) return '';
    if (answeredBy is Map) {
      return answeredBy['displayName']?.toString() ?? '';
    }
    return answeredBy.toString();
  }

  // Widget to display top answer
  Widget _buildTopAnswerCard(Map<String, dynamic> topAnswer) {
    final answeredBy = topAnswer['answeredBy'];
    final answerText = topAnswer['text']?.toString() ?? '';
    final upvotesCount = topAnswer['upvotesCount']?.toString() ?? '0';
    final answererName = _getAnswererDisplayName(answeredBy);

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.askPageBackground,
        border: Border.all(color: AppColors.askPageBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Answerer info row
          Row(
            children: [
              Icon(Icons.verified_user, size: 16, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                answererName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.askPageTitle,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.verified, size: 12, color: Colors.blue),
              Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 12,
                    color: AppColors.askPageSubtitle,
                  ),
                  SizedBox(width: 4),
                  Text(
                    upvotesCount,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.askPageSubtitle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          // Answer text
          Text(
            answerText,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.askPageTitle,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display individual answer in the scrollable list
  Widget _buildAnswerCard(Map<String, dynamic> answer) {
    final answeredBy = answer['answeredBy'];
    final answerText = answer['text']?.toString() ?? '';
    final upvotesCount = answer['upvotesCount']?.toString() ?? '0';
    final answererName = _getAnswererDisplayName(answeredBy);
    final createdAt = answer['createdAt']?.toString() ?? '';
    final answerId = answer['id']?.toString() ?? '';
    final isCertified = _isCertifiedVolunteer();
    final isUpvoted = upvotedAnswerId == answerId;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.askPageBorder.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Answerer info row
          Row(
            children: [
              Icon(
                Icons.verified_user,
                size: 16,
                color: AppColors.islamicGreen500,
              ),
              SizedBox(width: 4),
              Text(
                answererName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.askPageTitle,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.verified, size: 12, color: AppColors.islamicGreen500),
              Spacer(),
              // Upvote icon for certified volunteers
              if (isCertified)
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: isUpvoted ? Colors.green : AppColors.askPageSubtitle,
                  ),
                  tooltip: isUpvoted ? 'Upvoted' : 'Upvote',
                  onPressed:
                      (upvotedAnswerId == null || isUpvoted)
                          ? () => _handleUpvote(answerId)
                          : null,
                ),
              Row(
                children: [
                  Text(
                    upvotesCount,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.askPageSubtitle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          // Answer text
          Text(
            answerText,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.askPageTitle,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          // Timestamp
          if (createdAt.isNotEmpty)
            Text(
              'Answered on ${_formatDate(createdAt)}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.askPageSubtitle,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // Helper function to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
