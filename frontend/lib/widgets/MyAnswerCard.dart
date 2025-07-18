import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:http/http.dart' as http;
import '../constants/colors.dart';
import 'package:provider/provider.dart';

class MyAnswerCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onDelete;
  // item should have keys: 'question', 'topAnswer', 'volunteerAnswer'
  const MyAnswerCard({Key? key, required this.item, this.onDelete})
    : super(key: key);

  @override
  State<MyAnswerCard> createState() => _MyAnswerCardState();
}

class _MyAnswerCardState extends State<MyAnswerCard> {
  bool _isDeleting = false;
  bool _deleted = false;
  Future<void> _deleteAnswer(String answerId) async {
    if (!mounted) return;
    setState(() {
      _isDeleting = true;
    });
    try {
      final response = await http.delete(Uri.parse('$deleteAns$answerId'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Answer deleted successfully')));
        _deleted = true;
        if (widget.onDelete != null) {
          widget.onDelete!();
          return; // Prevent further code from running after widget is disposed
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete answer: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      // Only call setState if still mounted and onDelete hasn't been called
      if (mounted)
        setState(() {
          _isDeleting = false;
        });
    }
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

  void _confirmDelete(String answerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Answer'),
            content: Text('Are you sure you want to delete your answer?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      _deleteAnswer(answerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.item['question'] ?? {};
    final topAnswer = widget.item['topAnswer'];
    final volunteerAnswer = widget.item['volunteerAnswer'];
    final askedBy = widget.item['askedBy'];

    // Determine if the volunteer has an answer to allow delete
    final Map<String, dynamic>? ownAnswer = volunteerAnswer ?? topAnswer;
    final String? ownAnswerId =
        ownAnswer != null ? ownAnswer['answerId']?.toString() : null;
    final bool canDelete = ownAnswer != null && ownAnswer['answeredBy'] != null;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.askPageTitle,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (canDelete && ownAnswerId != null)
                    IconButton(
                      icon:
                          _isDeleting
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete your answer',
                      onPressed:
                          _isDeleting
                              ? null
                              : () => _confirmDelete(ownAnswerId),
                    ),
                ],
              ),
              SizedBox(height: 8),
              // Category and meta info
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (question['category'] != null)
                    _buildCategoryChip(question['category'].toString()),
                  if (askedBy != null)
                    _buildInfoChip(
                      Icons.person,
                      askedBy is Map
                          ? askedBy['displayName']?.toString()
                          : askedBy?.toString(),
                    ),
                  if (question['createdAt'] != null)
                    _buildInfoChip(
                      Icons.access_time,
                      _formatDate(question['createdAt'].toString()),
                    ),
                ],
              ),
              SizedBox(height: 16),
              // Top Answer
              if (topAnswer != null)
                _buildAnswerSection('Top Answer', topAnswer, highlight: true),
              // Volunteer Answer
              if (volunteerAnswer != null &&
                  topAnswer != null &&
                  topAnswer['answerId'] != volunteerAnswer['answerId'])
                _buildAnswerSection(
                  'Your Answer',
                  volunteerAnswer,
                  highlight: false,
                ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildAnswerSection(
    String label,
    Map<String, dynamic> answer, {
    bool highlight = false,
  }) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final answerer =
        answer['answeredBy'] is Map
            ? answer['answeredBy']['displayName']?.toString()
            : user?['displayName'];
    final answerText = answer['text']?.toString() ?? '';
    final upvotesCount = answer['upvotesCount']?.toString() ?? '0';
    final createdAt = _formatDate(answer['createdAt']?.toString() ?? '');
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            highlight
                ? AppColors.islamicGreen400.withOpacity(0.15)
                : Colors.white,
        border: Border.all(
          color:
              highlight
                  ? AppColors.islamicGreen500.withOpacity(0.5)
                  : AppColors.askPageBorder.withOpacity(0.3),
          width: highlight ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (highlight)
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
                      Icon(Icons.star, size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Top Answer',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Icon(
                Icons.verified_user,
                size: 16,
                color: AppColors.islamicGreen500,
              ),
              SizedBox(width: 4),
              Text(
                answerer ?? '',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.askPageTitle,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.verified, size: 12, color: AppColors.islamicGreen500),
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
          Text(
            answerText,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.askPageTitle,
              height: 1.4,
            ),
          ),
          if (createdAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Answered on $createdAt',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.askPageSubtitle,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
