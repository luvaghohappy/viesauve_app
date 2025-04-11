import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  // Initialisation de l'instance OpenAI
  final OpenAI _openAI = OpenAI.instance.build(
    token: dotenv.env['OPENAI_API_KEY'] ?? 'Clé API manquante',
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
    enableLog: true,
  );

  // Utilisateurs
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User');
  final ChatUser _gptChatUser = ChatUser(id: '2', firstName: 'GPT');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252535),
        title: const Text(
          'AI HEALTH CHAT',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texte blanc pour un bon contraste
          ),
        ),
      ),
      body: DashChat(
        currentUser: _currentUser,
        typingUsers: _typingUsers,
        messageOptions: const MessageOptions(
          currentUserContainerColor: Color(
            0xFF373B44,
          ), // Fond sombre pour le message utilisateur
          currentUserTextColor: Colors.white, // Texte blanc pour l'utilisateur
          containerColor: Color(
            0xFF2E2E3E,
          ), // Fond sombre pour les messages GPT
          textColor: Color.fromARGB(
            255,
            95,
            150,
            245,
          ), // Texte de GPT en vert clair
        ),
        inputOptions: InputOptions(
          inputTextStyle: const TextStyle(
            color: Colors.white,
          ), // Texte blanc dans le champ d'entrée
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: const Color(
              0xFF252535,
            ), // Fond sombre pour le champ d'entrée
            hintText: "Écrivez un message...",
            hintStyle: const TextStyle(
              color: Colors.grey,
            ), // Texte indicatif en gris
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        onSend: (ChatMessage message) {
          getChatResponse(message); // Récupération de la réponse OpenAI
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _typingUsers.add(_gptChatUser);
    });

    List<Map<String, dynamic>> _messageHistory =
        _messages.reversed.map((msg) {
          if (msg.user == _currentUser) {
            return {"role": "user", "content": msg.text};
          } else {
            return {"role": "assistant", "content": msg.text};
          }
        }).toList();

    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: _messageHistory,
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        _messages.insert(
          0,
          ChatMessage(
            user: _gptChatUser,
            createdAt: DateTime.now(),
            text: element.message!.content,
          ),
        );
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
