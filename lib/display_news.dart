import 'package:finalwhistle_user/news_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'app_bar.dart';
import 'bottom_menu.dart';

class DisplayNewsPage extends StatefulWidget {
  final String feedUrl;
  final String? sport;

  const DisplayNewsPage({super.key, required this.feedUrl, this.sport});

  @override
  _DisplayNewsPageState createState() => _DisplayNewsPageState();
}

class _DisplayNewsPageState extends State<DisplayNewsPage> {
  Map<String, dynamic>? _newsDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoryDetails();
  }

  Future<void> _fetchStoryDetails() async {
    try {
      final response = await http.get(Uri.parse('${widget.feedUrl}feed/rss/?withoutcomments=1'));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final item = document.findAllElements('item').first;

        final contentEncoded = _safeParse(item, 'content:encoded');
        final title = _safeParse(item, 'title');
        final author = _safeParse(item, 'dc:creator');
        final pubDate = _formatPubDate(_safeParse(item, 'pubDate'));
        final category = _safeParse(item, 'category');

        setState(() {
          _newsDetails = {
            'title': title,
            'content': _extractRelevantContent(contentEncoded),
            'author': author,
            'pubDate': pubDate,
            'category': category,
            'imageUrl': _extractImageUrl(contentEncoded),
          };
          _isLoading = false;
        });
      } else {
        _handleError('Failed to fetch data');
      }
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _handleError(String message) {
    debugPrint('Error: $message');
    setState(() {
      _isLoading = false;
    });
  }

  String _safeParse(xml.XmlElement item, String tagName) {
    try {
      return item.findElements(tagName).first.text.trim();
    } catch (_) {
      return '';
    }
  }

  String _extractRelevantContent(String? content) {
    if (content == null || content.isEmpty) return 'No content available.';

    // Extract content after the last marker
    final marker = '800px" /></p>\n<p>';
    final lastIndex = content.lastIndexOf(marker);
    if (lastIndex != -1) {
      content = content.substring(lastIndex + marker.length);
    }

    // Remove content between <span id> and </span>, process strong tags, and sanitize
    content = content.replaceAll(RegExp(r'<span id.*?</span>'), '');
    return _sanitizeContent(content);
  }

  String _sanitizeContent(String content) {
    return content
        .replaceAllMapped(
          RegExp(r'<strong>(.*?)</strong>'),
          (match) => '**${match.group(1)?.trim() ?? ''}**', // Format strong text as bold
        )
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '') // Remove HTML entities
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<p>', '\n')
        .replaceAll('</p>', '\n') // Replace paragraph tags with newlines
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove all other HTML tags
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // Reduce consecutive newlines to a single blank line
        .trim();
  }

  String _extractImageUrl(String? content) {
    if (content == null || content.isEmpty) return '';
    final match = RegExp(r'srcset="([^"]+)"').firstMatch(content);
    if (match != null) {
      final fullUrl = match.group(1) ?? '';
      final firstSpaceIndex = fullUrl.indexOf(' ');
      return firstSpaceIndex != -1 ? fullUrl.substring(0, firstSpaceIndex) : fullUrl;
    }
    return '';
  }

  String _formatPubDate(String pubDate) {
    try {
      final dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(pubDate);
      return DateFormat("EEE, dd MMM yyyy").format(dateTime);
    } catch (_) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _newsDetails == null
              ? const Center(child: Text('No details available.'))
              : Column(
                  children: [
                    const NewsMenu(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_newsDetails!['imageUrl'] != null &&
                                _newsDetails!['imageUrl'].isNotEmpty)
                              Image.network(
                                _newsDetails!['imageUrl'],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              _newsDetails!['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 20.4,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003471),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_newsDetails!['category']} · ${_newsDetails!['author']} · ${_newsDetails!['pubDate']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            _buildFormattedContent(_newsDetails!['content'] ?? ''),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const BottomMenuBar(),
    );
  }

  Widget _buildFormattedContent(String content) {
    final spans = <InlineSpan>[];
    final parts = content.split('**');
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i % 2 == 0
            ? const TextStyle() // Regular text
            : const TextStyle(fontWeight: FontWeight.bold), // Bold text
      ));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black),
        children: spans,
      ),
    );
  }
}