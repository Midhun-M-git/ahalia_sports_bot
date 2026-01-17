import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'tournament_screen.dart';

class ChatScreen extends StatefulWidget {
  final String sportType;

  const ChatScreen({super.key, required this.sportType});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late final ChatService _chatService;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(
      widget.sportType,
      onShowTournament: (teams, fixtures) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentScreen(
              teams: teams,
              fixtures: fixtures,
            ),
          ),
        );
      },
    );
    _addBotMessage('Welcome to Ahalia ${widget.sportType.toUpperCase()} Bot! How can I help you create your team?');
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _handleSubmitted(String text) async {
    _messageController.clear();

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    final response = await _chatService.getChatResponse(text);
    _addBotMessage(response);

    // If commentary mode is activated
    if (response.contains('Starting commentary mode')) {
      _startVoiceCommentary();
    }
  }

  void _startVoiceCommentary() async {
    setState(() {
      _isListening = true;
    });

    await _chatService.startListening((String result) {
      if (result.isNotEmpty) {
        _handleSubmitted(result);
      }
      setState(() {
        _isListening = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ahalia ${widget.sportType.toUpperCase()} Bot'),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _isListening ? null : _startVoiceCommentary,
            color: _isListening ? Colors.red : Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A237E).withOpacity(0.1),
                    const Color(0xFF121212),
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return _buildMessage(message);
                },
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  widget.sportType == 'cricket'
                      ? Icons.sports_cricket
                      : Icons.sports_soccer,
                  color: Colors.white,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : isDark
                        ? Theme.of(context).cardColor
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: 'Ask me to create your team...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => _handleSubmitted(_messageController.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatService.stopListening();
    super.dispose();
  }
}
