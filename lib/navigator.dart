import 'package:flutter/material.dart';
import 'package:viesauve_app/mespages/mainpage.dart';
import 'package:viesauve_app/mespages/sos.dart';
import 'mespages/position.dart';
import 'mespages/settings.dart';


class NavigationPage extends StatefulWidget {
 final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const NavigationPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<NavigationPage> createState() => _NaviagtionPageState();
}

class _NaviagtionPageState extends State<NavigationPage> {
  int currentindex = 1; // Définir à 1 pour afficher "Secours" en premier

  void _listbotton(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screen = [
    const MainPage(),
    const SOSPage(),
    LocationSharingPage(),
    Settings(
      isDarkMode: widget.isDarkMode,
      onToggleTheme: widget.onToggleTheme,
    ),
  ];
    return Scaffold(
      backgroundColor: const Color(0xFF2D2E33),
      body: screen[
          currentindex], // Afficher l'écran en fonction de l'index actuel
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black,
        currentIndex: currentindex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentindex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 20,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.security_outlined,
              size: 20,
            ),
            label: 'Secours',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_pin,
              size: 20,
            ),
            label: 'Position',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 20,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
