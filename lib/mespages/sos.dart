import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../const.dart';
import 'package:permission_handler/permission_handler.dart';
import '../const.dart' as AppConstants show baseUrl;

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool isLoading = false;
  String selectedAlertText = "A l'aide";
  final List<String> alertMessages = [
    "A l'aide",
    "Il y a un voleur",
    "Il y a un feu",
    "Il y a une fusillade",
    "J'ai un malaise",
    "Quelqu'un est blessé",
    "Un accident s'est produit",
    "Besoin d'une assistance immédiate",
  ];
  String? id_user;
  String? secteur_id;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = prefs.getString('id_user');
      secteur_id = prefs.getString('secteur_id');
    });
  }

  Future<void> _checkAndRequestLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      print('Location permission is required to access the location.');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<void> showMessageDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendData(String servicetype) async {
    setState(() {
      isLoading = true;
    });

    await _getCurrentLocation();

    if (id_user != null && latitude != null && longitude != null) {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.baseUrl}alertes.php'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'user_id': id_user!,
            'secteur_id': secteur_id!,
            'messages': selectedAlertText,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'serviceType': servicetype,
            'etat': 'nouvelle',
          }),
        );

        if (response.statusCode == 200) {
          await showMessageDialog("Succès", "✅ Demande soumise avec succès");
        } else {
          await showMessageDialog("Erreur", "❌ Échec de l'envoi des données");
        }
      } catch (e) {
        await showMessageDialog(
          "Exception",
          "❗ Une erreur s'est produite : $e",
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      await showMessageDialog(
        "Données manquantes",
        "⚠️ Données utilisateur ou localisation manquantes",
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'VIESAUVE URGENCES',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SOSButton(
                      text: 'SOS AMBULANCE',
                      imageUrl: 'assets/ambulance.png',
                      onPressed: () {
                        _sendData('ambulance');
                      },
                    ),
                    SOSButton(
                      text: 'SOS POLICE',
                      imageUrl: 'assets/policier.jpg',
                      onPressed: () {
                        _sendData('police');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SOSButton(
                      text: 'SOS POMPIER',
                      imageUrl: 'assets/pompier.png',
                      onPressed: () {
                        _sendData('pompier');
                      },
                    ),
                    SOSButton(
                      text: 'CHAT LIVE',
                      imageUrl: 'assets/chat.jpg',
                      onPressed: () {
                        _sendData('chat');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate((alertMessages.length / 2).ceil(), (
                      index,
                    ) {
                      final first = alertMessages[index * 2];
                      final second =
                          (index * 2 + 1 < alertMessages.length)
                              ? alertMessages[index * 2 + 1]
                              : null;

                      return Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(first),
                              value: first,
                              groupValue: selectedAlertText,
                              onChanged:
                                  (value) => setState(
                                    () => selectedAlertText = value!,
                                  ),
                            ),
                          ),
                          if (second != null)
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(second),
                                value: second,
                                groupValue: selectedAlertText,
                                onChanged:
                                    (value) => setState(
                                      () => selectedAlertText = value!,
                                    ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class SOSButton extends StatelessWidget {
  final String text;
  final String imageUrl;
  final VoidCallback onPressed;

  const SOSButton({
    required this.text,
    required this.imageUrl,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Material(
            elevation: 5,
            shape: const CircleBorder(),
            shadowColor: Colors.black,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(imageUrl),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
