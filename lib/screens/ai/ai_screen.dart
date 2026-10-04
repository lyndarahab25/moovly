import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  // OLLAMA
  // ============================================================

  // Pour Flutter exécuté sur Windows / PC.
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';

  static const String _model = 'qwen3:4b';

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
            const Text(
              "Moovly AI",
              style: TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
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
  // MESSAGES
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
              color: Colors.black.withOpacity(0.025),
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            SizedBox(width: 5),
            _Dot(),
            SizedBox(width: 5),
            _Dot(),
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
            borderRadius: BorderRadius.circular(20),
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
            color: Colors.black.withOpacity(0.04),
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
                onSubmitted: _sendMessage,
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

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isTyping) {
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

    final response = await _getAiResponse(
      cleanMessage,
    );

    if (!mounted) return;

    setState(() {
      _isTyping = false;

      _messages.add({
        "sender": "ai",
        "text": response,
      });
    });

    _scrollToBottom();
  }

  // ============================================================
  // REAL AI RESPONSE
  // ============================================================

  Future<String> _getAiResponse(
    String message,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_ollamaUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,

              // Prompt principal
              'prompt': '''
Tu es Moovly AI, l'assistant intelligent
de l'application mobile Moovly.

Moovly est une plateforme de mobilité urbaine
destinée notamment aux déplacements à Bouira,
en Algérie.

Tu aides les utilisateurs concernant :
- les lignes de bus ;
- les trajets ;
- les déplacements urbains ;
- les bus à proximité ;
- les tickets ;
- les paiements par QR code ;
- les abonnements Moovly ;
- les cartes Moovly ;
- les fonctionnalités de l'application.

Les abonnements Moovly sont :
- Premium : suppression des publicités et
  notifications avancées.
- Gold : fonctionnalités Premium + Moovly AI +
  suggestions intelligentes + accès au suivi
  en temps réel des bus lorsqu'il est disponible.

RÈGLES IMPORTANTES :

1. Réponds en français si l'utilisateur écrit
   en français.

2. Sois naturel, clair et concis.

3. Ne prétends jamais avoir accès à une donnée
   en temps réel si elle ne t'est pas fournie.

4. Ne crée pas de lignes, horaires, prix ou
   informations de transport imaginaires.

5. Si une information précise n'est pas disponible,
   dis-le clairement.

6. Tu es l'assistant intégré à Moovly.

7. Ne parle pas d'Ollama ou de Qwen sauf si
   l'utilisateur demande explicitement des
   informations techniques sur ton fonctionnement.

Question de l'utilisateur :
$message
''',

              // IMPORTANT pour Qwen3 :
              // on ne veut pas afficher son raisonnement
              // dans l'application.
              'think': false,

              // Une seule réponse complète.
              'stream': false,
            }),
          )
          .timeout(
            const Duration(seconds: 120),
          );

      if (response.statusCode != 200) {
        debugPrint(
          'OLLAMA ERROR ${response.statusCode}: ${response.body}',
        );

        return "Désolé, Moovly AI rencontre actuellement "
            "un problème de connexion. Veuillez réessayer.";
      }

      final data = jsonDecode(response.body);

      String answer = (data['response'] ?? '').toString().trim();

      if (answer.isEmpty) {
        return "Je n'ai pas pu générer une réponse "
            "pour le moment. Veuillez réessayer.";
      }

      answer = _cleanAiResponse(answer);

      if (answer.isEmpty) {
        return "Je n'ai pas pu générer une réponse "
            "pour le moment. Veuillez réessayer.";
      }

      return answer;
    } catch (e) {
      debugPrint(
        'OLLAMA CONNECTION ERROR: $e',
      );

      return "Je ne peux pas contacter Moovly AI "
          "pour le moment.\n\n"
          "Vérifiez que le service Moovly AI est "
          "bien démarré sur votre ordinateur.";
    }
  }

  // ============================================================
  // CLEAN RESPONSE
  // ============================================================

  String _cleanAiResponse(String response) {
    String cleaned = response;

    // Supprime correctement les blocs <think>...</think>
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<think>[\s\S]*?</think>',
        caseSensitive: false,
      ),
      '',
    );

    return cleaned.trim();
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
        duration: const Duration(
          milliseconds: 300,
        ),
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
            "Comment puis-je vous aider aujourd'hui ?",
      });
    });

    _scrollToBottom();
  }
}

// ============================================================
// TYPING DOT
// ============================================================

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 7,
      height: 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF64748B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
