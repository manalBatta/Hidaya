import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../providers/UserProvider.dart';
import '../../services/stream_chat_service.dart';

class ChatListScreen extends StatefulWidget {
  final StreamChatClient client;
  final StreamChatService? streamService;
  const ChatListScreen({Key? key, required this.client, this.streamService})
    : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  StreamChannelListController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final connectedUserId = widget.client.state.currentUser?.id;
    if (connectedUserId != null) {
      _controller = StreamChannelListController(
        client: widget.client,
        filter: Filter.in_('members', [connectedUserId]),
        channelStateSort: const [SortOption('last_message_at')],
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fallbackUserId =
          StreamChat.of(context).currentUser?.id ??
          context.read<UserProvider>().userId;
      _controller = StreamChannelListController(
        client: widget.client,
        filter: Filter.in_('members', [fallbackUserId]),
        channelStateSort: const [SortOption('last_message_at')],
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),

      body: RefreshIndicator(
        onRefresh: _controller!.refresh,
        child: StreamChannelListView(
          controller: _controller!,
          onChannelTap: (channel) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => StreamChat(
                      client: widget.client,
                      child: StreamChannel(
                        channel: channel,
                        child: const ChannelPage(),
                      ),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStartChatDialog(BuildContext context) {
    final TextEditingController userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start New Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the user ID to start a conversation:'),
              const SizedBox(height: 16),
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: 'e.g., user123',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final otherUserId = userIdController.text.trim();
                if (otherUserId.isNotEmpty) {
                  Navigator.of(context).pop();
                  _startChatWithUser(context, otherUserId);
                }
              },
              child: const Text('Start Chat'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startChatWithUser(
    BuildContext context,
    String otherUserId,
  ) async {
    final currentUserId = widget.client.state.currentUser?.id;
    if (currentUserId == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Ensure the other user exists in Stream Chat before creating channel
      if (widget.streamService != null) {
        final userExists = await widget.streamService!.ensureUserExists(
          otherUserId,
        );
        if (!userExists) {
          Navigator.of(context).pop(); // Close loading dialog
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to start chat. User not found.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      Navigator.of(context).pop(); // Close loading dialog

      final channelId = _generateShortChannelId(currentUserId, otherUserId);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => StreamChat(
                client: widget.client,
                child: StreamChannel(
                  channel: widget.client.channel(
                    'messaging',
                    id: channelId,
                    extraData: {
                      'members': [currentUserId, otherUserId],
                    },
                  ),
                  child: const ChannelPage(),
                ),
              ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      print('Error starting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateShortChannelId(String userId1, String userId2) {
    // Sort user IDs to ensure consistent channel ID regardless of order
    final sortedIds = [userId1, userId2]..sort();

    // Create a hash of the combined user IDs
    final combined = '${sortedIds[0]}_${sortedIds[1]}';
    final hash = combined.hashCode.abs();

    // Return a short channel ID (max 64 chars)
    return 'chat_$hash';
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RestorationScope(
      restorationId: 'channel_page',
      child: Scaffold(
        appBar: const StreamChannelHeader(),
        body: const StreamMessageListView(),
        bottomNavigationBar: SafeArea(
          child: StreamMessageInput(
            // Disable restoration to prevent the assertion error
            restorationId: null,
          ),
        ),
      ),
    );
  }
}
