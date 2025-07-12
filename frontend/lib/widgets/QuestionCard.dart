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

  @override
  void initState() {
    print("displaying the question : ${widget.question}");
    super.initState();
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still mounted
      //Todo : make sure saved questions icon is filled with color
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final savedQuestions =
          userProvider
              .savedQuestions; // Adjust this if your property is named differently
      print("is question saved $savedQuestions");
      if (savedQuestions.contains(widget.question['questionId'])) {
        setState(() {
          isSaved = true;
        });
      }
    });
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
                /// 🔽 Modified Row to include Save Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        question['text']?.toString() ?? 'No question text',
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
              ],
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
}
