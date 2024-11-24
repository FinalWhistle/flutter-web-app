import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompetitionInformation extends StatefulWidget {
  final String sportSlug;
  final String leagueSlug;
  final String seasonSlug;

  const CompetitionInformation({
    super.key,
    required this.sportSlug,
    required this.leagueSlug,
    required this.seasonSlug,
  });

  @override
  State<CompetitionInformation> createState() => _CompetitionInformationState();
}

class _CompetitionInformationState extends State<CompetitionInformation> {
  List<Map<String, dynamic>> _tables = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isCompactView = true; // Toggle between compact and full view
  late String _currentSeasonSlug; // Track the current seasonSlug

  @override
  void initState() {
    super.initState();
    _currentSeasonSlug = widget.seasonSlug;
    _fetchLeagueTables();
  }

  @override
  void didUpdateWidget(covariant CompetitionInformation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seasonSlug != oldWidget.seasonSlug) {
      setState(() {
        _currentSeasonSlug = widget.seasonSlug;
        _isLoading = true;
        _errorMessage = '';
        _tables = [];
      });
      _fetchLeagueTables();
    }
  }

  /// Fetch league tables from the API
  Future<void> _fetchLeagueTables() async {
    final url =
        'https://www.finalwhistle.ie/${widget.sportSlug}/?feed=json-tables&league=${widget.leagueSlug}&season=$_currentSeasonSlug';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Process tables if data is valid
        if (data is Map<String, dynamic>) {
          List<Map<String, dynamic>> tables = [];
          data.forEach((key, value) {
            if (value is Map<String, dynamic> && value['table_title'] != null) {
              tables.add({
                'title': value['table_title'],
                'data': value['table_data'],
                'labels': value['table_labels'],
              });
            }
          });

          setState(() {
            _tables = tables;
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid data format received.');
        }
      } else {
        throw Exception('Failed to fetch tables: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching league tables: $e';
        _isLoading = false;
      });
    }
  }

  /// Sanitizes text by replacing HTML entities with their actual characters
  String sanitizeText(String? input) {
    if (input == null) return '';
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), ''); // Removes other unsupported HTML entities
  }

  /// Get columns for the table view
  List<DataColumn> _getTableColumns(Map<String, dynamic> labels, bool isCompact) {
    // Exclude unwanted columns for Camogie
    final excludedColumns = widget.sportSlug == 'camogie' ? ['manualorder', 'manual order'] : [];
    final filteredKeys = labels.keys.where((key) => !excludedColumns.contains(key.toLowerCase()));

    if (widget.sportSlug == 'rugby' && isCompact) {
      return ['pos', 'name', 'p', 'pd', 'bp', 'pts']
          .map((key) => DataColumn(label: Text(labels[key] ?? key.toUpperCase())))
          .toList();
    } else if (widget.sportSlug == 'soccer' && isCompact) {
      return ['pos', 'name', 'p', 'gd', 'pts']
          .map((key) => DataColumn(label: Text(labels[key] ?? key.toUpperCase())))
          .toList();
    } else if (widget.sportSlug == 'gaelic' && isCompact) {
      return ['pos', 'name', 'p', 'pd', 'pts']
          .map((key) => DataColumn(label: Text(labels[key] ?? key.toUpperCase())))
          .toList();
    } else if (isCompact) {
      return ['pos', 'name', 'p', 'pd', 'pts']
          .map((key) => DataColumn(label: Text(labels[key] ?? key.toUpperCase())))
          .toList();
    } else {
      return filteredKeys
          .map((key) => DataColumn(label: Text(labels[key] ?? key.toUpperCase())))
          .toList();
    }
  }

  /// Get rows for the table view
  List<DataRow> _getTableRows(
    Map<String, dynamic> data,
    Map<String, dynamic> labels,
    bool isCompact,
  ) {
    return data.entries.map((entry) {
      final rowData = entry.value as Map<String, dynamic>;

      if (widget.sportSlug == 'rugby' && isCompact) {
        return DataRow(
          cells: [
            DataCell(Text(rowData['pos']?.toString() ?? '')),
            DataCell(Text(sanitizeText(rowData['name']))),
            DataCell(Text(rowData['p']?.toString() ?? '')),
            DataCell(Text(rowData['pd']?.toString() ?? '')),
            DataCell(Text(
              ((int.tryParse(rowData['tb'] ?? '0') ?? 0) +
                      (int.tryParse(rowData['lb'] ?? '0') ?? 0))
                  .toString(),
            )),
            DataCell(Text(rowData['pts']?.toString() ?? '')),
          ],
        );
      } else if (widget.sportSlug == 'soccer' && isCompact) {
        return DataRow(
          cells: [
            DataCell(Text(rowData['pos']?.toString() ?? '')),
            DataCell(Text(sanitizeText(rowData['name']))),
            DataCell(Text(rowData['p']?.toString() ?? '')),
            DataCell(Text(rowData['gd']?.toString() ?? '')), // Goal Difference (GD)
            DataCell(Text(rowData['pts']?.toString() ?? '')),
          ],
        );
      } else if (widget.sportSlug == 'gaelic' && isCompact) {
        return DataRow(
          cells: ['pos', 'name', 'p', 'pd', 'pts']
              .map((key) => DataCell(Text(rowData[key]?.toString() ?? '')))
              .toList(),
        );
      } else if (isCompact) {
        return DataRow(
          cells: ['pos', 'name', 'p', 'pd', 'pts']
              .map((key) => DataCell(Text(rowData[key]?.toString() ?? '')))
              .toList(),
        );
      } else {
        return DataRow(
          cells: labels.keys
              .where((key) =>
                  !(widget.sportSlug == 'camogie' && key.toLowerCase() == 'manualorder')) // Exclude manualorder
              .map((key) => DataCell(Text(sanitizeText(rowData[key]?.toString() ?? ''))))
              .toList(),
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _tables.map((table) {
                  final tableTitle = table['title'];
                  final tableData = table['data'];
                  final tableLabels = table['labels'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Title
                      Text(
                        tableTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Toggle Button for Compact/Full View
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isCompactView = !_isCompactView;
                            });
                          },
                          child: Text(
                            _isCompactView ? 'Show Full Table' : 'Show Compact Table',
                          ),
                        ),
                      ),

                      // League Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: DataTable(
                            columnSpacing: 10,
                            columns: _getTableColumns(tableLabels, _isCompactView),
                            rows: _getTableRows(tableData, tableLabels, _isCompactView),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
