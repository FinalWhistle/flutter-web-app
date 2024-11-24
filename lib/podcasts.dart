import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: const [
          SportsMenu(),
          Expanded(
            child: Center(
              child: Text(
                'Podcasts will be listed here.',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}