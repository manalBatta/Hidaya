// lib/pages/ask_page.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import '../constants/colors.dart';
import 'QuestionCard.dart';
import 'AIResponseCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:async'; // Added for Completer
import 'package:provider/provider.dart';
import '../providers/UserProvider.dart';

class Questions extends StatefulWidget {
  @override
  _QuestionsState createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _searchController = TextEditingController();
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;
  late TabController _tabController;

  String _selectedCategory = '';
  bool _isPublic = true;
  bool _showSuccessMessage = false;
  String _searchQuery = '';
  bool _showFailMessage = false;

  UserProvider? userProvider;

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

  // Mock data for tabs
  List<Map<String, dynamic>> _communityQuestions = [
    {
      'questionId': '201',
      'text': 'What is the correct way to perform Wudu before prayer?',
      'isPublic': true,
      'askedBy': {'id': 'user-2', 'displayName': 'Sister Aisha'},
      'createdAt': '2024-07-11T08:00:00.000Z',
      'aiAnswer': '',
      'topAnswerId': 'answer-201',
      'tags': ['wudu', 'prayer', 'worship'],
      'category': 'Worship',
      '_id': 'dbid-201',
      '__v': 0,
      'timeAgo': '2 hours ago',
      'answers': 24,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Sheikh Ahmad Ali',
      'excerpt':
          'Wudu is performed in a specific sequence as taught by Prophet Muhammad (PBUH)...',
      'isFavorited': false,
    },
    {
      'questionId': '202',
      'text': 'Can I pray while traveling and what are the concessions?',
      'isPublic': true,
      'askedBy': {'id': 'user-3', 'displayName': 'Brother Omar'},
      'createdAt': '2024-07-11T06:00:00.000Z',
      'aiAnswer':
          'Yes, Islam provides several concessions for travelers including shortening prayers...',
      'topAnswerId': '',
      'tags': ['prayer', 'travel'],
      'category': 'Prayer',
      '_id': 'dbid-202',
      '__v': 0,
      'timeAgo': '4 hours ago',
      'answers': 0,
      'responseType': 'ai',
      'isAnswered': false,
      'answeredBy': 'AI Assistant',
      'excerpt':
          'Yes, Islam provides several concessions for travelers including shortening prayers...',
      'isFavorited': false,
    },
    {
      'questionId': '203',
      'text':
          'What are the etiquettes when visiting a mosque for the first time?',
      'isPublic': true,
      'askedBy': {'id': 'user-4', 'displayName': 'Sister Fatima'},
      'createdAt': '2024-07-11T04:00:00.000Z',
      'aiAnswer': '',
      'topAnswerId': 'answer-203',
      'tags': ['etiquette', 'mosque'],
      'category': 'Etiquette',
      '_id': 'dbid-203',
      '__v': 0,
      'timeAgo': '6 hours ago',
      'answers': 32,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Dr. Fatima Al-Zahra',
      'excerpt':
          'When visiting a mosque, there are several important etiquettes to observe...',
      'isFavorited': true,
    },
    {
      'questionId': '204',
      'text':
          'How do I balance Islamic principles with modern workplace demands?',
      'isPublic': true,
      'askedBy': {'id': 'user-5', 'displayName': 'Brother Ahmed'},
      'createdAt': '2024-07-10T08:00:00.000Z',
      'aiAnswer':
          'Balancing faith with work requires clear communication and seeking halal alternatives...',
      'topAnswerId': '',
      'tags': ['daily life', 'workplace', 'Islam'],
      'category': 'Daily Life',
      '_id': 'dbid-204',
      '__v': 0,
      'timeAgo': '1 day ago',
      'answers': 0,
      'responseType': 'ai',
      'isAnswered': false,
      'answeredBy': 'AI Assistant',
      'excerpt':
          'Balancing faith with work requires clear communication and seeking halal alternatives...',
      'isFavorited': false,
    },
  ];

  final List<Map<String, dynamic>> _myQuestions = [
    {
      'questionId': '101',
      'text': 'Personal question about family relationships in Islam',
      'isPublic': false,
      'askedBy': {'id': 'user-1', 'displayName': 'Test User'},
      'createdAt': '2024-07-01T10:00:00.000Z',
      'aiAnswer':
          'In Islam, family relationships are based on mutual respect, kindness, and fulfilling each other’s rights and responsibilities.',
      'topAnswerId': 'answer-101',
      'tags': ['family', 'relationships', 'Islam'],
      'category': 'Family & Marriage',
      '_id': 'dbid-101',
      '__v': 0,
      // For UI compatibility
      'timeAgo': '3 days ago',
      'answers': 5,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Sister Khadija Ibrahim',
    },
    {
      'questionId': '102',
      'text': 'How to perform Tahajjud prayer correctly?',
      'isPublic': true,
      'askedBy': {'id': 'user-1', 'displayName': 'Test User'},
      'createdAt': '2024-06-25T08:30:00.000Z',
      'aiAnswer':
          'Tahajjud prayer is performed after Isha and before Fajr, preferably in the last third of the night. It consists of at least two rak’ahs and can be prayed in sets of two.',
      'topAnswerId': '',
      'tags': ['tahajjud', 'prayer', 'worship'],
      'category': 'Worship',
      '_id': 'dbid-102',
      '__v': 0,
      // For UI compatibility
      'timeAgo': '1 week ago',
      'answers': 0,
      'responseType': 'ai',
      'isAnswered': false,
      'answeredBy': 'Sheikh Ahmad Ali',
    },
  ];

  List<Map<String, dynamic>> _favoriteQuestions = [
    {
      'questionId': '201',
      'text': 'Understanding the concept of Tawakkul (trust in Allah)',
      'isPublic': true,
      'askedBy': {
        'id': 'user-201',
        'displayName': 'Brother Yusuf',
        'country': 'Palestine',
      },
      'createdAt': '2024-06-01T10:00:00.000Z',
      'aiAnswer': '',
      'topAnswerId': 'answer-201',
      'tags': ['tawakkul', 'trust', 'Allah'],
      'category': 'Spirituality',
      '_id': 'dbid-201',
      '__v': 0,
      'timeAgo': '1 month ago',
      'answers': 89,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Dr. Omar Suleiman',
      'isFavorited': true,
    },
  ];

  // Recent community questions data
  List<Map<String, dynamic>> _recentQuestions = [
    {
      'questionId': '301',
      'text': 'What is the correct way to perform Wudu?',
      'isPublic': true,
      'askedBy': {
        'id': 'user-301',
        'displayName': 'Sister Aisha',
        'country': 'Palestine',
      },
      'createdAt': '2024-07-11T08:00:00.000Z',
      'aiAnswer': '',
      'topAnswerId': 'answer-301',
      'tags': ['wudu', 'prayer', 'worship'],
      'category': 'Worship',
      '_id': 'dbid-301',
      '__v': 0,
      'timeAgo': '2 hours ago',
      'answers': 3,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Sheikh Ahmad Ali',
    },
    {
      'questionId': '302',
      'text': 'Can I pray while traveling?',
      'isPublic': true,
      'askedBy': {
        'id': 'user-302',
        'displayName': 'Brother Omar',
        'country': 'Palestine',
      },
      'createdAt': '2024-07-11T06:00:00.000Z',
      'aiAnswer':
          'Yes, you can pray while traveling. Islam provides accommodations for travelers including shortening prayers (Qasr) and combining certain prayers. The Quran mentions this in verse 4:101. However, it\'s recommended to seek guidance from a certified scholar for your specific travel circumstances.',
      'topAnswerId': '',
      'tags': ['prayer', 'travel'],
      'category': 'Prayer',
      '_id': 'dbid-302',
      '__v': 0,
      'timeAgo': '4 hours ago',
      'answers': 1,
      'responseType': 'ai',
      'isAnswered': false,
      'answeredBy': 'AI Assistant',
    },
    {
      'questionId': '303',
      'text': 'What are the etiquettes of visiting a mosque?',
      'isPublic': true,
      'askedBy': {
        'id': 'user-303',
        'displayName': 'Sister Fatima',
        'country': 'Palestine',
      },
      'createdAt': '2024-07-11T04:00:00.000Z',
      'aiAnswer': '',
      'topAnswerId': 'answer-303',
      'tags': ['etiquette', 'mosque'],
      'category': 'Etiquette',
      '_id': 'dbid-303',
      '__v': 0,
      'timeAgo': '6 hours ago',
      'answers': 0,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Dr. Fatima Al-Zahra',
    },
    {
      'questionId': '304',
      'text': 'Personal family guidance needed',
      'isPublic': false,
      'askedBy': {
        'id': 'user-304',
        'displayName': 'Anonymous',
        'country': 'Palestine',
      },
      'createdAt': '2024-07-11T03:00:00.000Z',
      'aiAnswer': '',
      'topAnswerId': 'answer-304',
      'tags': ['family', 'guidance'],
      'category': 'Family & Marriage',
      '_id': 'dbid-304',
      '__v': 0,
      'timeAgo': '8 hours ago',
      'answers': 1,
      'responseType': 'human',
      'isAnswered': true,
      'answeredBy': 'Anonymous',
    },
    {
      'questionId': '305',
      'text': 'How should I handle conflicts with Islamic principles at work?',
      'isPublic': true,
      'askedBy': {
        'id': 'user-305',
        'displayName': 'Brother Ahmed',
        'country': 'Palestine',
      },
      'createdAt': '2024-07-10T08:00:00.000Z',
      'aiAnswer':
          'Balancing Islamic principles with workplace requirements can be challenging. The key is open communication with your employer about your religious needs, seeking halal alternatives when possible, and consulting with Islamic scholars for guidance on specific situations. Remember that Islam emphasizes both fulfilling your obligations and maintaining your faith.',
      'topAnswerId': '',
      'tags': ['work', 'Islamic principles', 'conflict'],
      'category': 'Daily Life',
      '_id': 'dbid-305',
      '__v': 0,
      'timeAgo': '1 day ago',
      'answers': 0,
      'responseType': 'ai',
      'isAnswered': false,
      'answeredBy': 'AI Assistant',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    // Get userProvider after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      _getCommunityAndRecentQuestions();
      getFavoriteQuestions();
    });
    _tabController.addListener(() {
      if (_tabController.index == 0 && _tabController.indexIsChanging) {
        _getCommunityAndRecentQuestions();
        getFavoriteQuestions();
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _searchController.dispose();
    _successAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _submitQuestion() async {
    if (_formKey.currentState!.validate() && _selectedCategory.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final tags = await extractTagsFromQuestionGemini(
          _questionController.text,
        );
        // Generate AI answer before submitting
        final aiAnswer = await generateAIAnswerGemini(_questionController.text);

        final requestbody = {
          "text": _questionController.text,
          "isPublic": _isPublic,
          "category": _selectedCategory,
          "tags": tags,
          "aiAnswer": aiAnswer,
        };

        print("add question request body: $requestbody");
        var response = await http.post(
          Uri.parse(questions),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(requestbody),
        );
        final data = jsonDecode(response.body);

        print("response: ${response.statusCode}");
        if (response.statusCode == 201) {
          if (data['status'] == true) {
            print('Question submitted successfully');
            print(data);

            // Add the new question to _myQuestions
            final newQuestion = data['question'];
            setState(() {
              _myQuestions.insert(0, {
                'questionId':
                    newQuestion['questionId'] ?? newQuestion['_id'] ?? '',
                'text': newQuestion['text'] ?? '',
                'isPublic': newQuestion['isPublic'] ?? true,
                'askedBy':
                    newQuestion['askedBy'] ?? {'id': '', 'displayName': ''},
                'createdAt':
                    newQuestion['createdAt'] ??
                    DateTime.now().toIso8601String(),
                'aiAnswer': newQuestion['aiAnswer'] ?? '',
                'topAnswerId': newQuestion['topAnswerId'] ?? '',
                'tags': newQuestion['tags'] ?? [],
                'category': newQuestion['category'] ?? '',
                '_id': newQuestion['_id'] ?? '',
                '__v': newQuestion['__v'] ?? 0,
                // UI compatibility fields
                'timeAgo': 'Just now',
                'answers': 0,
                'responseType':
                    (newQuestion['topAnswerId'] == null &&
                            newQuestion['topAnswerId'].toString().isEmpty)
                        ? 'ai'
                        : 'human',
                'isAnswered':
                    (newQuestion['topAnswerId'] != null &&
                        newQuestion['topAnswerId'].toString().isNotEmpty),
                'answeredBy': newQuestion['askedBy']?['displayName'] ?? '',
              });
            });

            // Reset form
            _questionController.clear();
            setState(() {
              _selectedCategory = '';
              _isPublic = true;
              _showSuccessMessage = true;
              _showFailMessage = false;
            });

            _successAnimationController.forward();

            Future.delayed(Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showSuccessMessage = false;
                });
                _successAnimationController.reset();
              }
            });
          } else {
            print('Question submission failed');
            setState(() {
              _showFailMessage = true;
              _showSuccessMessage = false;
            });
            Future.delayed(Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showFailMessage = false;
                });
              }
            });
          }
        } else {
          print(response.reasonPhrase);
          setState(() {
            _showFailMessage = true;
            _showSuccessMessage = false;
          });
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showFailMessage = false;
              });
            }
          });
        }
      } catch (e) {
        print('Error submitting question: $e');
        setState(() {
          _showFailMessage = true;
          _showSuccessMessage = false;
        });
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showFailMessage = false;
            });
          }
        });
      }
    }
  }

  Future<List<String>> extractTagsFromQuestionGemini(
    String questionText,
  ) async {
    final prompt =
        'Extract 3-5 relevant tags (single words or short phrases) from the following question. Return ONLY a JSON array of strings, e.g. ["tag1", "tag2", "tag3"]. Question: "$questionText"';

    final completer = Completer<List<String>>();
    StringBuffer buffer = StringBuffer();

    Gemini.instance
        .promptStream(parts: [Part.text(prompt)])
        .listen(
          (value) {
            if (value?.output != null) {
              buffer.write(value!.output);
            }
          },
          onDone: () {
            try {
              final output = buffer.toString();
              final jsonStart = output.indexOf('[');
              final jsonEnd = output.lastIndexOf(']');
              if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
                final jsonString = output.substring(jsonStart, jsonEnd + 1);
                final List<dynamic> tags = jsonDecode(jsonString);
                completer.complete(tags.whereType<String>().toList());
                return;
              }
              // Fallback: try to parse the whole output as JSON
              try {
                final List<dynamic> tags = jsonDecode(output);
                completer.complete(tags.whereType<String>().toList());
              } catch (_) {
                completer.complete([]);
              }
            } catch (e) {
              print('Error extracting tags from Gemini: $e');
              completer.complete([]);
            }
          },
          onError: (e) {
            print('Error extracting tags from Gemini: $e');
            completer.complete([]);
          },
        );

    return completer.future;
  }

  // Generate AI answer from Gemini for submission
  Future<String> generateAIAnswerGemini(String questionText) async {
    final prompt =
        'Provide a concise, clear Islamic answer to the following question. Question: "$questionText"';
    StringBuffer buffer = StringBuffer();
    final completer = Completer<String>();
    Gemini.instance
        .promptStream(parts: [Part.text(prompt)])
        .listen(
          (value) {
            if (value?.output != null) {
              buffer.write(value!.output);
            }
          },
          onDone: () {
            completer.complete(buffer.toString());
          },
          onError: (e) {
            print('Error fetching AI answer from Gemini: $e');
            completer.complete('');
          },
        );
    return await completer.future;
  }

  List<Map<String, dynamic>> _getFilteredCommunityQuestions() {
    if (_searchQuery.isEmpty) {
      return _communityQuestions;
    }
    return _communityQuestions
        .where(
          (q) =>
              q['text'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              q['category'].toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // Helper: Sort community questions by tag similarity, freshness, location, answers
  List<Map<String, dynamic>> sortCommunityQuestions(
    List<Map<String, dynamic>> questions,
    String userCountry,
    List<String> userTags,
  ) {
    int tagSimilarity(List<String> qTags) {
      if (userTags.isEmpty || qTags.isEmpty) return 0;
      return qTags.where((tag) => userTags.contains(tag)).length;
    }

    int locationScore(String? qCountry) {
      if (qCountry == null) return 0;
      return qCountry.toLowerCase() == userCountry.toLowerCase() ? 1 : 0;
    }

    int freshnessScore(String createdAt) {
      final date = DateTime.tryParse(createdAt) ?? DateTime(1970);
      return -date.millisecondsSinceEpoch;
    }

    questions.sort((a, b) {
      int tagA = tagSimilarity(List<String>.from(a['tags'] ?? []));
      int tagB = tagSimilarity(List<String>.from(b['tags'] ?? []));
      int locA = locationScore(a['askedBy']?['country']);
      int locB = locationScore(b['askedBy']?['country']);
      int freshA = freshnessScore(a['createdAt'] ?? '');
      int freshB = freshnessScore(b['createdAt'] ?? '');
      int ansA = a['answers'] ?? 0;
      int ansB = b['answers'] ?? 0;
      // Weighted sum (adjust weights as needed)
      int scoreA = tagA * 100 + locA * 50 + freshA ~/ 1000000 + ansA;
      int scoreB = tagB * 100 + locB * 50 + freshB ~/ 1000000 + ansB;
      return scoreB.compareTo(scoreA);
    });
    return questions;
  }

  void _getCommunityAndRecentQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      var response = await http.get(
        Uri.parse(publicQuestions),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      //Todo: make sure the country of askedby{country:} is returned
      print("response of get all public questions: ${response.statusCode}");
      print("questions field: ${data['question']}");
      if (response.statusCode == 200) {
        if (data['status'] == true) {
          final questions = data['question'];
          print("questions field: $questions");
          if (questions is List) {
            List<Map<String, dynamic>> updatedQuestions = [];
            for (var question in questions) {
              // askedBy is a String or Map in backend, convert to Map for UI
              final askedByRaw = question['askedBy'];
              Map<String, dynamic> askedBy;
              if (askedByRaw is String) {
                askedBy = {'id': askedByRaw, 'displayName': askedByRaw};
              } else if (askedByRaw is Map) {
                askedBy = {
                  'id': askedByRaw['id'] ?? '',
                  'displayName': askedByRaw['displayName'] ?? '',
                  'country': askedByRaw['country'] ?? '',
                };
              } else {
                askedBy = {'id': '', 'displayName': '', 'country': ''};
              }
              updatedQuestions.add({
                'questionId': question['questionId'] ?? question['_id'] ?? '',
                'text': question['text'] ?? '',
                'isPublic': question['isPublic'] ?? true,
                'askedBy': askedBy,
                'createdAt':
                    question['createdAt'] ?? DateTime.now().toIso8601String(),
                'aiAnswer': question['aiAnswer'] ?? '',
                'topAnswerId': question['topAnswerId'] ?? '',
                'tags': question['tags'] ?? [],
                'category': question['category'] ?? '',
                '_id': question['_id'] ?? '',
                '__v': question['__v'] ?? 0,
                // UI compatibility fields
                'timeAgo': 'Just now',
                'answers': 0,
                'responseType':
                    (question['topAnswerId'] == null ||
                            question['topAnswerId'].toString().isEmpty)
                        ? 'ai'
                        : 'human',
                'isAnswered':
                    (question['topAnswerId'] != null &&
                        question['topAnswerId'].toString().isNotEmpty),
                'answeredBy': askedBy['displayName'],
              });
            }
            // Extract tags from all questions in _myQuestions
            final Set<String> userTagsSet = {};
            for (final q in _myQuestions) {
              final tags = q['tags'];
              if (tags is List) {
                userTagsSet.addAll(tags.map((e) => e.toString()));
              }
            }
            List<String> userTags = userTagsSet.toList();
            updatedQuestions = sortCommunityQuestions(
              updatedQuestions,
              userProvider.user!['country'] ?? '',
              userTags,
            );
            setState(() {
              _communityQuestions = updatedQuestions;
              _recentQuestions = List<Map<String, dynamic>>.from(
                updatedQuestions,
              )..sort((a, b) {
                final aDate =
                    DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
                final bDate =
                    DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
                return bDate.compareTo(aDate); // descending: newest first
              });
            });
            print("recomended questions to user $updatedQuestions");
          } else {
            setState(() {
              _communityQuestions = [];
              _recentQuestions = [];
            });
            print('No questions found or questions is not a List.');
            return;
          }
        } else {
          print("community qustions faild to load");
        }
      }
    } catch (e) {
      setState(() {
        _communityQuestions = [];
        _recentQuestions = [];
      });
      print('Error loading community questions: $e');
    }
  }

  // Get favorite questions for the user by matching savedQuestions IDs with questions in _recentQuestions and _communityQuestions
  void getFavoriteQuestions() async {
    if (userProvider == null) return;
    final savedIds = (userProvider!.user?['savedQuestions'] ?? []) as List?;
    if (savedIds == null || savedIds.isEmpty) {
      print("no saved questions for this user");
      setState(() {
        _favoriteQuestions = [];
      });
      return;
    }
    final Set<String> idSet = savedIds.map((e) => e.toString()).toSet();
    // Combine recent and community questions for search
    final allQuestions = [..._recentQuestions];
    // Use a set to avoid duplicates
    final Set<String> seen = {};
    final List<Map<String, dynamic>> favorites = [];
    for (final q in allQuestions) {
      final qid = q['questionId'] ?? q['_id'] ?? '';
      if (idSet.contains(qid) && !seen.contains(qid)) {
        favorites.add(q);
        seen.add(qid);
      }
    }
    // For any missing favorite IDs, fetch from backend
    final missingIds = idSet.difference(seen);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //Todo:check this request to get favorite private questions
    for (final id in missingIds) {
      try {
        final response = await http.get(
          Uri.parse('question/$id'),
          headers: {
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true && data['question'] != null) {
            final question = data['question'];
            // askedBy may be a String or Map
            final askedByRaw = question['askedBy'];
            Map<String, dynamic> askedBy;
            if (askedByRaw is String) {
              askedBy = {'id': askedByRaw, 'displayName': askedByRaw};
            } else if (askedByRaw is Map) {
              askedBy = {
                'id': askedByRaw['id'] ?? '',
                'displayName': askedByRaw['displayName'] ?? '',
                'country': askedByRaw['country'] ?? '',
              };
            } else {
              askedBy = {'id': '', 'displayName': '', 'country': ''};
            }
            favorites.add({
              'questionId': question['questionId'] ?? question['_id'] ?? '',
              'text': question['text'] ?? '',
              'isPublic': question['isPublic'] ?? true,
              'askedBy': askedBy,
              'createdAt':
                  question['createdAt'] ?? DateTime.now().toIso8601String(),
              'aiAnswer': question['aiAnswer'] ?? '',
              'topAnswerId': question['topAnswerId'] ?? '',
              'tags': question['tags'] ?? [],
              'category': question['category'] ?? '',
              '_id': question['_id'] ?? '',
              '__v': question['__v'] ?? 0,
              // UI compatibility fields
              'timeAgo': 'Just now',
              'answers': 0,
              'responseType':
                  (question['topAnswerId'] == null ||
                          question['topAnswerId'].toString().isEmpty)
                      ? 'ai'
                      : 'human',
              'isAnswered':
                  (question['topAnswerId'] != null &&
                      question['topAnswerId'].toString().isNotEmpty),
              'answeredBy': askedBy['displayName'],
            });
          }
        }
      } catch (e) {
        print('Error fetching favorite question $id: $e');
      }
    }
    setState(() {
      _favoriteQuestions = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SingleChildScrollView(
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

            // Tabbed Interface
            _buildTabbedInterface(),
            SizedBox(height: 24),

            // Recent Questions
            _buildRecentQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask Your Question',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF104C34),
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 8),
          Text(
            'Get guidance from certified Islamic scholars and volunteers',
            style: TextStyle(color: Color(0xFF206F4F)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm() {
    bool isValid =
        _selectedCategory.isNotEmpty &&
        _questionController.text.trim().isNotEmpty;

    return Card(
      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
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
                        color: Color.fromARGB(255, 255, 255, 255),
                        border: Border.all(color: Color(0xFFBFE3D5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF206F4F),
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
            if (_showFailMessage)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE6E6),
                  border: Border.all(color: Color(0xFFD32F2F)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Failed to submit question. Please try again.',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
                      style: TextStyle(fontSize: 12, color: Color(0xFF206F4F)),
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
          onChanged: (value) {
            setState(() {});
          },
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
                  'Every question is welcome!',
                  ' Ask with sincerity and respect.,'
                      'Be clear and focused.',
                  'Choose the most relevant category.',
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
                .map((question) => QuestionCard(question: question))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabbedInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Questions & Answers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF104C34),
          ),
        ),
        SizedBox(height: 20),

        Card(
          color: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Color(0xFFBFE3D5)),
          ),
          elevation: 8,
          child: Column(
            children: [
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFBFE3D5), width: 1),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Check if screen is wide enough to fit all tabs
                    bool isWideScreen = constraints.maxWidth > 600;

                    return TabBar(
                      controller: _tabController,
                      labelColor: Color(0xFF206F4F),
                      unselectedLabelColor: Color(0xFF45A376),
                      indicatorColor: Color(0xFF2D8662),
                      indicatorWeight: 3,
                      isScrollable: !isWideScreen,
                      labelPadding:
                          isWideScreen
                              ? EdgeInsets.symmetric(horizontal: 16)
                              : EdgeInsets.symmetric(horizontal: 8),
                      labelStyle: TextStyle(
                        fontSize: isWideScreen ? 14 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: isWideScreen ? 14 : 13,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.question_answer, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Community',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              SizedBox(width: 2),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE6F3ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_communityQuestions.length}',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'My Questions',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              SizedBox(width: 2),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE6F3ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_myQuestions.length}',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Favorites',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              SizedBox(width: 2),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE6F3ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_favoriteQuestions.length}',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Tab Content
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCommunityTab(),
                    _buildMyQuestionsTab(),
                    _buildFavoritesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTab() {
    List<Map<String, dynamic>> filteredQuestions =
        _getFilteredCommunityQuestions();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search community questions...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF45A376)),
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
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 16),

          // Questions List
          Expanded(
            child:
                filteredQuestions.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No community questions yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _communityQuestions.length,
                      itemBuilder: (context, index) {
                        final question = _communityQuestions[index];
                        return QuestionCard(question: question);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyQuestionsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child:
          _myQuestions.isEmpty
              ? _buildEmptyState(
                'No questions asked yet',
                'Start by asking your first question',
              )
              : ListView.builder(
                itemCount: _myQuestions.length,
                itemBuilder: (context, index) {
                  final question = _myQuestions[index];
                  // No need to generate AI answer here; it is included in the backend response
                  return QuestionCard(question: question);
                },
              ),
    );
  }

  Widget _buildFavoritesTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child:
          _favoriteQuestions.isEmpty
              ? _buildEmptyState(
                'No favorite questions',
                'Save questions you find helpful',
              )
              : ListView.builder(
                itemCount: _favoriteQuestions.length,
                itemBuilder: (context, index) {
                  return QuestionCard(question: _favoriteQuestions[index]);
                },
              ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_answer, size: 64, color: Color(0xFF93C5AE)),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF104C34),
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Color(0xFF206F4F)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
