import 'package:flutter/material.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';
import 'app_bar.dart';
import 'game_info.dart';

class SportPage extends StatelessWidget {
  final String sportName;

  const SportPage({super.key, required this.sportName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Reusing the main app bar
      body: Column(
        children: [
          const SportsMenu(),
          Expanded(
            child: GameInfo(sportName: sportName),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}