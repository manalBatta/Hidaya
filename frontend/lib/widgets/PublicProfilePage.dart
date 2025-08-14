import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:frontend/services/meeting_request_service.dart';
import 'package:frontend/utils/auth_utils.dart';

class PublicProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool inDialog;

  const PublicProfilePage({Key? key, required this.user, this.inDialog = false})
    : super(key: key);

  String _stringOf(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (inDialog) {
      return PublicProfileView(user: user);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.islamicGreen500,
        foregroundColor: Colors.white,
        title: Text(
          _stringOf(user['displayName']).isNotEmpty
              ? _stringOf(user['displayName'])
              : 'User',
        ),
      ),
      body: PublicProfileView(user: user),
    );
  }
}

class PublicProfileView extends StatelessWidget {
  final Map<String, dynamic> user;

  const PublicProfileView({Key? key, required this.user}) : super(key: key);

  String _stringOf(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _stringOf(user['displayName']).isNotEmpty
            ? _stringOf(user['displayName'])
            : 'User';
    final role =
        _stringOf(user['role']).isNotEmpty ? _stringOf(user['role']) : 'user';
    final country = _stringOf(user['country']);
    final language = _stringOf(user['language']);
    final volunteerProfile = user['volunteerProfile'] as Map<String, dynamic>?;
    final bio =
        volunteerProfile != null ? _stringOf(volunteerProfile['bio']) : '';
    final languages =
        volunteerProfile != null
            ? (volunteerProfile['languages'] as List?)
            : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.islamicGreen200,
                child: Icon(Icons.person, color: AppColors.islamicGreen800),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.islamicGreen900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(icon: Icons.verified_user, label: role),
                        if (country.isNotEmpty)
                          _InfoChip(icon: Icons.public, label: country),
                        if (language.isNotEmpty)
                          _InfoChip(icon: Icons.language, label: language),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (bio.isNotEmpty) ...[
            Text(
              'Bio',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.islamicGreen800,
              ),
            ),
            SizedBox(height: 8),
            Text(bio, style: TextStyle(color: AppColors.islamicGreen700)),
            SizedBox(height: 16),
          ],
          if (languages != null && languages.isNotEmpty) ...[
            Text(
              'Spoken Languages',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.islamicGreen800,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  languages
                      .map(
                        (e) => _InfoChip(
                          icon: Icons.record_voice_over,
                          label: e.toString(),
                        ),
                      )
                      .toList(),
            ),
          ],

          // Request Zoom Meeting button (only for volunteers)
          if (role.toLowerCase() == 'certified_volunteer') ...[
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showZoomRequestDialog(context),
                icon: Icon(Icons.video_call, color: Colors.white),
                label: Text(
                  'Request Zoom Meeting',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.islamicGreen600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showZoomRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Request Zoom Meeting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select up to 5 preferred time slots for your meeting with ${_stringOf(user['displayName'])}.',
              ),
              SizedBox(height: 16),
              Text(
                'Each slot is 30 minutes. The volunteer will choose one of your preferred times.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showTimeSlotSelectionDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.islamicGreen600,
                foregroundColor: Colors.white,
              ),
              child: Text('Select Times'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeSlotSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: _TimeSlotSelector(volunteerUser: user),
        );
      },
    );
  }
}

class _TimeSlotSelector extends StatefulWidget {
  final Map<String, dynamic> volunteerUser;

  const _TimeSlotSelector({Key? key, required this.volunteerUser})
    : super(key: key);

  @override
  State<_TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<_TimeSlotSelector> {
  final List<DateTime> _slots = [];
  bool _submitting = false;

  String _formatLocal(DateTime dt) {
    final local = dt.toLocal();
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}  ${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _addSlot() async {
    if (_slots.length >= 5) return;

    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(Duration(days: 60)),
      initialDate: now,
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(Duration(minutes: 30))),
    );
    if (pickedTime == null) return;

    final localStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    // Convert to UTC for backend
    final startUtc = localStart.toUtc();

    if (startUtc.isBefore(DateTime.now().toUtc())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Start time must be in the future')),
      );
      return;
    }

    // Prevent duplicates (same start time up to minute)
    final duplicate = _slots.any(
      (s) =>
          s.toUtc().millisecondsSinceEpoch == startUtc.millisecondsSinceEpoch,
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This time slot is already added')),
      );
      return;
    }

    // Enforce exact 30-minute slot implicitly via endUtc
    setState(() {
      _slots.add(startUtc);
      _slots.sort();
    });
  }

  Future<void> _submit() async {
    if (_slots.isEmpty || _submitting) return;
    final volunteerId = widget.volunteerUser['userId']?.toString() ?? '';
    if (volunteerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to determine volunteer ID')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final token = await AuthUtils.getValidToken(context);
      if (token == null) {
        setState(() => _submitting = false);
        return;
      }

      final preferredSlots =
          _slots
              .map(
                (s) => {
                  'start': s.toIso8601String(),
                  'end': s.add(Duration(minutes: 30)).toIso8601String(),
                },
              )
              .toList();

      final result = await MeetingRequestService.createMeetingRequest(
        volunteerId: volunteerId,
        preferredSlots: preferredSlots,
        token: token,
      );

      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Meeting request sent')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to send request'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select up to 5 time slots (30 min each)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.islamicGreen800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _slots)
                    Chip(
                      label: Text(_formatLocal(s)),
                      onDeleted:
                          _submitting
                              ? null
                              : () {
                                setState(() {
                                  _slots.remove(s);
                                });
                              },
                    ),
                  if (_slots.length < 5)
                    ActionChip(
                      label: Text('Add slot'),
                      avatar: Icon(Icons.add, size: 18),
                      onPressed: _submitting ? null : _addSlot,
                    ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting || _slots.isEmpty ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.islamicGreen600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _submitting
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text('Send Request'),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({Key? key, required this.icon, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.askPageCategoryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.askPageCategoryText),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.askPageCategoryText,
            ),
          ),
        ],
      ),
    );
  }
}
