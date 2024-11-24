import 'package:flutter/material.dart';
import 'match_model.dart';
import 'match_display_fixture.dart';
import 'match_display_result.dart';
import 'match_display_live.dart';

class MatchDisplay extends StatelessWidget {
  final Match match;

  const MatchDisplay(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamically select the appropriate widget based on the match's status
    Widget matchWidget;

    if (match.matchStatus == 'Live') {
      matchWidget = MatchDisplayLive(match);
    } else if (match.matchStatus == 'Fixture') {
      matchWidget = MatchDisplayFixture(match);
    } else if (match.matchStatus == 'Result') {
      matchWidget = MatchDisplayResult(match);
    } else {
      matchWidget = MatchDisplayResult(match);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        matchWidget,
      ],
    );
  }
}