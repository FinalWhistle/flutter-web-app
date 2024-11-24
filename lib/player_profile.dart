import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'app_bar.dart';
import 'bottom_menu.dart';

class PlayerProfile extends StatefulWidget {
  final int playerID;
  final String sportSlug;

  const PlayerProfile({
    Key? key,
    required this.playerID,
    required this.sportSlug,
  }) : super(key: key);

  @override
  _PlayerProfileState createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {
  Map<String, dynamic>? _playerData;
  Map<String, String> _clubLogos = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPlayerData();
  }

  Future<void> _fetchPlayerData() async {
    final url =
        'https://www.finalwhistle.ie/${widget.sportSlug}/?feed=json-player&ID=${widget.playerID}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _playerData = data;
          _isLoading = false;
        });
        _fetchClubLogos(data);
      } else {
        throw Exception('Failed to fetch player data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching player data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClubLogos(Map<String, dynamic> data) async {
    final List<Map<String, dynamic>> teams = [];
    if (data['current_teams'] != null) {
      teams.addAll(data['current_teams']);
    }
    if (data['past_teams'] != null) {
      teams.addAll(data['past_teams']);
    }

    for (var team in teams) {
      final teamID = team['team_id'];
      final url =
          'https://www.finalwhistle.ie/${widget.sportSlug}/?feed=json-club&ID=$teamID';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final teamData = json.decode(response.body);
          setState(() {
            _clubLogos[team['team_name']] = teamData['featured_image_url'];
          });
        }
      } catch (e) {
        debugPrint('Error fetching logo for team $teamID: $e');
      }
    }
  }

  String sanitizeText(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('&8217;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(r"n\'s", "n's")
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '')
        .trim();
  }

  Widget buildPlayerHeader() {
    final currentTeams = _playerData?['current_teams'] ?? [];
    final positions = _playerData?['positions'] ?? [];

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              NetworkImage(_playerData?['featured_image_url'] ?? ''),
          onBackgroundImageError: (error, stackTrace) =>
              const Icon(Icons.person, size: 100),
        ),
        const SizedBox(height: 10),
        Text(
          sanitizeText(_playerData?['name']),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003471),
          ),
        ),
        const SizedBox(height: 10),
        if (positions.isNotEmpty)
          Text(
            sanitizeText(positions[0]['name']),
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        const SizedBox(height: 10),
        if (currentTeams.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List<Widget>.generate(
              currentTeams.length > 3 ? 3 : currentTeams.length,
              (index) {
                final team = currentTeams[index];
                final teamLogo = _clubLogos[sanitizeText(team['team_name'])] ?? '';
                return Column(
                  children: [
                    if (teamLogo.isNotEmpty)
                      Image.network(
                        teamLogo,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      sanitizeText(team['team_name']),
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildClubHistory() {
    final pastTeams = _playerData?['past_teams'] ?? [];
    if (pastTeams.isEmpty) {
      return const Text('No past clubs available.');
    }

    return Column(
      children: [
        const Text(
          'Previous Teams',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003471),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: pastTeams.map<Widget>((team) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  _clubLogos[sanitizeText(team['team_name'])] ?? '',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 40),
                ),
                const SizedBox(height: 5),
                Text(
                  sanitizeText(team['team_name']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildGamesTable() {
    if (_playerData?['statistics'] == null || _playerData!['statistics'].isEmpty) {
      return const Text('No statistics available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _playerData!['statistics'].entries.map<Widget>((entry) {
        final competitionName = sanitizeText(entry.value['0']['name']);
        final seasons = entry.value as Map<String, dynamic>;

        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              competitionName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003471),
              ),
            ),
            const SizedBox(height: 10),
            DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF003471)),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              columnSpacing: 10,
              columns: const [
                DataColumn(label: Text('Season')),
                DataColumn(label: Text('Club')),
                DataColumn(label: Text('Apps')),
                DataColumn(label: Text('Starts')),
                DataColumn(label: Text('Points')),
                DataColumn(label: Text('Tries')),
              ],
              rows: seasons.entries
                  .where((e) => e.key != '0' && e.key != '-1')
                  .map<DataRow>((seasonEntry) {
                final seasonStats = seasonEntry.value as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(sanitizeText(seasonStats['name']))),
                  DataCell(
                    Image.network(
                      _clubLogos[sanitizeText(seasonStats['team'])] ?? '',
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  DataCell(Text('${seasonStats['a'] ?? 0}')),
                  DataCell(Text('${seasonStats['starts'] ?? 0}')),
                  DataCell(Text('${seasonStats['pts'] ?? 0}')),
                  DataCell(Text('${seasonStats['t'] ?? 0}')),
                ]);
              }).toList()
                ..add(
                  DataRow(cells: [
                    const DataCell(Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataCell(Text('-')),
                    DataCell(Text(
                      '${seasons['-1']?['a'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      '${seasons['-1']?['starts'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      '${seasons['-1']?['pts'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      '${seasons['-1']?['t'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ]),
                ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPlayerHeader(),
                        const SizedBox(height: 20),
                        buildClubHistory(),
                        const SizedBox(height: 20),
                        const Text(
                          'Games Statistics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003471),
                          ),
                        ),
                        buildGamesTable(),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }
}
