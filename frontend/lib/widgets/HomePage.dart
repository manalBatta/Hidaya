// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/utils/auth_utils.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ImmersiveAIChat());
  }
}

class ChatMessage {
  final String type;
  final String content;

  ChatMessage({required this.type, required this.content});
}

class ParsedAIMessage {
  final String cleanMessage;
  final List<String> suggestions;

  ParsedAIMessage({required this.cleanMessage, required this.suggestions});
}

ParsedAIMessage extractSuggestions(String aiMessage) {
  final suggestions = <String>[];
  final suggestionsStart = aiMessage.indexOf("Suggestions:");

  if (suggestionsStart == -1) {
    return ParsedAIMessage(cleanMessage: aiMessage.trim(), suggestions: []);
  }

  final messageWithoutSuggestions =
      aiMessage.substring(0, suggestionsStart).trim();
  final suggestionsText = aiMessage.substring(
    suggestionsStart + "Suggestions:".length,
  );
  final lines = suggestionsText.split('\n');

  for (var line in lines) {
    final trimmed = line.trim().replaceFirst(RegExp(r'^[-•*]\s*'), '');
    if (trimmed.isNotEmpty) {
      suggestions.add(trimmed);
    }
  }

  return ParsedAIMessage(
    cleanMessage: messageWithoutSuggestions,
    suggestions: suggestions,
  );
}

class ImmersiveAIChat extends StatefulWidget {
  final VoidCallback? onClose;

  const ImmersiveAIChat({super.key, this.onClose});

  @override
  State<ImmersiveAIChat> createState() => _ImmersiveAIChatState();
}

class _ImmersiveAIChatState extends State<ImmersiveAIChat>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isResponding = false;
  bool _isTyping = false;
  String _typingText = "";
  bool _isDarkMode = false;
  bool _isMuted = true;
  bool _showSettings = false;

  // Animation properties
  late AnimationController _waveController;
  late AnimationController _pulseController;
  double _waveAmplitude = 0.3;
  double _waveFrequency = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeChatSession();
    _inputController.addListener(() {
      setState(() {}); // Rebuilds the widget when the input changes
    });
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChatSession() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!mounted) return;
    try {
      final token = await AuthUtils.getValidToken(context);

      final response = await http.post(
        Uri.parse(startChat),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userProvider.userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        userProvider.setSessionId(data['sessionId']);
        _scrollToBottom();
        await _typeAIResponse(data["greeting"]);
        _scrollToBottom();
      } else {
        // handle failure
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start sission')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendMessage([String? message]) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sessionId = userProvider.sessionId;

    if ((message == null && _inputController.text.trim().isEmpty) ||
        sessionId == null) {
      return;
    }
    final content = message ?? _inputController.text.trim();
    final userMessage = ChatMessage(type: 'user', content: content);

    if (!mounted) return;
    setState(() {
      userProvider.addMessage(userMessage);
      _isResponding = true;
      _waveAmplitude = 0.8;
      _waveFrequency = 2.0;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final token = await AuthUtils.getValidToken(context);

      final response = await http.post(
        Uri.parse(sendChat),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userProvider.userId,
          "sessionId": sessionId,
          "message": content,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["reply"] != null) {
        _scrollToBottom();
        await _typeAIResponse(data["reply"]);
        _scrollToBottom();
      } else {
        // Handle error or missing reply
        await _typeAIResponse(
          "I'm sorry, I couldn't process your question at the moment. Please try again, or ask another question about Islam and I'll do my best to help you.",
        );
      }
      print("answer is : $data");
      _scrollToBottom();
    } catch (e) {
      debugPrint('Failed to send message: $e');
      await _typeAIResponse(
        "I'm sorry, I couldn't process your question at the moment. Please try again, or ask another question about Islam and I'll do my best to help you.",
      );
      _scrollToBottom();
    } finally {
      if (!mounted) return;
      setState(() {
        _isResponding = false;
        _waveAmplitude = 0.3;
        _waveFrequency = 1.0;
      });
    }
  }

  Future<void> _typeAIResponse(String response) async {
    if (!mounted) return;

    // Parse the message and suggestions
    final parsed = extractSuggestions(response);
    final cleanResponse = parsed.cleanMessage;
    final suggestions = parsed.suggestions;

    setState(() {
      _isTyping = true;
      _typingText = "";
      _waveAmplitude = 0.6;
      _waveFrequency = 1.5;
    });

    for (int i = 0; i <= cleanResponse.length; i++) {
      if (mounted) {
        setState(() {
          _typingText = cleanResponse.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 30));
      } else {
        return;
      }
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        // Add the AI message (without suggestions)
        userProvider.addMessage(
          ChatMessage(type: 'ai', content: cleanResponse),
        );

        // Add each suggestion as a button (custom message type)
        for (var suggestion in suggestions) {
          userProvider.addMessage(
            ChatMessage(type: 'suggestion', content: suggestion),
          );
        }

        _isTyping = false;
        _typingText = "";
        _waveAmplitude = 0.3;
        _waveFrequency = 1.0;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildAnimatedWaveform() {
    return Container(
      width: double.infinity,
      height: 128,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(
              progress: _waveController.value,
              amplitude: _waveAmplitude,
              frequency: _waveFrequency,
              isDarkMode: _isDarkMode,
              isResponding: _isResponding,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.type == 'user';
    if (message.type == 'suggestion') {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isDarkMode
                      ? Colors.green.shade700.withOpacity(0.9)
                      : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              _sendMessage(message.content);
            },
            child: Text(
              message.content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? (_isDarkMode
                            ? Colors.green.shade600.withOpacity(0.8)
                            : const Color(0xFF059669).withOpacity(0.9))
                        : (_isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8)),
                borderRadius: BorderRadius.circular(24).copyWith(
                  bottomRight: isUser ? const Radius.circular(8) : null,
                  bottomLeft: !isUser ? const Radius.circular(8) : null,
                ),
                border:
                    !isUser
                        ? Border.all(
                          color:
                              _isDarkMode
                                  ? Colors.green.shade600.withOpacity(0.3)
                                  : const Color(0xFF059669).withOpacity(0.2),
                          width: 1,
                        )
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: null,
                    style: TextStyle(
                      color:
                          isUser
                              ? Colors.white
                              : (_isDarkMode
                                  ? Colors.grey.shade100
                                  : const Color(0xFF064E3B)),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width *
                    0.5, // Match message bubble
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    _isDarkMode
                        ? Colors.grey.shade800.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(
                  24,
                ).copyWith(bottomLeft: const Radius.circular(8)),
                border: Border.all(
                  color:
                      _isDarkMode
                          ? Colors.green.shade600.withOpacity(0.3)
                          : const Color(0xFF059669).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _typingText + ((_typingText.isNotEmpty) ? "|" : ""),
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: null,
                style: TextStyle(
                  color:
                      _isDarkMode
                          ? Colors.grey.shade100
                          : const Color(0xFF064E3B),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final messages = userProvider.messages;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                _isDarkMode
                    ? [
                      const Color(0xFF111827),
                      const Color(0xFF064E3B),
                      const Color(0xFF1F2937),
                    ]
                    : [
                      const Color(0xFFF0FDF4),
                      const Color(0xFFFFFBEB),
                      const Color(0xFFFEFCE8),
                    ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),

                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask About Islam',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                _isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF064E3B),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isDarkMode
                                    ? Colors.green.shade800
                                    : const Color(0xFF059669).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'AI Islamic Guide',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _isDarkMode
                                      ? Colors.green.shade100
                                      : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    /*  IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color:
                            _isDarkMode
                                ? Colors.white
                                : const Color(0xFF059669),
                      ),
                    ),
                    
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      icon: Icon(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color:
                            _isDarkMode
                                ? Colors.white
                                : const Color(0xFF059669),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSettings = !_showSettings;
                        });
                      },
                      icon: Icon(
                        Icons.settings,
                        color:
                            _isDarkMode
                                ? Colors.white
                                : const Color(0xFF059669),
                      ),
                    ), */
                    IconButton(
                      onPressed: () async {
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        userProvider.clearMessages();
                      },
                      icon: Icon(
                        Icons.add_comment,
                        color:
                            _isDarkMode
                                ? Colors.white
                                : const Color(0xFF059669),
                      ),
                      tooltip: 'New Chat',
                    ),
                    if (widget.onClose != null)
                      IconButton(
                        onPressed: widget.onClose,
                        icon: Icon(
                          Icons.close,
                          color:
                              _isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF059669),
                        ),
                      ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Waveform Section
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnimatedWaveform(),
                            const SizedBox(height: 32),
                            if (_isResponding)
                              Text(
                                'AI is responding...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF059669),
                                ),
                              )
                            else if (_isTyping)
                              Text(
                                'Typing response...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      _isDarkMode
                                          ? Colors.green.shade300
                                          : const Color(0xFF059669),
                                ),
                              )
                            else if (messages.isEmpty)
                              Column(
                                children: [
                                  Text(
                                    'Welcome to the immersive Islamic AI experience',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          _isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF064E3B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ask me anything about Islam, and I\'ll guide you with wisdom from the Quran and Sunnah',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          _isDarkMode
                                              ? Colors.grey.shade300
                                              : const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Chat Section
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: (_isDarkMode ? Colors.black : Colors.white)
                            .withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Messages
                          Expanded(
                            child:
                                messages.isEmpty && !_isTyping
                                    ? _buildSuggestions()
                                    : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16),
                                      itemCount:
                                          messages.length + (_isTyping ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index < messages.length) {
                                          return _buildMessageBubble(
                                            messages[index],
                                            index,
                                          );
                                        } else {
                                          return _buildTypingIndicator();
                                        }
                                      },
                                    ),
                          ),

                          // Input Area
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (_isDarkMode ? Colors.black : Colors.white)
                                  .withOpacity(0.3),
                              border: Border(
                                top: BorderSide(
                                  color:
                                      _isDarkMode
                                          ? Colors.green.shade600.withOpacity(
                                            0.3,
                                          )
                                          : const Color(
                                            0xFF059669,
                                          ).withOpacity(0.2),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (_isDarkMode
                                              ? Colors.grey.shade800
                                              : Colors.white)
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color:
                                            _isDarkMode
                                                ? Colors.green.shade600
                                                    .withOpacity(0.3)
                                                : const Color(
                                                  0xFF059669,
                                                ).withOpacity(0.2),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _inputController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Ask a question about Islam...',
                                        hintStyle: TextStyle(
                                          color:
                                              _isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                        /* suffixIcon: IconButton(
                                          onPressed: () {
                                            // Voice input functionality
                                          },
                                          icon: Icon(
                                            Icons.mic,
                                            color:
                                                _isDarkMode
                                                    ? Colors.green.shade400
                                                    : const Color(0xFF059669),
                                          ),
                                        ), */
                                      ),
                                      style: TextStyle(
                                        color:
                                            _isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF064E3B),
                                        fontSize: 16,
                                      ),
                                      enabled: !_isResponding,
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _isDarkMode
                                            ? Colors.green.shade600
                                            : const Color(0xFF059669),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: IconButton(
                                    onPressed:
                                        _inputController.text.trim().isEmpty ||
                                                _isResponding
                                            ? null
                                            : _sendMessage,
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  }

  Widget _buildSuggestions() {
    final suggestions = [
      "How do I perform Wudu?",
      "Tell me about the Five Pillars",
      "When are the prayer times?",
      "What is the significance of Ramadan?",
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              suggestions.map((suggestion) {
                return OutlinedButton(
                  onPressed: () {
                    _inputController.text = suggestion;
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color:
                          _isDarkMode
                              ? Colors.green.shade600
                              : const Color(0xFF059669).withOpacity(0.3),
                    ),
                    foregroundColor:
                        _isDarkMode
                            ? Colors.green.shade100
                            : const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(suggestion),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final double amplitude;
  final double frequency;
  final bool isDarkMode;
  final bool isResponding;

  WaveformPainter({
    required this.progress,
    required this.amplitude,
    required this.frequency,
    required this.isDarkMode,
    required this.isResponding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isDarkMode ? Colors.green.shade400 : const Color(0xFF059669)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final secondaryPaint =
        Paint()
          ..color = (isDarkMode
                  ? Colors.green.shade300
                  : const Color(0xFF6EE7B7))
              .withOpacity(0.6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final tertiaryPaint =
        Paint()
          ..color = (isDarkMode
                  ? Colors.green.shade200
                  : const Color(0xFFA7F3D0))
              .withOpacity(0.4)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final path = Path();
    final secondaryPath = Path();
    final tertiaryPath = Path();

    final centerY = size.height / 2;
    final timeOffset = progress * 2 * pi * frequency;

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = (x / size.width) * 4 * pi * frequency;

      final y =
          centerY +
          sin(normalizedX + timeOffset) * amplitude * 20 +
          sin(normalizedX * 2 + timeOffset * 1.5) * amplitude * 10 +
          sin(normalizedX * 0.5 + timeOffset * 0.8) * amplitude * 15;

      final secondaryY =
          centerY +
          sin(normalizedX + timeOffset + pi / 3) * amplitude * 0.6 * 20 +
          sin(normalizedX * 2 + timeOffset * 1.5 + pi / 3) *
              amplitude *
              0.6 *
              10;

      final tertiaryY =
          centerY +
          sin(normalizedX + timeOffset + pi / 6) * amplitude * 0.3 * 20 +
          sin(normalizedX * 2 + timeOffset * 1.5 + pi / 6) *
              amplitude *
              0.3 *
              10;

      if (x == 0) {
        path.moveTo(x, y);
        secondaryPath.moveTo(x, secondaryY);
        tertiaryPath.moveTo(x, tertiaryY);
      } else {
        path.lineTo(x, y);
        secondaryPath.lineTo(x, secondaryY);
        tertiaryPath.lineTo(x, tertiaryY);
      }
    }

    canvas.drawPath(tertiaryPath, tertiaryPaint);
    canvas.drawPath(secondaryPath, secondaryPaint);
    canvas.drawPath(path, paint);

    // Draw pulsing dots when responding
    if (isResponding) {
      final dotPaint =
          Paint()
            ..color =
                isDarkMode ? Colors.green.shade400 : const Color(0xFF059669)
            ..style = PaintingStyle.fill;

      final positions = [0.25, 0.5, 0.75];
      for (int i = 0; i < positions.length; i++) {
        final opacity = (sin(progress * 2 * pi + i * pi / 2) + 1) / 2;
        dotPaint.color = (isDarkMode
                ? Colors.green.shade400
                : const Color(0xFF059669))
            .withOpacity(opacity * 0.8);
        canvas.drawCircle(
          Offset(size.width * positions[i], centerY),
          4,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
