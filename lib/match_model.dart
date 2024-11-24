
class Match {
  final String eventId;
  final String competitionName;
  final String competitionRound;
  final DateTime eventDateTime;
  final String homeTeamName;
  final String awayTeamName;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final String homeTeamCrest;
  final String awayTeamCrest;
  final String? venue;
  final String sport;
  final String sportSlug; // New variable for sportSlug
  final String matchOutcome;
  final String matchStatus;
  final int? homeRedCards;
  final int? awayRedCards;
  final int? currentMinutes;
  final String clockMessage;

  // Additional time-related fields
  final DateTime? liveStart;
  final DateTime? liveEnd;

  // Rugby-specific
  final int? homeTriesScored;
  final int? awayTriesScored;

  // Gaelic, Hurling, Ladies Football, Camogie-specific
  final int? homeBlackCards;
  final int? awayBlackCards;
  final int? homeGoals;
  final int? homePoints;
  final int? awayGoals;
  final int? awayPoints;

  // Soccer-specific PSO (Penalty Shootout) Scores
  final int? homePSO;
  final int? awayPSO;

  // Additional fields
  final String leagueSlug;
  final String seasonSlug;

  Match({
    required this.eventId,
    required this.competitionName,
    required this.competitionRound,
    required this.eventDateTime,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamScore,
    this.awayTeamScore,
    required this.homeTeamCrest,
    required this.awayTeamCrest,
    this.venue,
    required this.sport,
    required this.sportSlug, // Add sportSlug to constructor
    required this.matchOutcome,
    required this.matchStatus,
    this.homeRedCards,
    this.awayRedCards,
    this.currentMinutes,
    required this.clockMessage,
    this.liveStart,
    this.liveEnd,
    this.homeTriesScored,
    this.awayTriesScored,
    this.homeBlackCards,
    this.awayBlackCards,
    this.homeGoals,
    this.homePoints,
    this.awayGoals,
    this.awayPoints,
    this.homePSO,
    this.awayPSO,
    required this.leagueSlug,
    required this.seasonSlug,
  });

  /// Sanitize strings to remove unwanted characters
  static String sanitizeString(String? input) {
    if (input == null) return '';
    String sanitized = input
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '') // Remove non-ASCII characters
        .trim(); // Remove leading and trailing whitespace
    sanitized = sanitized
        .replaceAll("'", "\\'")
        .replaceAll('"', '\\"')
        .replaceAll("\n", " ")
        .replaceAll("\r", " ");
    return sanitized;
  }

  /// Add size to team crest URLs
  static String addSizeToCrest(String? url) {
    if (url == null || url.isEmpty) return '';
    final lastDotIndex = url.lastIndexOf('.');
    if (lastDotIndex == -1) return url; // No file extension
    return '${url.substring(0, lastDotIndex)}-32x32${url.substring(lastDotIndex)}';
  }

  /// Get sportSlug from sport
  static String getSportSlug(String sport) {
    switch (sport.toLowerCase()) {
      case 'gaelic football':
        return 'gaelic';
      case 'hurling':
        return 'hurling';
      case 'camogie':
        return 'camogie';
      case 'rugby':
        return 'rugby';
      case 'ladies football':
        return 'ladiesfootball';
      case 'soccer':
        return 'soccer';
      default:
        return 'unknown';
    }
  }

  factory Match.fromJson(Map<String, dynamic> json, String sport) {
    dynamic getValue(dynamic value, List<String> keys) {
      for (String key in keys) {
        if (value is Map && value.containsKey(key)) {
          value = value[key];
        } else {
          return null; // Return null if value is not a Map or key doesn't exist
        }
      }
      return value;
    }

    String competitionName = 'Unknown Competition';
    String leagueSlug = 'unknown-league';
    String seasonSlug = 'unknown-season';

    if (json['leagues'] is List && (json['leagues'] as List).isNotEmpty) {
      final league = json['leagues'][0];
      competitionName = league['name']?.toString() ?? 'Unknown Competition';
      leagueSlug = league['slug']?.toString() ?? 'unknown-league';
    }

    if (json['seasons'] is List && (json['seasons'] as List).isNotEmpty) {
      final season = json['seasons'][0];
      seasonSlug = season['slug']?.toString() ?? 'unknown-season';
    }

    DateTime now = DateTime.now();
    DateTime eventDate =
        DateTime.tryParse(json['event_date']?['datetime']?.toString() ?? '') ??
            now;

    DateTime? liveStart =
        DateTime.tryParse(json['live_start']?['datetime']?.toString() ?? '');
    DateTime? liveEnd =
        DateTime.tryParse(json['live_end']?['datetime']?.toString() ?? '');

    String homeOutcome =
        getValue(json, ['home_team', 'results', 'outcome'])?.toString() ?? '';
    String awayOutcome =
        getValue(json, ['away_team', 'results', 'outcome'])?.toString() ?? '';

    int? currentMinutes =
        int.tryParse(json['minutes_passed']?.toString() ?? '');

    String clockMessage = '';
    if (json['live_event_log'] is Map<String, dynamic>) {
      Map<String, dynamic> liveEventLog = json['live_event_log'];

      if (liveEventLog.isNotEmpty) {
        var lastLogEntry = liveEventLog.entries.last.value;
        clockMessage =
            sanitizeString(lastLogEntry['message']?.toString() ?? '');
      }
    }

    String? venueName;
    if (json['venues'] is List && (json['venues'] as List).isNotEmpty) {
      venueName = sanitizeString(json['venues'][0]['name']?.toString());
    } else {
      venueName = null;
    }

    String matchStatus = json['status']?.toString() ?? '';
    if (matchStatus.isNotEmpty && matchStatus.toLowerCase() != 'on time') {
      matchStatus = matchStatus;
    } else {
      if (liveStart != null && liveStart.isBefore(now) && liveEnd == null) {
        matchStatus = 'Live';
      } else if (liveEnd != null ||
          (homeOutcome.isNotEmpty && awayOutcome.isNotEmpty)) {
        matchStatus = 'Result';
      } else {
        matchStatus = 'Fixture';
      }
    }

    return Match(
      eventId: sanitizeString(json['event_id']?.toString()),
      competitionName: sanitizeString(competitionName),
      competitionRound: sanitizeString(json['round']?.toString()),
      eventDateTime: eventDate,
      liveStart: liveStart,
      liveEnd: liveEnd,
      homeTeamName: sanitizeString(getValue(json, ['home_team', 'name'])),
      awayTeamName: sanitizeString(getValue(json, ['away_team', 'name'])),
      homeTeamScore: sport.toLowerCase() == 'soccer'
          ? int.tryParse(
              getValue(json, ['home_team', 'results', 'goals'])?.toString() ??
                  '0')
          : (sport.toLowerCase() == 'rugby'
              ? int.tryParse(
                  getValue(json, ['home_team', 'results', 'points'])
                          ?.toString() ??
                      '0')
              : int.tryParse(
                  getValue(json, ['home_team', 'results', 'score'])
                          ?.toString() ??
                      '0')),
      awayTeamScore: sport.toLowerCase() == 'soccer'
          ? int.tryParse(
              getValue(json, ['away_team', 'results', 'goals'])?.toString() ??
                  '0')
          : (sport.toLowerCase() == 'rugby'
              ? int.tryParse(
                  getValue(json, ['away_team', 'results', 'points'])
                          ?.toString() ??
                      '0')
              : int.tryParse(
                  getValue(json, ['away_team', 'results', 'score'])
                          ?.toString() ??
                      '0')),
      currentMinutes: currentMinutes,
      clockMessage: clockMessage,
      matchStatus: matchStatus,
      leagueSlug: sanitizeString(leagueSlug),
      seasonSlug: sanitizeString(seasonSlug),
      homeTriesScored: sport.toLowerCase() == 'rugby'
          ? int.tryParse(
              getValue(json, ['home_team', 'results', 'tries'])?.toString() ??
                  '0')
          : null,
      awayTriesScored: sport.toLowerCase() == 'rugby'
          ? int.tryParse(
              getValue(json, ['away_team', 'results', 'tries'])?.toString() ??
                  '0')
          : null,
      homeGoals: (sport.toLowerCase() == 'gaelic football' ||
              sport.toLowerCase() == 'hurling' ||
              sport.toLowerCase() == 'ladies football' ||
              sport.toLowerCase() == 'camogie')
          ? int.tryParse(
              getValue(json, ['home_team', 'results', 'goals'])?.toString() ??
                  '0')
          : null,
      homePoints: (sport.toLowerCase() == 'gaelic football' ||
              sport.toLowerCase() == 'hurling' ||
              sport.toLowerCase() == 'ladies football' ||
              sport.toLowerCase() == 'camogie')
          ? int.tryParse(
              getValue(json, ['home_team', 'results', 'points'])?.toString() ??
                  '0')
          : null,
      awayGoals: (sport.toLowerCase() == 'gaelic football' ||
              sport.toLowerCase() == 'hurling' ||
              sport.toLowerCase() == 'ladies football' ||
              sport.toLowerCase() == 'camogie')
          ? int.tryParse(
              getValue(json, ['away_team', 'results', 'goals'])?.toString() ??
                  '0')
          : null,
      awayPoints: (sport.toLowerCase() == 'gaelic football' ||
              sport.toLowerCase() == 'hurling' ||
              sport.toLowerCase() == 'ladies football' ||
              sport.toLowerCase() == 'camogie')
          ? int.tryParse(
              getValue(json, ['away_team', 'results', 'points'])?.toString() ??
                  '0')
          : null,
      homePSO: sport.toLowerCase() == 'soccer'
          ? int.tryParse(
              getValue(json, ['home_team', 'results', 'pso'])?.toString() ??
                  '0')
          : null,
      awayPSO: sport.toLowerCase() == 'soccer'
          ? int.tryParse(
              getValue(json, ['away_team', 'results', 'pso'])?.toString() ??
                  '0')
          : null,
      homeTeamCrest: addSizeToCrest(
          sanitizeString(getValue(json, ['home_team', 'featured_image']))),
      awayTeamCrest: addSizeToCrest(
          sanitizeString(getValue(json, ['away_team', 'featured_image']))),
      venue: venueName,
      sport: sanitizeString(sport),
      sportSlug: getSportSlug(sanitizeString(sport)), // Assign sportSlug
      matchOutcome: sanitizeString(json['outcome']?.toString()),
      homeRedCards: int.tryParse(
          getValue(json, ['home_team', 'results', 'redcards'])?.toString() ??
              '0'),
      awayRedCards: int.tryParse(
          getValue(json, ['away_team', 'results', 'redcards'])?.toString() ??
              '0'),
      homeBlackCards: int.tryParse(
          getValue(json, ['home_team', 'results', 'black_cards'])
                  ?.toString() ??
              '0'),
      awayBlackCards: int.tryParse(
          getValue(json, ['away_team', 'results', 'black_cards'])
                  ?.toString() ??
              '0'),
    );
  }
}
