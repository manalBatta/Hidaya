import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:frontend/constants/colors.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LessonsPage.dart';
import 'Stories/Story.dart';
import 'Qustions.dart';
import '../providers/NavigationProvider.dart';
import '../config.dart';

class Joke {
  final String id;
  final String content;
  final String reson;
  final int likes;
  final int dislikes;
  final DateTime createdAt;

  Joke({
    required this.id,
    required this.content,
    required this.reson,
    required this.likes,
    required this.dislikes,
    required this.createdAt,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      content: json['content'] ?? '',
      reson: json['reson'] ?? '',
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class OnboardingProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _jokesKey = GlobalKey();
  final GlobalKey _dressCodeKey = GlobalKey();
  
  List<Joke> jokes = [];
  bool isLoadingJokes = false;

  void scrollToAbout() {
    final context = _aboutKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToJokes() {
    _loadJokes();
    final context = _jokesKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToDressCode() {
    final context = _dressCodeKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadJokes() async {
    if (isLoadingJokes) return;
    setState(() { isLoadingJokes = true; });

    try {
      final response = await http.get(
        Uri.parse('${jokesUrl}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> jokesJson = data['jokes'] ?? [];
          setState(() {
            jokes = jokesJson.map((json) => Joke.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      print("Error loading jokes: $e");
    } finally {
      setState(() { isLoadingJokes = false; });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<OnboardingProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.grey900 : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    "Welcome to Hidaya",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      TyperAnimatedText(
                        "Read.",
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      TyperAnimatedText(
                        "Learn.",
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      TyperAnimatedText(
                        "Reflect.",
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      TyperAnimatedText(
                        "Grow.",
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                "What you'll discover",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FeatureCard(
                    icon: Icons.menu_book,
                    title: "Read about Hidaya",
                    description: "Learn the basics of Islam in an easy way",
                    color: isDarkMode ? AppColors.islamicGreen700 : const Color(0xFFE6F7EE),
                    iconColor: AppColors.islamicGreen700,
                    onTap: scrollToAbout,
                    isDarkMode: isDarkMode,
                  ),
                  FeatureCard(
                    icon: Icons.question_answer,
                    title: "Answers to Common Questions",
                    description: "Ask questions and get answers from certified volunteers",
                    color: isDarkMode ? AppColors.homeGreenDarker : const Color(0xFFEAF1FF),
                    iconColor: Colors.blue,
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).setMainTabIndex(2);
                    },
                    isDarkMode: isDarkMode,
                  ),
                  FeatureCard(
                    icon: Icons.school,
                    title: "Lessons",
                    description: "Practical lessons to deepen understanding ",
                    color: isDarkMode ? AppColors.islamicGreen700 : AppColors.lessonsCircle,
                    iconColor: AppColors.lessonsIcon,
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).setMainTabIndex(4);
                    },
                    isDarkMode: isDarkMode,
                  ),
                  FeatureCard(
                    icon: Icons.favorite,
                    title: "Stories",
                    description: "Inspiring real stories about people who follow the path of Allah and learn from their experiences",
                    color: isDarkMode ? AppColors.islamicGreen700 : const Color(0xFFFFF0F0),
                    iconColor: Colors.red,
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).setMainTabIndex(3);
                    },
                    isDarkMode: isDarkMode,
                  ),
                  FeatureCard(
                    icon: Icons.emoji_emotions,
                    title: "Islamic Jokes",
                    description: "Enjoy light-hearted humor about Islam for fun",
                    color: isDarkMode ? AppColors.islamicGreen700 : const Color(0xFFFFF8E1),
                    iconColor: Colors.orange,
                    onTap: scrollToJokes,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Container(
                key: _aboutKey,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.grey800 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "About the App",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.islamicGreen700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "This app provides clear and simple educational content about Islam. Its goal is to make understanding Islamic values and principles easy and accessible for everyone.Hidaya has a certified volunteer by them you can take a certified answer for any question in your mind",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Container(
                key: _jokesKey,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.grey800 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "Islamic Jokes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoadingJokes)
                      const CircularProgressIndicator()
                    else if (jokes.isEmpty)
                      Text(
                        "No jokes available at the moment",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      )
                    else
                      ...jokes.map((joke) => ApiJokeCard(
                        joke: joke,
                        isDarkMode: isDarkMode,
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.iconColor,
    this.onTap,
    required this.isDarkMode,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 180,
            height: 200,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? AppColors.grey800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: widget.color,
                  child: Icon(widget.icon, size: 30, color: widget.iconColor),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDarkMode ? Colors.grey[300] : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApiJokeCard extends StatefulWidget {
  final Joke joke;
  final bool isDarkMode;

  const ApiJokeCard({super.key, required this.joke, required this.isDarkMode});

  @override
  State<ApiJokeCard> createState() => _ApiJokeCardState();
}

class _ApiJokeCardState extends State<ApiJokeCard> {
  late int likes;
  bool isLiked = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    likes = widget.joke.likes;
  }

 

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: widget.isDarkMode ? AppColors.grey700 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "${widget.joke.content} 👉 ${widget.joke.reson}",
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
           
          ],
        ),
      ),
    );
  }
}
