import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_bar.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';
import 'season_selector.dart';
import 'competition_information.dart';
import 'competition_game_information.dart';

class CompetitionPage extends StatefulWidget {
  final String sportSlug; // Required
  final String leagueSlug; // Required
  final String? seasonSlug; // Optional

  const CompetitionPage({
    super.key,
    required this.sportSlug,
    required this.leagueSlug,
    this.seasonSlug,
  });

  @override
  State<CompetitionPage> createState() => _CompetitionPageState();
}

class _CompetitionPageState extends State<CompetitionPage> {
  String? _resolvedSeasonSlug;
  List<Map<String, String>> _seasons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSeasons();
  }

  /// Fetch the seasons and resolve the initial seasonSlug
  Future<void> _fetchSeasons() async {
    final url =
        'https://www.finalwhistle.ie/${widget.sportSlug}/?feed=json-events&league_slug=${widget.leagueSlug}&count=100000';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final events = data['events'] ?? [];
        final uniqueSeasons = <String, String>{};

        // Extract unique seasons from events
        for (var event in events) {
          if (event['seasons'] != null) {
            for (var season in event['seasons']) {
              uniqueSeasons[season['slug']] = season['name'];
            }
          }
        }

        final sortedSeasons = uniqueSeasons.entries
            .map((entry) => {'slug': entry.key, 'name': entry.value})
            .toList()
          ..sort((a, b) => b['name']!.compareTo(a['name']!)); // Sort by name descending

        setState(() {
          _seasons = sortedSeasons;
          _resolvedSeasonSlug = widget.seasonSlug ??
              (sortedSeasons.isNotEmpty ? sortedSeasons.first['slug'] : null);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch seasons: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching seasons: $e');
      setState(() {
        _errorMessage = 'Error loading data. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SportsMenu(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Season Selector
                            SeasonSelector(
                              seasons: _seasons,
                              currentSeasonSlug: _resolvedSeasonSlug,
                              onSeasonChanged: (newSeasonSlug) {
                                setState(() {
                                  _resolvedSeasonSlug = newSeasonSlug;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Competition Information
                            if (_resolvedSeasonSlug != null)
                              CompetitionInformation(
                                sportSlug: widget.sportSlug,
                                leagueSlug: widget.leagueSlug,
                                seasonSlug: _resolvedSeasonSlug!,
                              ),
                            const SizedBox(height: 16),

                            // Competition Games Information
                            if (_resolvedSeasonSlug != null)
                              CompetitionGameInformation(
                                sportSlug: widget.sportSlug,
                                leagueSlug: widget.leagueSlug,
                                seasonSlug: _resolvedSeasonSlug!,
                              ),
                          ],
                        ),
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              children: [
                Text('Sport Slug: ${widget.sportSlug}', style: const TextStyle(fontSize: 14)),
                Text('League Slug: ${widget.leagueSlug}', style: const TextStyle(fontSize: 14)),
                Text('Season Slug: $_resolvedSeasonSlug', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}
