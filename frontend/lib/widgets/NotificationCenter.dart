import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/auth_utils.dart';

class NotificationCenter extends StatefulWidget {
  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${url}notifications'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(
              data['notifications'] ?? [],
            );
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) return;

      final response = await http.put(
        Uri.parse('${url}notifications/$notificationId/read'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Update local state
        setState(() {
          final index = notifications.indexWhere(
            (n) => n['id'] == notificationId,
          );
          if (index != -1) {
            notifications[index]['read'] = true;
          }
        });
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) return;

      final response = await http.put(
        Uri.parse('${url}notifications/mark-all-read'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var notification in notifications) {
            notification['read'] = true;
          }
        });
      }
    } catch (e) {
      print('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> _deleteAllNotifications() async {
    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('${url}notifications'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All notifications deleted successfully'),
            backgroundColor: AppColors.islamicGreen500,
          ),
        );
      }
    } catch (e) {
      print('Failed to delete all notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delete All Notifications',
                  style: TextStyle(
                    color: AppColors.islamicGreen800,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete all notifications? This action cannot be undone.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete All', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'question_answered':
        return '💬';
      case 'answer_upvoted':
        return '👍';
      case 'new_question':
        return '🤔';
      case 'welcome':
        return '🎉';
      case 'test':
        return '🔔';
      default:
        return '📢';
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'question_answered':
        return AppColors.islamicGreen500;
      case 'answer_upvoted':
        return AppColors.islamicGold500;
      case 'new_question':
        return AppColors.islamicGreen600;
      case 'welcome':
        return AppColors.islamicGreen400;
      case 'test':
        return AppColors.islamicGold400;
      default:
        return AppColors.islamicGreen500;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.islamicGreen800,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.islamicGreen800),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () => _showDeleteConfirmation(),
              tooltip: 'Delete all notifications',
            ),
          if (notifications.any((n) => !n['read']))
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.islamicGreen50,
              AppColors.islamicCream,
              AppColors.islamicGold50,
            ],
          ),
        ),
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.islamicGreen500,
                  ),
                )
                : hasError
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load notifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.islamicGreen500,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                : notifications.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You\'ll see notifications here when you receive them',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: AppColors.islamicGreen500,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isUnread = !notification['read'];

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: isUnread ? 4 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              isUnread
                                  ? BorderSide(
                                    color: _getNotificationColor(
                                      notification['type'],
                                    ),
                                    width: 2,
                                  )
                                  : BorderSide.none,
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isUnread) {
                              _markAsRead(notification['id']);
                            }
                            // Handle navigation based on notification type
                            _handleNotificationTap(notification);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(
                                      notification['type'],
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getNotificationIcon(
                                        notification['type'],
                                      ),
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification['title'] ??
                                                  'Notification',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    isUnread
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color:
                                                    isUnread
                                                        ? AppColors
                                                            .islamicGreen800
                                                        : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: _getNotificationColor(
                                                  notification['type'],
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        notification['message'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _formatDate(
                                          notification['createdAt'] ?? '',
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'];
    final data = notification['data'];

    switch (type) {
      case 'question_answered':
        // Navigate to the answered question
        final questionId = data?['questionId'];
        if (questionId != null) {
          // Navigate to question detail page
          print('Navigate to question: $questionId');
        }
        break;
      case 'answer_upvoted':
        // Navigate to the upvoted answer
        final questionId = data?['questionId'];
        final answerId = data?['answerId'];
        if (questionId != null) {
          print('Navigate to upvoted answer: $answerId');
        }
        break;
      case 'new_question':
        // Navigate to the new question
        final questionId = data?['questionId'];
        if (questionId != null) {
          print('Navigate to new question: $questionId');
        }
        break;
      case 'welcome':
      case 'test':
        // No navigation needed
        break;
    }
  }
}
