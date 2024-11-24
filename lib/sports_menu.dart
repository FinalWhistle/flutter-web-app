import 'package:flutter/material.dart';
import 'game_info.dart';

class SportsMenu extends StatelessWidget {
  const SportsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set the background color to white
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          SizedBox(
            height: 20.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/home-menu.png', 'Soccer', 'Soccer'),
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/soccer-menu.png', 'Soccer', 'Soccer'),
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/rugby-menu.png', 'Rugby', 'Rugby'),
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/gaelic-menu.png', 'Gaelic Football', 'Gaelic Football'),
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/hurling-menu.png', 'Hurling', 'Hurling'),
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/ladies-football-menu.png', 'Ladies Football', 'Ladies Football'),
                  const SizedBox(width: 17.0),
                  buildMenuItem(context, 'lib/assets/menu-logos/camogie-menu.png', 'Camogie', 'Camogie'),
                  const SizedBox(width: 17.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Container(
            height: 2.0,
            width: double.infinity,
            color: const Color(0xFF003471),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, String assetPath, String tooltip, String? sportName) {
    return GestureDetector(
      onTap: () {
        if (sportName != null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => GameInfo(sportName: sportName),
              transitionDuration: Duration.zero, // Remove transition animation
              reverseTransitionDuration: Duration.zero, // Remove reverse transition
            ),
          );
        }
      },
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        height: 20.0,
      ),
    );
  }
}