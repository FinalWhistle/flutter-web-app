import 'package:flutter/material.dart';
import 'match_model.dart';
import 'competition_page.dart';
import 'event_page.dart';
import 'package:intl/intl.dart'; // For date formatting

class MatchDisplayFixture extends StatelessWidget {
  final Match match;

  const MatchDisplayFixture(this.match, {super.key});

  /// Sanitize text to remove unwanted ASCII codes and special characters
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

  /// Format time to 12-hour clock with AM/PM
  String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    String venueText = (match.venue?.isNotEmpty == true)
        ? sanitizeText(match.venue)
        : 'Venue TBC';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EventPage(),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Center(
                        child: Image.network(
                          match.homeTeamCrest,
                          width: 75,
                          height: 75,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sanitizeText(match.homeTeamName),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompetitionPage(
                                sportSlug: sanitizeText(match.sportSlug),
                                leagueSlug: sanitizeText(match.leagueSlug),
                                seasonSlug: sanitizeText(match.seasonSlug),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              sanitizeText(match.competitionName),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003471),
                              ),
                            ),
                            Text(
                              sanitizeText(match.competitionRound),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF003471),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'V',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003471),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Center(
                        child: Image.network(
                          match.awayTeamCrest,
                          width: 75,
                          height: 75,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sanitizeText(match.awayTeamName),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: Text(
                '$venueText / ${formatTime(match.eventDateTime)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF003471),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}