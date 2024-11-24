import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async'; // Import for Timer
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'date_selector.dart'; // Import DateSelector
import 'match_model.dart';
import 'match_display.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';
import 'app_bar.dart';

class GameInfo extends StatefulWidget {
  final String? sportName;

  const GameInfo({super.key, this.sportName});

  @override
  State<GameInfo> createState() => _GameInfoState();
}

class _GameInfoState extends State<GameInfo> {
  late String selectedDate;
  Map<String, List<Match>> currentMatches = {};
  String currentUrl = ''; // To store the current URL being fetched
  Timer? refreshTimer;
  bool _isFetching = false; // To prevent overlapping fetches

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadMatches();

    // Start a timer to refresh the matches every 15 seconds
    refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshMatches();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, List<Match>>> fetchMatches(String? sport, String date) async {
    final Map<String, String> sportFeeds = {
      'Soccer': 'https://www.finalwhistle.ie/soccer/?feed=json-events&count=1000&date=$date',
      'Rugby': 'https://www.finalwhistle.ie/rugby/?feed=json-events&count=1000&date=$date',
      'Camogie': 'https://www.finalwhistle.ie/camogie/?feed=json-events&count=1000&date=$date',
      'Ladies Football': 'https://www.finalwhistle.ie/ladiesfootball/?feed=json-events&count=1000&date=$date',
      'Hurling': 'https://www.finalwhistle.ie/hurling/?feed=json-events&count=1000&date=$date',
      'Gaelic Football': 'https://www.finalwhistle.ie/gaelic/?feed=json-events&count=1000&date=$date',
    };

    // Define status priority
    int getStatusPriority(String matchStatus) {
      switch (matchStatus.toLowerCase()) {
        case 'live':
          return 1;
        case 'fixture':
          return 2;
        case 'result':
          return 3;
        default:
          return 3;
      }
    }

    try {
      final List<Match> allMatches = [];

      if (sport == null || sport.isEmpty || sport.toLowerCase() == "all") {
        for (var entry in sportFeeds.entries) {
          currentUrl = entry.value;
          final sportSlug = entry.value.split('/')[3]; // Extract sportSlug
          final response = await http.get(Uri.parse(entry.value));
          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            final List<dynamic> events = jsonData['events'] ?? [];

            final matches = events.map((e) {
              try {
                return Match.fromJson(e, entry.key); // Pass only expected arguments
              } catch (error) {
                debugPrint('Error parsing match for ${entry.key}: $error');
                return null;
              }
            }).whereType<Match>().toList();

            allMatches.addAll(matches);
          } else {
            debugPrint('Failed to fetch matches from ${entry.value}. Status code: ${response.statusCode}');
          }
        }
      } else {
        final String? url = sportFeeds[sport];
        if (url == null) {
          throw Exception('Invalid sport name: $sport');
        }

        currentUrl = url;
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final List<dynamic> events = jsonData['events'] ?? [];

          final matches = events.map((e) {
            try {
              return Match.fromJson(e, sport); // Pass only expected arguments
            } catch (error) {
              debugPrint('Error parsing match for $sport: $error');
              return null;
            }
          }).whereType<Match>().toList();

          allMatches.addAll(matches);
        } else {
          debugPrint('Failed to fetch matches from $url. Status code: ${response.statusCode}');
          throw Exception('Failed to load matches');
        }
      }

      allMatches.sort((a, b) {
        int priorityA = getStatusPriority(a.matchStatus);
        int priorityB = getStatusPriority(b.matchStatus);
        if (priorityA != priorityB) {
          return priorityA.compareTo(priorityB);
        }
        int dateComparison = a.eventDateTime.compareTo(b.eventDateTime);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return a.homeTeamName.toLowerCase().compareTo(b.homeTeamName.toLowerCase());
      });

      Map<String, List<Match>> groupedMatches = {};
      for (var match in allMatches) {
        String dateKey = DateFormat('EEEE, MMM d, yyyy').format(match.eventDateTime);
        groupedMatches.putIfAbsent(dateKey, () => []).add(match);
      }

      return groupedMatches;
    } catch (error) {
      debugPrint('Error fetching matches: $error');
      throw Exception('Failed to load matches');
    }
  }

  Future<void> _loadMatches() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final matches = await fetchMatches(widget.sportName, selectedDate);
      setState(() {
        currentMatches = matches;
      });
    } catch (error) {
      debugPrint('Error loading matches: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load matches. Please try again later.'),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _refreshMatches() async {
    await _loadMatches();
  }

  void _onDateSelected(String newDate) {
    setState(() {
      selectedDate = newDate;
    });
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          const SportsMenu(),
          DateSelector(onDateSelected: _onDateSelected),
          Expanded(
            child: currentMatches.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshMatches,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: currentMatches.keys.length,
                      itemBuilder: (context, index) {
                        String date = currentMatches.keys.elementAt(index);
                        List<Match> matches = currentMatches[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                date,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003471),
                                ),
                              ),
                            ),
                            ...matches.map((match) {
                              return Column(
                                children: [
                                  MatchDisplay(match),
                                  const Divider(),
                                ],
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}