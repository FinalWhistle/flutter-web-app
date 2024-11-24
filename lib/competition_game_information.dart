import 'package:flutter/material.dart';

class CompetitionGameInformation extends StatelessWidget {
  final String sportSlug;
  final String leagueSlug;
  final String seasonSlug;

  const CompetitionGameInformation({
    super.key,
    required this.sportSlug,
    required this.leagueSlug,
    required this.seasonSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Competition Game Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Sport: $sportSlug'),
            Text('League: $leagueSlug'),
            Text('Season: $seasonSlug'),
          ],
        ),
      ),
    );
  }
}
