import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viesauve_app/logins/login.dart';
import 'package:viesauve_app/mespages/settings.dart';
import '../const.dart' as AppConstants;

class SignInPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const SignInPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController txtnoms = TextEditingController();
  TextEditingController txtmotdepasse = TextEditingController();
  bool _obscurePassword = true;
  int _attempts = 0;
  bool _fieldsDisabled = false;

  Future<void> loginUser() async {
    if (_fieldsDisabled) return;

    final url = '${AppConstants.baseUrl}login.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'noms': txtnoms.text,
          'mot_de_passe': txtmotdepasse.text,
        }),
      );

      print("Réponse du serveur : ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Données reçues : $responseData");

        if (responseData['success'] == true) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          String idUser = responseData['id_user'].toString();
          String nomUtilisateur = responseData['noms'];
          String email = responseData['email'] ?? '';
          String imagePath = responseData['image_path'] ?? '';

          await prefs.setString("id_user", idUser);
          await prefs.setString("noms", nomUtilisateur);
          await prefs.setString("email", email);
          await prefs.setString(
            "image_url",
            "${AppConstants.baseUrl}$imagePath",
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Settings(
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                  ),
            ),
          );
        } else {
          _attempts++;
          if (_attempts >= 3) {
            setState(() {
              _fieldsDisabled = true;
            });
            _showErrorDialog(context, 'Accès refusé après 3 tentatives.');
          } else {
            _showErrorDialog(
              context,
              responseData['message'] ?? 'Erreur inconnue.',
            );
          }
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la connexion : $e");
      _showErrorDialog(
        context,
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de connexion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'VIESAUVE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text('Noms', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: txtnoms,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Mot de passe', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: txtmotdepasse,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text("Si vous n'avez pas de compte, "),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiStepForm(),
                          ),
                        );
                      },
                      child: Text('créez-en un ici.'),
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
}
