import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'competition_page.dart';
import 'app_bar.dart';
import 'sports_menu.dart';
import 'bottom_menu.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  /// Helper function to sanitize strings and remove ASCII codes
  String sanitizeString(String? input) {
    if (input == null) return '';
    return input
        .replaceAll('&8217;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '') // Remove other HTML entities
        .trim();
  }

  Future<void> _fetchData() async {
    await _fetchCompetitions();
    setState(() {
      _filteredItems = _items;
    });
  }

  Future<void> _fetchCompetitions() async {
    final feeds = {
      'soccer': 'https://www.finalwhistle.ie/soccer/?feed=json-competitions',
      'rugby': 'https://www.finalwhistle.ie/rugby/?feed=json-competitions',
      'gaelic': 'https://www.finalwhistle.ie/gaelic/?feed=json-competitions',
      'hurling': 'https://www.finalwhistle.ie/hurling/?feed=json-competitions',
      'ladiesfootball':
          'https://www.finalwhistle.ie/ladiesfootball/?feed=json-competitions',
      'camogie': 'https://www.finalwhistle.ie/camogie/?feed=json-competitions',
    };

    for (var entry in feeds.entries) {
      final sportSlug = entry.key;
      final url = entry.value;

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          for (var competition in data) {
            _items.add({
  'type': 'competition',
  'name': sanitizeString(competition['competition_name']),
  'slug': sanitizeString(competition['competition_slug']),
  'sportSlug': sanitizeString(sportSlug),
  'leagueSlug': sanitizeString(competition['competition_slug']),
  'seasonSlug': sanitizeString(competition['seasons']?[0]?['slug']),
});

          }
        } else {
          debugPrint('Failed to load data from $url');
        }
      } catch (e) {
        debugPrint('Error fetching data from $url: $e');
      }
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();
    final words = query.split(' ');

    setState(() {
      _filteredItems = _items.where((item) {
        final name = item['name']?.toLowerCase() ?? '';
        final sport = item['sportSlug']?.toLowerCase() ?? '';
        final leagueSlug = item['leagueSlug']?.toLowerCase() ?? '';
        return words.every((word) =>
            name.contains(word) || sport.contains(word) || leagueSlug.contains(word));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SportsMenu(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Competitions',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final type = item['type'];
                final name = item['name'];
                final sportSlug = item['sportSlug'];
                final leagueSlug = item['leagueSlug'];

                return ListTile(
                  leading: Icon(type == 'competition' ? Icons.emoji_events : Icons.group),
                  title: Text(
                    '$name (${sportSlug.toUpperCase()})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('League: $leagueSlug'),
                  onTap: () {
                    if (type == 'competition') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompetitionPage(
                            sportSlug: sportSlug,
                            leagueSlug: leagueSlug, // Use full slug
                            seasonSlug: item['seasonSlug'],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}
