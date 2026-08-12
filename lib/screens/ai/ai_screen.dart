import 'package:flutter/material.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF1953FF);
  static const Color purple = Color(0xFF6C3BFF);
  static const Color background = Color(0xFFF7F9FC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // MESSAGES
  // ============================================================

  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text": "Bonjour 👋 Je suis Moovly AI.\n\n"
          "Je peux vous aider à planifier vos déplacements, "
          "trouver une ligne de bus et optimiser votre trajet.",
    },
  ];

  bool _isTyping = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: dark,
            size: 21,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    primaryBlue,
                    purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Moovly AI",
                  style: TextStyle(
                    color: dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: border,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _clearConversation,
              icon: const Icon(
                Icons.refresh_rounded,
                color: dark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessages(),
            ),
            _buildSuggestions(),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGES LIST
  // ============================================================

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        20,
      ),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];

        final bool isUser = message["sender"] == "user";

        return _buildMessageBubble(
          message["text"] ?? "",
          isUser,
        );
      },
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(
    String text,
    bool isUser,
  ) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [
                    primaryBlue,
                    Color(0xFF3158D9),
                  ],
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isUser ? 18 : 5,
            ),
            bottomRight: Radius.circular(
              isUser ? 5 : 18,
            ),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: border,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.025,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : dark,
            fontSize: 13.5,
            height: 1.45,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TYPING
  // ============================================================

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: border,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 7,
              height: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: muted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 5),
            SizedBox(
              width: 7,
              height: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: muted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 5),
            SizedBox(
              width: 7,
              height: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: muted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUGGESTIONS
  // ============================================================

  Widget _buildSuggestions() {
    final suggestions = [
      "Quel bus prendre ?",
      "Planifier mon trajet",
      "Bus à proximité",
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _sendMessage(
                suggestions[index],
              );
            },
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: border,
                ),
              ),
              child: Text(
                suggestions[index],
                style: const TextStyle(
                  color: dark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        9,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: border,
                ),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  _sendMessage(value);
                },
                decoration: const InputDecoration(
                  hintText: "Demandez quelque chose à Moovly AI...",
                  hintStyle: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _sendMessage(
                _messageController.text,
              );
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue,
                    purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  void _sendMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }

    final cleanMessage = message.trim();

    setState(() {
      _messages.add({
        "sender": "user",
        "text": cleanMessage,
      });

      _messageController.clear();

      _isTyping = true;
    });

    _scrollToBottom();

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) return;

        setState(() {
          _isTyping = false;

          _messages.add({
            "sender": "ai",
            "text": _getAiResponse(
              cleanMessage,
            ),
          });
        });

        _scrollToBottom();
      },
    );
  }

  // ============================================================
  // AI RESPONSE
  // ============================================================

  String _getAiResponse(String message) {
    final text = message.toLowerCase();

    if (text.contains("bus") && text.contains("proxim")) {
      return "Je peux vous aider à trouver les bus "
          "à proximité. 🚌\n\n"
          "Ouvrez la carte depuis Moovly pour voir "
          "les bus disponibles autour de vous.";
    }

    if (text.contains("trajet") ||
        text.contains("aller") ||
        text.contains("route")) {
      return "Bien sûr ! 📍\n\n"
          "Indiquez-moi votre point de départ "
          "et votre destination et je pourrai vous "
          "aider à choisir le meilleur trajet.";
    }

    if (text.contains("ligne")) {
      return "Je peux vous aider à trouver une ligne "
          "de bus adaptée à votre déplacement. 🚌\n\n"
          "Donnez-moi votre destination.";
    }

    if (text.contains("bouira")) {
      return "Moovly est conçu pour faciliter vos "
          "déplacements à Bouira. 📍\n\n"
          "Vous pouvez consulter les lignes, "
          "les bus à proximité et planifier vos trajets.";
    }

    if (text.contains("bonjour") ||
        text.contains("salut") ||
        text.contains("hello")) {
      return "Bonjour 👋\n\n"
          "Comment puis-je vous aider avec votre "
          "déplacement aujourd'hui ?";
    }

    return "Je suis Moovly AI 🤖\n\n"
        "Je peux vous aider avec vos déplacements, "
        "les lignes de bus, les trajets et les bus "
        "à proximité.\n\n"
        "Essayez par exemple : "
        "\"Quel bus prendre pour aller au centre-ville ?\"";
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _clearConversation() {
    setState(() {
      _messages.clear();

      _messages.add({
        "sender": "ai",
        "text": "Bonjour 👋 Je suis Moovly AI.\n\n"
            "Comment puis-je vous aider "
            "aujourd'hui ?",
      });
    });
  }
}
