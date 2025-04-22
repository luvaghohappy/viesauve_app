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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
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
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black26,
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
                        MaterialPageRoute(
                          builder: (context) => MultiStepForm(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black26,
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
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (items.isNotEmpty)
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(255, 168, 142, 240),
                ),
                child: Center(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      backgroundImage:
                          items[0]['image_path'] != null
                              ? NetworkImage(
                                "${AppConstants.baseUrl}${items[0]['image_path']}",
                              )
                              : null,
                      child:
                          items[0]['image_path'] == null
                              ? const Icon(
                                Icons.image,
                                size: 10,
                                color: Colors.grey,
                              )
                              : null,
                    ),
                    title: Text(noms ?? 'Nom inconnu'),
                    subtitle: Text(
                      items[0]['email'] ?? 'N/A',
                      style: const TextStyle(color: Colors.black12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.person, size: 25),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ListTile(
                title: Text(
                  'Paramètres',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Securite', style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.abc),
              title: Text('A propos', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Guides', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Confidentialite', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.book),
              title: Text(
                'Politique de VISAUVE',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.abc),
              title: Text('Mode', style: TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: Icon(
                  widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () => widget.onToggleTheme(!widget.isDarkMode),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Autres',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AIPages()),
                );
              },
              leading: Icon(Icons.voice_chat),
              title: Text("IA's", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications', style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('Rate Interventions', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.history_edu),
              title: Text('Historique', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
