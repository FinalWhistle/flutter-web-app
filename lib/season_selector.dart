import 'package:flutter/material.dart';

class SeasonSelector extends StatelessWidget {
  final List<Map<String, String>> seasons;
  final String? currentSeasonSlug;
  final ValueChanged<String> onSeasonChanged;

  const SeasonSelector({
    super.key,
    required this.seasons,
    required this.currentSeasonSlug,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: DropdownButton<String>(
            value: currentSeasonSlug,
            onChanged: (value) {
              if (value != null) {
                onSeasonChanged(value);
              }
            },
            items: seasons
                .map((season) => DropdownMenuItem<String>(
                      value: season['slug'],
                      child: Text(
                        season['name'] ?? 'Unknown Season',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            icon: const Icon(Icons.arrow_drop_down),
            underline: Container(),
            isDense: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
