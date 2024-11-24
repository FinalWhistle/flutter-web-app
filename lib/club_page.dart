import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';

class ClubPage extends StatelessWidget {
  final int id;

  const ClubPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SportsMenu(),
          Expanded(
            child: Center(
              child: Text(
                'Club Page: (ID: $id)',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}