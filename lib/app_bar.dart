import 'package:flutter/material.dart';
import 'main.dart';
import 'search_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Always set AppBar background color to white
      iconTheme: const IconThemeData(color: Colors.black), // Set icon color to black for contrast
      title: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const MyApp(),
              transitionDuration: Duration.zero, // Remove transition animation
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        child: Row(
          children: [
            Image.asset(
              'lib/assets/FinalwhistleLogoText.png',
              height: 20,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black), // Icons with black color for visibility
          tooltip: 'Search',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const SearchPage(),
                transitionDuration: Duration.zero, // Remove transition animation
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_alert, color: Colors.black),
          tooltip: 'Notifications',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications tapped')));
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          tooltip: 'Menu',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu tapped')));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}