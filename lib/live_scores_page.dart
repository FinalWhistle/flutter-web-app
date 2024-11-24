import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_bar.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';

class LiveScoresPage extends StatefulWidget {
  const LiveScoresPage({super.key});

  @override
  _LiveScoresPageState createState() => _LiveScoresPageState();
}

class _LiveScoresPageState extends State<LiveScoresPage> {
  List<Map<String, dynamic>> competitions = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCompetitions();
  }

  Future<void> fetchCompetitions() async {
    const String competitionsUrl =
        'https://www.finalwhistle.ie/soccer/?feed=json-competitions';

    try {
      final response = await http.get(Uri.parse(competitionsUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          // Filter only competitions where parent_competition is not null
          competitions = jsonData
              .cast<Map<String, dynamic>>()
              .where((competition) => competition['parent_competition'] != null)
              .toList();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load competitions. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching competitions: $e';
      });
    }
  }

  List<Widget> buildHierarchy() {
    // Organize competitions by parent-child relationships
    Map<int, List<Map<String, dynamic>>> levels = {};

    for (var competition in competitions) {
      final parent = competition['parent_competition'];
      final parentId = parent != null ? parent['parent_id'] : null;

      if (parentId == null) {
        levels.putIfAbsent(1, () => []).add(competition); // Level 1
      } else {
        levels.putIfAbsent(parentId, () => []).add(competition);
      }
    }

    List<Widget> hierarchy = [];
    void buildLevel(int level, List<Map<String, dynamic>> competitions, int depth) {
      for (var competition in competitions) {
        final competitionId = competition['competition_id'];
        final childCompetitions = levels[competitionId] ?? [];
        final textColor = depth == 1
            ? Colors.black
            : depth == 2
                ? Colors.blue
                : depth == 3
                    ? Colors.green
                    : Colors.red;

        hierarchy.add(Padding(
          padding: EdgeInsets.only(left: (depth - 1) * 20.0),
          child: Text(
            competition['competition_name'],
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
        ));

        if (childCompetitions.isNotEmpty) {
          buildLevel(level + 1, childCompetitions, depth + 1);
        }
      }
    }

    buildLevel(1, levels[1] ?? [], 1); // Start with level 1
    return hierarchy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SportsMenu(),
          Expanded(
            child: errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : competitions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: buildHierarchy(),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}