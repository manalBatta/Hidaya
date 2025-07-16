import 'package:flutter/material.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config.dart';
import 'package:provider/provider.dart';
import '../utils/auth_utils.dart';

import '../constants/colors.dart';
import 'AIResponseCard.dart';
import '../widgets/Qustions.dart' as questions_util;

class QuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final VoidCallback? onRefresh;
  final void Function(Map<String, dynamic> updatedFields)? onUpdate;

  const QuestionCard({Key? key, required this.question, this.onRefresh, this.onUpdate})
    : super(key: key);

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

  // Responsive sizing helper methods
  double _getResponsiveFontSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return baseSize * 1.2; // Large screens (desktop)
    } else if (screenWidth >= 768) {
      return baseSize * 1.1; // Medium screens (tablet)
    } else {
      return baseSize; // Small screens (mobile)
    }
  }

  double _getResponsiveIconSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return baseSize * 1.3; // Large screens (desktop)
    } else if (screenWidth >= 768) {
      return baseSize * 1.15; // Medium screens (tablet)
    } else {
      return baseSize; // Small screens (mobile)
    }
  }

  double _getResponsivePadding(double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return basePadding * 1.25; // Large screens (desktop)
    } else if (screenWidth >= 768) {
      return basePadding * 1.1; // Medium screens (tablet)
    } else {
      return basePadding; // Small screens (mobile)
    }
  }

   bool hasHummanAnswer(Map<String, dynamic> question){
     final topAnswerId = question['topAnswerId'];
     print("topAnswerId by ruba : $topAnswerId");
  return topAnswerId != null && topAnswerId.toString().trim().isNotEmpty;
  }
  
  //By Ruby 
  
   







  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still mounted
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final savedQuestions = userProvider.savedQuestions;
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

  //Done deep checking
  Future<void> saveQuestion() async {
    print("calling saveQuestion");
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

      print("save question response is :${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Add or remove the saved question in the user provider
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.toggleSavedQuestion(widget.question["questionId"]);

          // Check if the question is now saved or unsaved
          final savedQuestions = userProvider.savedQuestions;
          setState(() {
            isSaved = savedQuestions.contains(widget.question["questionId"]);
          });
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

  // Add this function for confirmation dialog
  Future<bool> _showChangeVoteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Change your vote?',
                  style: TextStyle(color: AppColors.askPageTitle),
                ),
                content: Text(
                  'You have already upvoted another answer. Are you sure you want to change your vote to this answer?',
                  style: TextStyle(color: AppColors.askPageSubtitle),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.askPageSubtitle),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.islamicGreen500,
                      foregroundColor: AppColors.islamicWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Yes, change vote'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Function to fetch all answers for the question
  Future<void> _fetchAllAnswers() async {
    setState(() {
      isLoadingAnswers = true;
    });
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final answers = List<Map<String, dynamic>>.from(
            data['answers'] ?? [],
          );

          // Sort answers by upvotesCount descending
          answers.sort((a, b) {
            final aUpvotes =
                int.tryParse(a['upvotesCount']?.toString() ?? '0') ?? 0;
            final bUpvotes =
                int.tryParse(b['upvotesCount']?.toString() ?? '0') ?? 0;
            return bUpvotes.compareTo(aUpvotes);
          });

          allAnswers = answers;

          isLoadingAnswers = false;
        });
        // Fetch the upvoted answer ID for this question
        await fetchUpvotedAnswerId();
      } else {
        setState(() {
          isLoadingAnswers = false;
          allAnswers = [];
        });
      }
    } catch (e) {
      setState(() {
        allAnswers = [];
        isLoadingAnswers = false;
      });
    }
  }

  // Function to fetch the upvoted answer ID for the current user for this question
  Future<void> fetchUpvotedAnswerId() async {
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        upvotedAnswerId = null;
        return;
      }
      final urlWithQuery = Uri.parse(
        '$upvotedAnswerUrl?questionId=${widget.question['questionId']}',
      );
      final response = await http.get(
        urlWithQuery,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("get upvoted Answer initilization :${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          upvotedAnswerId = data['answerId']?.toString();
        });
      } else {
        setState(() {
          upvotedAnswerId = null;
        });
      }
    } catch (e) {
      setState(() {
        upvotedAnswerId = null;
      });
    }
  }

  // Function to handle upvoting an answer
  Future<void> _handleUpvote(String answerId) async {
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
      // If user already upvoted a different answer, show confirmation dialog
      if (upvotedAnswerId != null && upvotedAnswerId != answerId) {
        bool confirm = await _showChangeVoteDialog();
        if (!confirm) {
          setState(() {
            isUpvoting = false;
          });
          return;
        }
      }
      // If user clicks upvote on the same answer again, treat as toggle (remove upvote)
      final isTogglingOff = upvotedAnswerId == answerId;
      final apiUrl = Uri.parse(vote);
      final response = await http.put(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"answerId": answerId}),
      );
      print('Upvote response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          isUpvoting = false;
          if (isTogglingOff) {
            // Remove upvote
            upvotedAnswerId = null;
            for (var ans in allAnswers) {
              if (ans['answerId'] == answerId) {
                ans['upvotesCount'] = (ans['upvotesCount'] ?? 1) - 1;
                if (ans['upvotesCount'] < 0) ans['upvotesCount'] = 0;
              }
            }
          } else {
            // Remove previous upvote if any
            if (upvotedAnswerId != null && upvotedAnswerId != answerId) {
              for (var ans in allAnswers) {
                if (ans['answerId'] == upvotedAnswerId) {
                  ans['upvotesCount'] = (ans['upvotesCount'] ?? 1) - 1;
                  if (ans['upvotesCount'] < 0) ans['upvotesCount'] = 0;
                }
              }
            }
            upvotedAnswerId = answerId;
            // Update the upvotes count for the newly upvoted answer
            for (var ans in allAnswers) {
              if (ans['answerId'] == answerId) {
                ans['upvotesCount'] = (ans['upvotesCount'] ?? 0) + 1;
              }
            }
          }
        });
        // Optionally, refresh all answers from backend for full sync
        // await _fetchAllAnswers();
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
            showAllAnswers = true;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Answer submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          await _fetchAllAnswers();
          if (widget.onRefresh != null) {
            widget.onRefresh!();
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

  // Helper function to check if current user has already answered
  bool _hasCurrentUserAnswered() {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    for (final answer in allAnswers) {
      final answeredBy = answer['answeredBy'];
      final answeredById =
          answeredBy != null
              ? (answeredBy['id'] ?? answeredBy['userId'])
              : null;
      if (answeredById?.toString() == userId) {
        return true;
      }
    }
    return false;
  }

  // Modified function to handle showing the answer form
  Future<void> _handleShowAnswerForm() async {
    // Always fetch latest answers before showing the form
    await _fetchAllAnswers();
    if (!_hasCurrentUserAnswered()) {
      setState(() {
        showAnswerForm = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have already submitted an answer for this question.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final askedBy = widget.question['askedBy'];
final askedById = askedBy is String ? askedBy : askedBy?['id'];
final userId = userProvider.user?['id'];
final isOwner = askedById == userId;

final aiAnswer = widget.question['aiAnswer']?.toString().trim();
 final rawTopAnswer = widget.question['topAnswer'];
final topAnswerId = rawTopAnswer is Map ? rawTopAnswer['answerId']?.toString().trim() : null;

  //print("isQwner: $isOwner");
    //print("aiAnswer: $aiAnswer");
      //print("topAnswerId: $topAnswerId");
     // print("rawTopAnswerId: $topAnswerId");
    //  print("Full question: ${widget.question}");
final canEdit = isOwner &&
    aiAnswer != null &&
    aiAnswer.isNotEmpty &&
    (topAnswerId == null || topAnswerId.isEmpty);

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
                          fontSize: _getResponsiveFontSize(16),
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
                          size: _getResponsiveIconSize(16),
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
                            onTap: isSaving ? null : saveQuestion,
                            child: AnimatedScale(
                              scale:
                                  isPressed ? 0.85 : (isHovered ? 1.15 : 1.0),
                              duration: Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: _getResponsiveIconSize(20),
                                color:
                                    isSaved
                                        ? (isHovered
                                            ? Colors.green
                                            : AppColors.askPageSubtitle)
                                        : (isHovered
                                            ? Colors.blue
                                            : AppColors.askPageSubtitle),
                              ),
                            ),
                          ),
                        ),
                        // Delete button for owner
                        if (isOwner)
                          IconButton(
                            icon: Icon(Icons.delete, color: AppColors.deleteRed),
                            tooltip: 'Delete Question',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Question'),
                                  content: Text('Are you sure you want to delete this question? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700],
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Delete'),
                                      onPressed: () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  final token = await AuthUtils.getValidToken(context);
                                   final questionId = widget.question['questionId'] ?? widget.question['_id'];
                              if (questionId == null) {
                                 throw Exception('Question ID is missing');
                                       }
                               final url = Uri.parse('$deleteQuestionUrl$questionId');
                                  final response = await http.delete(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token',
                                    },
                                  );
                                  final data = jsonDecode(response.body);
                                  if (response.statusCode == 200 && data['success'] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Question deleted successfully'), backgroundColor: Colors.green),
                                    );
                                    if (widget.onRefresh != null) widget.onRefresh!();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(data['message'] ?? 'Failed to delete question'), backgroundColor: Colors.red),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting question: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                          ),
                        // Edit button for owner
                        if (canEdit)
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue[700]),
                            tooltip: 'Edit Question',
                            onPressed: () async {
                              final TextEditingController editController = TextEditingController(text: widget.question['text']);
                              String selectedCategory = widget.question['category'] ?? '';
                              final categories = [
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
                              bool isPublic = widget.question['isPublic'] ?? true;
                              String newAIAnswer = widget.question['aiAnswer'] ?? '';
                              bool textChanged = false;
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit Question'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: editController,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                            labelText: 'Question',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (val) {
                                            textChanged = true;
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        DropdownButtonFormField<String>(
                                          value: selectedCategory.isEmpty ? null : selectedCategory,
                                          items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                                          onChanged: (val) => selectedCategory = val ?? '',
                                          decoration: InputDecoration(
                                            labelText: 'Category',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(isPublic ? Icons.lock_open : Icons.lock, color: isPublic ? Colors.green : Colors.orange),
                                            SizedBox(width: 8),
                                            Text(isPublic ? 'Public' : 'Private'),
                                            Spacer(),
                                            Switch(
                                              value: isPublic,
                                              onChanged: (val) {
                                                isPublic = val;
                                                (context as Element).markNeedsBuild();
                                              },
                                              activeColor: Colors.green,
                                              inactiveThumbColor: Colors.orange,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Save'),
                                      onPressed: () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                              );
                              if (result == true) {
                                try {
                                  final token = await AuthUtils.getValidToken(context);
                                  // If the text changed, regenerate the AI answer
                                  if (textChanged && editController.text.trim() != widget.question['text']) {
                                    newAIAnswer = await questions_util.generateAIAnswerGemini(editController.text.trim());
                                  }
                                  final url = Uri.parse(updateQuestionUrl+(widget.question['questionId'] ?? widget.question['_id'] ?? ''));
                                  final response = await http.put(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token',
                                    },
                                    body: jsonEncode({
                                      'text': editController.text.trim(),
                                      'category': selectedCategory,
                                      'isPublic': isPublic,
                                      'aiAnswer': newAIAnswer,
                                    }),
                                  );
                                  final data = jsonDecode(response.body);
                                  if (response.statusCode == 200 && data['success'] == true) {
                                    print("status: ${response.statusCode}, data: $data");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Question updated successfully'), backgroundColor: Colors.green),
                                    );
                                    setState(() {
                                      widget.question['text'] = editController.text.trim();
                                      widget.question['category'] = selectedCategory;
                                      widget.question['isPublic'] = isPublic;
                                      widget.question['aiAnswer'] = newAIAnswer;
                                    });
                                    widget.onUpdate?.call({
                                      'text': editController.text.trim(),
                                      'category': selectedCategory,
                                      'isPublic': isPublic,
                                      'aiAnswer': newAIAnswer,
                                    });
                                    if (widget.onRefresh != null) widget.onRefresh!();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(data['message'] ?? 'Failed to update question'), backgroundColor: Colors.red),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error updating question: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
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
                        SizedBox(width: 12),
                        _buildPrivacyChip(question['isPublic'] ?? true),
                      ],
                    ),
                  ],
                ),
                // Show "Show/Hide all answers" button for certified volunteers
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    spacing: 5,
                    children: [
                      if (_isCertifiedVolunteer() &&
                          question['responseType'] == 'human') ...[
                        SizedBox(height: 16),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: _handleShowAllAnswers,
                            icon: Icon(
                              showAllAnswers
                                  ? Icons.visibility_off
                                  : Icons.list_alt,
                              size: _getResponsiveIconSize(16),
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
                                horizontal: _getResponsivePadding(20),
                                vertical: _getResponsivePadding(10),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Show "Answer Question" button for certified volunteers that has not answered yet
                      if (_isCertifiedVolunteer() &&
                          !_isTopAnswerByCurrentUser() &&
                          !_hasCurrentUserAnswered()) ...[
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed:
                                isSubmittingAnswer
                                    ? null
                                    : _handleShowAnswerForm,
                            icon: Icon(
                              showAnswerForm ? Icons.close : Icons.edit,
                              size: _getResponsiveIconSize(16),
                            ),
                            label: Text(
                              showAnswerForm ? 'Cancel' : 'Answer Question',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.islamicGreen500,
                              foregroundColor: AppColors.islamicWhite,
                              padding: EdgeInsets.symmetric(
                                horizontal: _getResponsivePadding(20),
                                vertical: _getResponsivePadding(10),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                      Spacer(),
                      if (question['responseType']?.toString() == 'ai')
                        _buildResponseBadge(
                          question['responseType']?.toString(),
                        ),
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
                  // Answers list (not scrollable, expands to fit all answers)
                  if (isLoadingAnswers)
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.islamicGreen500,
                        ),
                      ),
                    )
                  else if (allAnswers.isEmpty)
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No answers available',
                          style: TextStyle(
                            color: AppColors.askPageSubtitle,
                            fontSize: _getResponsiveFontSize(14),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children:
                          allAnswers
                              .asMap()
                              .entries
                              .map(
                                (entry) =>
                                    _buildAnswerCard(entry.value, entry.key),
                              )
                              .toList(),
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
                          size: _getResponsiveIconSize(16),
                          color: AppColors.islamicGreen500,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Your Answer',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(14),
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
                              horizontal: _getResponsivePadding(20),
                              vertical: _getResponsivePadding(10),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              isSubmittingAnswer
                                  ? SizedBox(
                                    width: _getResponsiveIconSize(16),
                                    height: _getResponsiveIconSize(16),
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
              question['topAnswer'] != null &&
              !showAllAnswers)
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
          size: _getResponsiveIconSize(20),
          color: AppColors.askPageSubtitle,
        );
      case 'ai':
        return Icon(
          Icons.smart_toy,
          size: _getResponsiveIconSize(20),
          color: AppColors.askPageAIBlue,
        );
      default:
        return Icon(
          Icons.access_time,
          size: _getResponsiveIconSize(20),
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
          Icon(
            Icons.tag,
            size: _getResponsiveIconSize(12),
            color: AppColors.askPageCategoryText,
          ),
          SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(12),
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
        Icon(
          icon,
          size: _getResponsiveIconSize(12),
          color: AppColors.askPageSubtitle,
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(12),
            color: AppColors.askPageSubtitle,
          ),
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
          fontSize: _getResponsiveFontSize(10),
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
    if (responseType == "ai") backgroundColor = AppColors.askPageAIBox;
    textColor = AppColors.askPageAIText;
    text = '🤖 AI';
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
          fontSize: _getResponsiveFontSize(12),
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper function to extract display name from answeredBy object
  String _getAnswererDisplayName(Map<String, dynamic>? answeredBy) {
    if (answeredBy == null) return '';
    return answeredBy['displayName']?.toString() ?? '';
  }

  // Widget to display top answer
  Widget _buildTopAnswerCard(Map<String, dynamic> topAnswer) {
    final answeredBy = topAnswer['answeredBy'];
    final answerText = topAnswer['text']?.toString() ?? '';
    final upvotesCount = topAnswer['upvotesCount']?.toString() ?? '0';
    final answererName = _getAnswererDisplayName(answeredBy);
    final createdAt = topAnswer['createdAt']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(6), // Outer white padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.islamicGreen400.withOpacity(0.5),
          border: Border.all(
            color: AppColors.islamicGreen500.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answerer info row
            Row(
              children: [
                // Top answer indicator
                Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.islamicGreen500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: _getResponsiveIconSize(10),
                        color: Colors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Top Answer',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(10),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_user,
                  size: _getResponsiveIconSize(16),
                  color: AppColors.islamicGreen500,
                ),
                SizedBox(width: 4),
                Text(
                  answererName,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.askPageTitle,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.verified,
                  size: _getResponsiveIconSize(12),
                  color: AppColors.islamicGreen500,
                ),
                Spacer(),
                Row(
                  children: [
                    Tooltip(
                      message:
                          _isCertifiedVolunteer()
                              ? "Expand to upvote this answer"
                              : "$upvotesCount Muslims approved this",
                      child: Icon(
                        Icons.thumb_up,
                        size: _getResponsiveIconSize(12),
                        color: AppColors.askPageSubtitle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      upvotesCount,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(12),
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
                fontSize: _getResponsiveFontSize(14),
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
                  fontSize: _getResponsiveFontSize(11),
                  color: AppColors.askPageSubtitle,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget to display individual answer in the scrollable list
  Widget _buildAnswerCard(Map<String, dynamic> answer, int index) {
    final answeredBy = answer['answeredBy'];
    final answerText = answer['text']?.toString() ?? '';
    final upvotesCount = answer['upvotesCount']?.toString() ?? '0';
    final answererName = _getAnswererDisplayName(answeredBy);
    final createdAt = answer['createdAt']?.toString() ?? '';
    final answerId = answer['answerId']?.toString() ?? '';
    final isCertified = _isCertifiedVolunteer();
    final isUpvoted = upvotedAnswerId == answerId;
    final isTopAnswer = index == 0; // First element is the top answer

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isTopAnswer
                ? AppColors.islamicGreen400.withOpacity(0.5)
                : Colors.white,
        border: Border.all(
          color:
              isTopAnswer
                  ? AppColors.islamicGreen500.withOpacity(0.5)
                  : AppColors.askPageBorder.withOpacity(0.3),
          width: isTopAnswer ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Answerer info row
          Row(
            children: [
              // Top answer indicator
              if (isTopAnswer)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.islamicGreen500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: _getResponsiveIconSize(10),
                        color: Colors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Top Answer',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(10),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Icon(
                Icons.verified_user,
                size: _getResponsiveIconSize(16),
                color: AppColors.islamicGreen500,
              ),
              SizedBox(width: 4),
              Text(
                answererName,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.askPageTitle,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.verified,
                size: _getResponsiveIconSize(12),
                color: AppColors.islamicGreen500,
              ),
              Spacer(),

              // Upvote icon for certified volunteers
              if (answeredBy['id']?.toString() !=
                  Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).userId?.toString())
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color:
                            isUpvoted
                                ? Colors.lightGreen
                                : AppColors.askPageSubtitle,
                      ),
                      tooltip: isUpvoted ? 'Upvoted' : 'Upvote',
                      onPressed:
                          isCertified ? () => _handleUpvote(answerId) : () {},
                    ),
                    Text(
                      upvotesCount,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(12),
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
              fontSize: _getResponsiveFontSize(14),
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
                fontSize: _getResponsiveFontSize(11),
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

  bool _isTopAnswerByCurrentUser() {
    final topAnswer = widget.question['topAnswer'];
    final answeredBy = topAnswer != null ? topAnswer['answeredBy'] : null;
    final answeredById = answeredBy != null ? answeredBy['id'] : null;
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    return answeredById?.toString() == userId;
  }

  






}

