import 'package:flutter/material.dart';
import 'match_model.dart';
import 'competition_page.dart';
import 'package:intl/intl.dart'; // For date formatting

class MatchDisplayResult extends StatelessWidget {
  final Match match;

  const MatchDisplayResult(this.match, {super.key});

  /// Sanitize text to remove unwanted ASCII codes and special characters
  String sanitizeText(String? text) {
    if (text == null) return '';
    return text
        .replaceAll(r"\'", "'") // Replace escaped single quotes
        .replaceAll('&8217;', "'") // Replace ASCII code for apostrophe
        .replaceAll('&quot;', '"') // Replace ASCII code for quotation marks
        .replaceAll('&amp;', '&') // Replace ASCII code for ampersand
        .replaceAll('&lt;', '<') // Replace ASCII code for less-than
        .replaceAll('&gt;', '>') // Replace ASCII code for greater-than
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '') // Remove unsupported HTML entities
        .trim();
  }

  /// Format time to 12-hour clock with AM/PM
  String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Widget to display red card icon
  Widget redCardIcon(int? redCards) {
    if (redCards != null && redCards > 0) {
      return Container(
        width: 16,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.red,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: Text(
            redCards > 1 ? '$redCards' : '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Widget to determine and display the score based on sport
  Widget getScore() {
    String displayText;

    if (match.matchStatus != 'Result' && match.matchStatus.isNotEmpty) {
      // Handle match status as score
      switch (match.matchStatus) {
        case 'Abandoned':
          displayText = 'A - A';
          break;
        case 'Cancelled':
        case 'Canceled':
          displayText = 'C - C';
          break;
        default:
          displayText = match.matchStatus.toUpperCase();
      }
    } else if (match.sportSlug == 'gaelic' ||
        match.sportSlug == 'hurling' ||
        match.sportSlug == 'ladiesfootball' ||
        match.sportSlug == 'camogie') {
      // Gaelic sports score format
      displayText =
          '${match.homeGoals ?? 0}-${match.homePoints ?? 0} - ${match.awayGoals ?? 0}-${match.awayPoints ?? 0}';
    } else {
      // Default score format for soccer, rugby, and others
      displayText =
          '${match.homeTeamScore ?? '-'} - ${match.awayTeamScore ?? '-'}';
    }

    return Text(
      displayText,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF003471),
      ),
    );
  }

  /// Widget to display penalties or tries under the score
  Widget getPenaltyOrTries() {
    String text = '';

    if (match.sportSlug == 'rugby') {
      if (match.homeTriesScored != null && match.awayTriesScored != null) {
        text += '(${match.homeTriesScored}T - ${match.awayTriesScored}T)';
      }
    }

    if (match.homePSO != null && match.awayPSO != null) {
      if (text.isNotEmpty) text += ' ';
      text += '(${match.homePSO}-${match.awayPSO} pens)';
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Color(0xFF003471), // Brand color
      ),
    );
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
            builder: (context) => CompetitionPage(
              sportSlug: sanitizeText(match.sportSlug),
              leagueSlug: sanitizeText(match.leagueSlug),
              seasonSlug: sanitizeText(match.seasonSlug),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                // Home Team Logo and Name
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
                // Competition Details and Score
                Expanded(
                  flex: 2,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          redCardIcon(match.homeRedCards),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              getScore(),
                              getPenaltyOrTries(),
                            ],
                          ),
                          const SizedBox(width: 8),
                          redCardIcon(match.awayRedCards),
                        ],
                      ),
                    ],
                  ),
                ),
                // Away Team Logo and Name
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
            // Venue and Time
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
