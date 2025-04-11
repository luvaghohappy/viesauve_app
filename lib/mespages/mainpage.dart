import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? imagePath;
  String? prenom;
  List<Map<String, dynamic>> items = [];

  final List<String> images = [
    'https://th.bing.com/th/id/R.41ae108aba96327a5f1d7305ba167ec7?rik=TwSPsRyHW97KcA&pid=ImgRaw&r=0',
    'https://th.bing.com/th/id/R.abad49c504fe7f1e74ed428cb9cda6a6?rik=L6Y8myr7P5jGAA&riu=http%3a%2f%2foise-media.fr%2fwp-content%2fuploads%2f2019%2f04%2fSDIS-2.jpg&ehk=37AZpKjFZD36BVWcKpx7RpShUq60Bj2heAiA%2fpW2%2fLU%3d&risl=&pid=ImgRaw&r=0',
    'https://th.bing.com/th/id/R.abd5b632ad50817a159c6817a5971030?rik=uIHa7fvZHBELbA&riu=http%3a%2f%2fi.ytimg.com%2fvi%2fhCzQdiUT1HI%2fmaxresdefault.jpg&ehk=GjrnTHzHPFDPG5v7HIbZbsF0RqgOG%2btdjSjGtc9QEP0%3d&risl=&pid=ImgRaw&r=0',
    'https://th.bing.com/th/id/R.4aea793fa245a81089f025d4e1b374e3?rik=H7TrDAEgrZNTew&riu=http%3a%2f%2fwww.coursonlescarrieres.fr%2fwp-content%2fuploads%2f2013%2f06%2f508-BIS.jpg&ehk=u6RFfvqnIsmagZn48IqhBJ88KbVvjqdp%2fRffJ7IlfQo%3d&risl=&pid=ImgRaw&r=0',
    'https://th.bing.com/th/id/OIP.SJlodOEQCpV6LYM0L1bS2gHaFT?rs=1&pid=ImgDetMain',
    'https://th.bing.com/th/id/R.d322c57e2007d3060ac99990929e20c0?rik=vgVVHOMeSY%2b7QQ&riu=http%3a%2f%2fi.ytimg.com%2fvi%2fvi9fhNwd5QI%2fmaxresdefault.jpg&ehk=7pyCcAlVdjMYMw9xvnnCBnDkOG8bNkyzSmsbH5ip%2b2Y%3d&risl=&pid=ImgRaw&r=0',
    'https://th.bing.com/th/id/OIP.YAtdXWceaPfmnat3f8CbrQHaFy?rs=1&pid=ImgDetMain',
    'https://th.bing.com/th/id/R.eaa7a625258287b3eadfd9ef57c82bf1?rik=7s3BwYdPgYDO7Q&pid=ImgRaw&r=0',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = items.isNotEmpty ? items[0] : {};
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 30)),
            ListTile(
              leading: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/logo.jpg'),
              ),
              title: const Text(
                'VIE_SAUVE',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              //   trailing: PopupMenuButton<int>(
              //     icon: const Icon(
              //       Icons.menu,
              //       color: Colors.black,
              //     ),
              //     onSelected: (value) {
              //       switch (value) {
              //         case 0:
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => const Settings(),
              //             ),
              //           );
              //           break;
              //         case 1:
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => const Guides(),
              //             ),
              //           );
              //           break;
              //         case 2:
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => const Apropos(),
              //             ),
              //           );
              //           break;
              //       }
              //     },
              //     itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              //       PopupMenuItem<int>(
              //         value: 0,
              //         child: Row(
              //           children: const [
              //             Icon(Icons.settings, size: 15, color: Colors.black),
              //             SizedBox(width: 8),
              //             Text('Paramètres'),
              //           ],
              //         ),
              //       ),
              //       PopupMenuItem<int>(
              //         value: 1,
              //         child: Row(
              //           children: const [
              //             Icon(Icons.book, size: 15, color: Colors.black),
              //             SizedBox(width: 8),
              //             Text('Guide'),
              //           ],
              //         ),
              //       ),
              //       PopupMenuItem<int>(
              //         value: 2,
              //         child: Row(
              //           children: const [
              //             Icon(Icons.info, size: 15, color: Colors.black),
              //             SizedBox(width: 8),
              //             Text('À propos'),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
            ),
            const Padding(padding: EdgeInsets.only(top: 30)),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOS SERVICES',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: h * 0.3,
                              width: 300,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/ambulance.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 300,
                              child: Text(
                                "Les ambulanciers sont responsables de l'évaluation, de la stabilisation et du transport des patients vers des établissements médicaux. Ils fournissent des soins vitaux, comme la réanimation, le traitement des traumatismes, et l'administration de médicaments.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.abel(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Container(
                              height: h * 0.3,
                              width: 300,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/policier.jpg'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 300,
                              child: Text(
                                "Les policiers sécurisent les lieux d'une urgence pour prévenir le chaos, les émeutes ou les situations de panique. Ils contrôlent également la circulation pour permettre aux services d'urgence d'accéder rapidement au site.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.abel(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Container(
                              height: h * 0.3,
                              width: 300,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/pompier.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 300,
                              child: Text(
                                'Ils effectuent des opérations de sauvetage, notamment en extrayant des personnes coincées dans des véhicules accidentés, des bâtiments effondrés, ou lors de situations de noyade.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.abel(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOS TACHES',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 20)),
                        const Text(
                          'Localisation des appels d’urgence:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        Text(
                          "La fonction de localisation des appels d'urgence permet de déterminer avec précision la position géographique des appelants en détresse. Grâce à la géolocalisation en temps réel.",
                          style: GoogleFonts.abel(),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        const Text(
                          'Assistance médicale à distance:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        Text(
                          "En attendant l'arrivée des secours, VIE-SAUVE offre une assistance médicale à distance. Les utilisateurs peuvent recevoir des instructions vitales, des conseils sur les premiers secours et des indications sur les mesures à prendre en cas d'urgence médicale.",
                          style: GoogleFonts.abel(),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Nous croyons fermement que VIE-SAUVE sera un outil précieux pour renforcer la sécurité et le sauvetage dans notre communauté, en permettant des interventions plus rapides, une assistance médicale à distance efficace et une tranquillité d'esprit pour nos utilisateurs.",
                        style: GoogleFonts.abel(),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  CarouselSlider(
                    items:
                        images.map((imageUrl) {
                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: 1000.0,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
