import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'app_bar.dart';
import 'news_menu.dart'; // Import the NewsMenu
import 'bottom_menu.dart';
import 'display_news.dart';

class NewsFeedPage extends StatefulWidget {
  final String? selectedSport; // Optional parameter for selected sport

  const NewsFeedPage({super.key, this.selectedSport});

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final List<Map<String, dynamic>> _newsItems = [];
  final List<Map<String, String>> _feeds = [
    {'sport': 'Soccer', 'url': 'https://www.finalwhistle.ie/soccer/feed/'},
    {'sport': 'Rugby', 'url': 'https://www.finalwhistle.ie/rugby/feed/'},
    {'sport': 'Gaelic', 'url': 'https://www.finalwhistle.ie/gaelic/feed/'},
    {'sport': 'Hurling', 'url': 'https://www.finalwhistle.ie/hurling/feed/'},
    {'sport': 'Camogie', 'url': 'https://www.finalwhistle.ie/camogie/feed/'},
    {'sport': 'Ladies Football', 'url': 'https://www.finalwhistle.ie/ladiesfootball/feed/'},
  ];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    if (_isFetching) return; // Prevent multiple fetches
    _isFetching = true;

    for (var feed in _feeds) {
      // Filter feeds based on selected sport, if any
      if (widget.selectedSport == null || widget.selectedSport == feed['sport']) {
        try {
          final response = await http.get(Uri.parse(feed['url']!));
          if (response.statusCode == 200) {
            final document = xml.XmlDocument.parse(response.body);
            final items = document.findAllElements('item');
            for (var item in items) {
              final title = _safeParse(item, 'title');
              final link = _safeParse(item, 'link');
              final pubDate = _safeParse(item, 'pubDate');
              final category = item.findElements('category').isNotEmpty
                  ? item.findElements('category').first.text
                  : 'Uncategorized';
              final content = _extractExcerpt(_safeParse(item, 'content:encoded'));
              final author = item.findElements('dc:creator').isNotEmpty
                  ? item.findElements('dc:creator').first.text
                  : 'Unknown';
              final imageUrl = _extractImageUrl(_safeParse(item, 'content:encoded'));

              if (title.isNotEmpty && link.isNotEmpty && pubDate.isNotEmpty) {
                _newsItems.add({
                  'sport': feed['sport'],
                  'title': title,
                  'link': link,
                  'pubDate': pubDate,
                  'category': category,
                  'author': author,
                  'description': content,
                  'image': imageUrl,
                });
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching news for ${feed['sport']}: $e');
        }
      }
    }

    // Sort stories globally by most recent pubDate
    _newsItems.sort((a, b) {
      final dateA = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(a['pubDate']);
      final dateB = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(b['pubDate']);
      return dateB.compareTo(dateA); // Most recent first
    });

    if (mounted) {
      setState(() {}); // Update UI with sorted list
    }
    _isFetching = false;
  }

  String _safeParse(xml.XmlElement item, String tagName) {
    try {
      return item.findElements(tagName).first.text.trim();
    } catch (e) {
      return '';
    }
  }

  String _extractExcerpt(String content) {
    try {
      final marker = 'sizes="(max-width: 800px) 100vw, 800px" /></p>';
      final startIndex = content.indexOf(marker);
      if (startIndex == -1) return ''; // If marker not found, return an empty string
      final contentAfterMarker = content.substring(startIndex + marker.length);
      final startPIndex = contentAfterMarker.indexOf('<p>');
      final endPIndex = contentAfterMarker.indexOf('</p>');

      if (startPIndex == -1 || endPIndex == -1 || endPIndex <= startPIndex) {
        return ''; // No valid <p>...</p> structure found
      }

      // Extract the paragraph content
      var paragraph = contentAfterMarker.substring(startPIndex + 3, endPIndex);

      // Sanitize the ASCII codes
      paragraph = _sanitizeText(paragraph);

      // Restrict to a maximum of 225 characters
      if (paragraph.length > 225) {
        paragraph = '${paragraph.substring(0, 225)}...';
      }

      return paragraph;
    } catch (e) {
      debugPrint('Error extracting excerpt: $e');
      return '';
    }
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll('&#8217;', "'") // Replace ASCII code for apostrophe
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '') // Remove other ASCII entities
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .trim();
  }

  String _extractImageUrl(String content) {
    final match = RegExp(r'src="([^"]+)"').firstMatch(content);
    return match?.group(1) ?? '';
  }

  String _formatPubDate(String pubDate) {
    try {
      final DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(pubDate);
      return DateFormat("EEE, dd MMM yyyy").format(dateTime);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          NewsMenu(), // Replace SportsMenu with NewsMenu
          Expanded(
            child: ListView.builder(
              itemCount: _newsItems.length,
              itemBuilder: (context, index) {
                final item = _newsItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisplayNewsPage(
                          feedUrl: item['link'], // Pass the story link
                          sport: item['sport'], // Pass the sport
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            if (item['image'] != null && item['image'].isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Image.network(
                                  item['image'],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                color: Colors.black54,
                                child: Text(
                                  item['sport'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003471),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['category']} · ${item['author']} · ${_formatPubDate(item['pubDate'])}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['description'],
                                style: const TextStyle(fontSize: 14),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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