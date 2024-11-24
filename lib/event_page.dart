import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Custom App Bar
      body: Column(
        children: [
          const SportsMenu(), // Sports Menu
          Expanded(
            child: Center(
              child: Text(
                'Event details will be displayed here.',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003471), // Match app branding color
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(), // Bottom Navigation Bar
    );
  }
}