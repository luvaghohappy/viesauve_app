import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:siri_wave/siri_wave.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VoiceAIApp extends StatefulWidget {
  @override
  _VoiceAIAppState createState() => _VoiceAIAppState();
}

class _VoiceAIAppState extends State<VoiceAIApp> {
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _userText = "";
  String _aiResponse = "";
  String _selectedLanguage = "fr-FR";
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  void _startListening() async {
    try {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _userText = result.recognizedWords;
            });
          },
          onSoundLevelChange: (level) {
            setState(() {
              _soundLevel = level;
              _controller.amplitude = (_soundLevel / 10).clamp(0.2, 1.0);
            });
          },
          localeId: _selectedLanguage,
        );
      } else {
        _showError("Microphone non disponible. Vérifiez les permissions.");
      }
    } catch (e) {
      print("Erreur lors de l'initialisation : $e");
      _showError("Erreur lors de l'initialisation du micro.");
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
    if (_userText.isNotEmpty) {
      _getAIResponse(_userText);
    } else {
      _showError("Aucun texte détecté. Essayez encore.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _getAIResponse(String userInput) async {
    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? 'Clé API manquante';
    final String apiBaseUrl = 'https://api.openai.com/v1/chat/completions';

    String prompt = """
    Tu es un assistant médical virtuel. Réponds dans la langue spécifiée : ${_selectedLanguage == 'fr-FR'
        ? 'français'
        : _selectedLanguage == 'en-US'
        ? 'anglais'
        : 'espagnol'}.
    Question : $userInput
    """;

    try {
      final response = await http.post(
        Uri.parse(apiBaseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content": "Tu es un assistant IA médical multilingue.",
            },
            {"role": "user", "content": prompt},
          ],
          "max_tokens": 250,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _aiResponse = data['choices'][0]['message']['content'].trim();
        _speak(_aiResponse);
      } else {
        print("Erreur: ${response.statusCode} - ${response.body}");
        _aiResponse = "Erreur lors de la communication avec l'IA.";
        _speak(_aiResponse);
      }
    } catch (e) {
      print("Exception: $e");
      _aiResponse = "Erreur de connexion.";
      _speak(_aiResponse);
    }
  }

  void _speak(String text) async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  final IOS7SiriWaveformController _controller = IOS7SiriWaveformController(
    amplitude: 0.5,
    color: Colors.white,
    frequency: 4,
    speed: 0.15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "AIVoiceAssistant",
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
            items:
                <String>[
                  'fr-FR',
                  'en-US',
                  'es-ES',
                ].map<DropdownMenuItem<String>>((String value) {
                  String languageCode = value.split('-')[0];
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          languageCode.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            dropdownColor: Colors.grey[900],
            underline: const SizedBox(),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Communicate with a medical AI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: GestureDetector(
                onTapDown: (_) {
                  _startListening();
                },
                onTapUp: (_) {
                  _stopListening();
                },
                onTapCancel: () {
                  _stopListening();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isListening ? Colors.red : Colors.blue,
                        blurRadius: 20.0,
                        spreadRadius: 5.0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child:
                      _isListening
                          ? SiriWaveform.ios7(
                            controller: _controller,
                            options: const IOS7SiriWaveformOptions(
                              height: 100,
                              width: 200,
                            ),
                          )
                          : const Icon(
                            Icons.mic_none,
                            size: 40,
                            color: Colors.white,
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
