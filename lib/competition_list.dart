import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompetitionListPage extends StatefulWidget {
  const CompetitionListPage({super.key});

  @override
  _CompetitionListPageState createState() => _CompetitionListPageState();
}

class _CompetitionListPageState extends State<CompetitionListPage> {
  List<dynamic> competitions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompetitions();
  }

  Future<void> fetchCompetitions() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.finalwhistle.ie/soccer/?feed=json-competitions'),
      );

      if (response.statusCode == 200) {
        setState(() {
          competitions = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load competitions: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitions'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: competitions.length,
              itemBuilder: (context, index) {
                final competition = competitions[index];
                return CompetitionTile(
                  competitionName: competition['competition_name'] ?? 'Unknown Competition',
                  parentCompetition: competition['parent_competition'],
                );
              },
            ),
    );
  }
}

class CompetitionTile extends StatelessWidget {
  final String competitionName;
  final Map<String, dynamic>? parentCompetition;

  const CompetitionTile({
    super.key,
    required this.competitionName,
    this.parentCompetition,
  });

  @override
  Widget build(BuildContext context) {
    final parentName = parentCompetition?['parent_name'] ?? 'No Parent';
    return ListTile(
      title: Text(
        competitionName,
        style: TextStyle(
          fontWeight: parentCompetition == null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: parentCompetition != null ? Text('Parent: $parentName') : null,
      leading: Icon(
        parentCompetition == null ? Icons.sports_soccer : Icons.subdirectory_arrow_right,
      ),
      onTap: () {
        // Handle navigation to competition details, if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $competitionName')),
        );
      },
    );
  }
}