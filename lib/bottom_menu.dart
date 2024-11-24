import 'package:flutter/material.dart';
import 'main.dart';
import 'search_page.dart';
import 'live_scores_page.dart';
import 'news_feed_page.dart';
import 'podcasts.dart';
import 'player_profile.dart'; // Import the PlayerProfile page

class BottomMenuBar extends StatelessWidget {
  const BottomMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF003471), // Set the background color to hex #003471
      height: 40.0,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 10.0),
          buildBottomMenuButton(context, Icons.home, 'Home', const MyApp()),
          buildBottomMenuButton(context, Icons.search, 'Search', const SearchPage()),
          buildBottomMenuButton(context, Icons.sensors, 'Live Scores', const LiveScoresPage()),
          buildBottomMenuButton(
            context,
            Icons.text_snippet_outlined,
            'News',
            const NewsFeedPage(), // Removed feedUrl dependency
          ),
          buildBottomMenuButton(context, Icons.podcasts, 'Podcasts', const PodcastsPage()),
          buildBottomMenuButton(
            context,
            Icons.person, // Icon for the first player profile
            'Player Profile',
            const PlayerProfile(playerID: 243, sportSlug: 'rugby'),
          ),
          buildBottomMenuButton(
            context,
            Icons.sports_football, // Icon for the second player profile (Gaelic)
            'Player Profile (Gaelic)',
            const PlayerProfile(playerID: 1013, sportSlug: 'gaelic'),
          ),
          buildBottomMenuButton(
            context,
            Icons.sports_soccer, // Icon for the third player profile (Soccer)
            'Player Profile (Soccer)',
            const PlayerProfile(playerID: 2976, sportSlug: 'soccer'),
          ),
          buildBottomMenuButton(
            context,
            Icons.sports_volleyball, // Icon for the fourth player profile (Ladies Football)
            'Player Profile (Ladies Football)',
            const PlayerProfile(playerID: 777, sportSlug: 'ladiesfootball'),
          ),
          const SizedBox(width: 17.0),
        ],
      ),
    );
  }

  Widget buildBottomMenuButton(
      BuildContext context, IconData icon, String tooltip, Widget page) {
    return Expanded(
      child: IconButton(
        icon: Icon(icon, color: Colors.white), // Set icon color to white
        tooltip: tooltip,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionDuration: Duration.zero, // Remove transition animation
              reverseTransitionDuration: Duration.zero, // Remove reverse transition
            ),
          );
        },
      ),
    );
  }
}
