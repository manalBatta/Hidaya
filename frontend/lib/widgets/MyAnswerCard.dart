import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MyAnswerCard extends StatelessWidget {
  final Map<String, dynamic> item;
  // item should have keys: 'question', 'topAnswer', 'volunteerAnswer'
  const MyAnswerCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final question = item['question'] ?? {};
    final topAnswer = item['topAnswer'];
    final volunteerAnswer = item['volunteerAnswer'];

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
              // Question text
              Text(
                question['text']?.toString() ?? 'No question text',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.askPageTitle,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8),
              // Category and meta info
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (question['category'] != null)
                    _buildCategoryChip(question['category'].toString()),
                  if (question['askedBy'] != null)
                    _buildInfoChip(
                      Icons.person,
                      question['askedBy'] is Map
                          ? question['askedBy']['displayName']?.toString()
                          : question['askedBy']?.toString(),
                    ),
                  if (question['createdAt'] != null)
                    _buildInfoChip(
                      Icons.access_time,
                      question['createdAt'].toString(),
                    ),
                ],
              ),
              SizedBox(height: 16),
              // Top Answer
              if (topAnswer != null)
                _buildAnswerSection('Top Answer', topAnswer, highlight: true),
              // Volunteer Answer
              if (volunteerAnswer != null)
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
    final answerer =
        answer['answeredBy'] is Map
            ? answer['answeredBy']['displayName']?.toString()
            : answer['answeredBy']?.toString();
    final answerText = answer['text']?.toString() ?? '';
    final upvotesCount = answer['upvotesCount']?.toString() ?? '0';
    final createdAt = answer['createdAt']?.toString() ?? '';
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
