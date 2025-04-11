import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viesauve_app/aipages/aipage.dart';
import 'package:viesauve_app/logins/signin.dart';
import '../const.dart' as AppConstants show baseUrl;
import '../logins/login.dart';

class Settings extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkMode;

  const Settings({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<Map<String, dynamic>> items = [];
  String? noms;
  String? idUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id_user');
    String? nom = prefs.getString('noms');

    if (id != null) {
      setState(() {
        idUser = id;
        noms = nom;
      });
      await fetchUserData(id);
    }
  }

  Future<void> fetchUserData(String idUser) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}getuser.php?id_user=$idUser"),
      );
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        setState(() {
          items = [data];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load user data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SignInPage(
                              isDarkMode: widget.isDarkMode,
                              onToggleTheme: widget.onToggleTheme,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                          blurStyle: BlurStyle.normal,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('Login')),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MultiStepForm()),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                          blurStyle: BlurStyle.normal,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('Compte')),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          if (items.isNotEmpty)
            ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue,
                backgroundImage:
                    items[0]['image_path'] != null
                        ? NetworkImage(
                          "${AppConstants.baseUrl}${items[0]['image_path']}",
                        )
                        : null,
                child:
                    items[0]['image_path'] == null
                        ? const Icon(Icons.image, size: 10, color: Colors.grey)
                        : null,
              ),
              title: Text(noms ?? 'Nom inconnu'),
              subtitle: Text(
                items[0]['email'] ?? 'N/A',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.person),
            ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ListTile(
              leading: Text(
                'Paramètres et confidentialite',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                onPressed: () {},
                icon: Icon(Icons.settings),
              ),
            ),
          ),
          Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Autres Parametres',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AIPages()),
              );
            },
            leading: Icon(Icons.voice_chat),
            title: Text("IA's"),
          ),
          SizedBox(height: 10),
          ListTile(leading: Icon(Icons.policy)),
          SizedBox(height: 10),
          ListTile(leading: Icon(Icons.book), title: Text('Guides')),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.rate_review),
            title: Text('Rate Agents'),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Text('Mode'),
            trailing: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () => widget.onToggleTheme(!widget.isDarkMode),
            ),
          ),
          SizedBox(height: 10),
          ListTile(leading: Icon(Icons.abc), title: Text('A propos')),
        ],
      ),
    );
  }
}
