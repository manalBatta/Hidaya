import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'AIResponseCard.dart';

class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;

  const QuestionCard({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          '${question['answers'] as int} ${question['answers'] as int == 1 ? 'answer' : 'answers'}',
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

          // AI Response Card
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
}
