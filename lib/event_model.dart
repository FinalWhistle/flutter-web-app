
class Event {
  final String lastBuildDate;
  final int eventId;
  final String eventTitle;
  final String status;
  final DateTime eventDateTime;
  final DateTime liveStartDateTime;
  final DateTime liveEndDateTime;
  final LiveEventLog liveEventLog;
  final String minutesPassed;
  final String? featuredImageUrl;
  final Teams teams;
  final Players players;
  final Staff staff;
  final String round;
  final List<Venue> venues;
  final List<League> leagues;
  final List<Season> seasons;
  final Timeline timeline;
  final Winner winner;
  final List<Commentary> commentaries;

  Event({
    required this.lastBuildDate,
    required this.eventId,
    required this.eventTitle,
    required this.status,
    required this.eventDateTime,
    required this.liveStartDateTime,
    required this.liveEndDateTime,
    required this.liveEventLog,
    required this.minutesPassed,
    this.featuredImageUrl,
    required this.teams,
    required this.players,
    required this.staff,
    required this.round,
    required this.venues,
    required this.leagues,
    required this.seasons,
    required this.timeline,
    required this.winner,
    required this.commentaries,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      lastBuildDate: json['lastBuildDate'],
      eventId: json['event_id'],
      eventTitle: json['event_title'],
      status: json['status'],
      eventDateTime: DateTime.parse(json['event_datetime']),
      liveStartDateTime: DateTime.parse(json['live_start_datetime']),
      liveEndDateTime: DateTime.parse(json['live_end_datetime']),
      liveEventLog: LiveEventLog.fromJson(json['live_event_log']),
      minutesPassed: json['minutes_passed'],
      featuredImageUrl: json['featured_image_url'],
      teams: Teams.fromJson(json['teams']),
      players: Players.fromJson(json['players']),
      staff: Staff.fromJson(json['staff']),
      round: json['round'],
      venues: (json['venues'] as List)
          .map((venueJson) => Venue.fromJson(venueJson))
          .toList(),
      leagues: (json['leagues'] as List)
          .map((leagueJson) => League.fromJson(leagueJson))
          .toList(),
      seasons: (json['seasons'] as List)
          .map((seasonJson) => Season.fromJson(seasonJson))
          .toList(),
      timeline: Timeline.fromJson(json['timeline']),
      winner: Winner.fromJson(json['winner']),
      commentaries: (json['commentaries'] as List)
          .map((commJson) => Commentary.fromJson(commJson))
          .toList(),
    );
  }
}

class LiveEventLog {
  final Map<String, LiveEvent> events;

  LiveEventLog({required this.events});

  factory LiveEventLog.fromJson(Map<String, dynamic> json) {
    Map<String, LiveEvent> events = {};
    json.forEach((key, value) {
      events[key] = LiveEvent.fromJson(value);
    });
    return LiveEventLog(events: events);
  }
}

class LiveEvent {
  final String status;
  final String type;
  final String message;

  LiveEvent({
    required this.status,
    required this.type,
    required this.message,
  });

  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    return LiveEvent(
      status: json['status'],
      type: json['type'],
      message: json['message'],
    );
  }
}

class Teams {
  final Team homeTeam;
  final Team awayTeam;

  Teams({required this.homeTeam, required this.awayTeam});

  factory Teams.fromJson(Map<String, dynamic> json) {
    return Teams(
      homeTeam: Team.fromJson(json['home_team']),
      awayTeam: Team.fromJson(json['away_team']),
    );
  }
}

class Team {
  final String teamId;
  final String teamName;
  final String imageUrl;
  final Results results;

  Team({
    required this.teamId,
    required this.teamName,
    required this.imageUrl,
    required this.results,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['team_id'],
      teamName: json['team_name'],
      imageUrl: json['image_url'],
      results: Results.fromJson(json['results']),
    );
  }
}

class Results {
  final String redcards;
  final String goals;
  final String pso;
  final List<String> outcome;

  Results({
    required this.redcards,
    required this.goals,
    required this.pso,
    required this.outcome,
  });

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      redcards: json['redcards'],
      goals: json['goals'],
      pso: json['pso'],
      outcome: List<String>.from(json['outcome']),
    );
  }
}

class Players {
  final Map<String, List<Player>> playersByTeam;

  Players({required this.playersByTeam});

  factory Players.fromJson(Map<String, dynamic> json) {
    Map<String, List<Player>> playersByTeam = {};
    json.forEach((teamId, playersList) {
      playersByTeam[teamId] = (playersList as List)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList();
    });
    return Players(playersByTeam: playersByTeam);
  }
}

class Player {
  final int playerId;
  final String name;
  final Performance performance;
  final String? imageUrl;

  Player({
    required this.playerId,
    required this.name,
    required this.performance,
    this.imageUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['player_id'],
      name: json['name'],
      performance: Performance.fromJson(json['performance']),
      imageUrl: json['image_url'],
    );
  }
}

class Performance {
  final String number;
  final List<dynamic> position;
  final String goals;
  final String assists;
  final String yellowcards;
  final String secondcard;
  final String redcards;
  final String cleansheets;
  final String owngoals;
  final String status;
  final String sub;

  Performance({
    required this.number,
    required this.position,
    required this.goals,
    required this.assists,
    required this.yellowcards,
    required this.secondcard,
    required this.redcards,
    required this.cleansheets,
    required this.owngoals,
    required this.status,
    required this.sub,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      number: json['number'],
      position: json['position'],
      goals: json['goals'],
      assists: json['assists'],
      yellowcards: json['yellowcards'],
      secondcard: json['secondcard'],
      redcards: json['redcards'],
      cleansheets: json['cleansheets'],
      owngoals: json['owngoals'],
      status: json['status'],
      sub: json['sub'],
    );
  }
}

class Staff {
  final StaffMember homeTeam;
  final StaffMember awayTeam;

  Staff({required this.homeTeam, required this.awayTeam});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      homeTeam: StaffMember.fromJson(json['home_team']),
      awayTeam: StaffMember.fromJson(json['away_team']),
    );
  }
}

class StaffMember {
  final String staffId;
  final String name;
  final List<String> roles;
  final String? imageUrl;

  StaffMember({
    required this.staffId,
    required this.name,
    required this.roles,
    this.imageUrl,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      staffId: json['staff_id'],
      name: json['name'],
      roles: List<String>.from(json['roles']),
      imageUrl: json['image_url'],
    );
  }
}

class Venue {
  final int id;
  final String name;

  Venue({required this.id, required this.name});

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
    );
  }
}

class League {
  final int id;
  final String name;
  final String slug;

  League({required this.id, required this.name, required this.slug});

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class Season {
  final int id;
  final String name;
  final String slug;

  Season({required this.id, required this.name, required this.slug});

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class Timeline {
  final Map<String, PlayerTimeline> timelineByTeam;

  Timeline({required this.timelineByTeam});

  factory Timeline.fromJson(Map<String, dynamic> json) {
    Map<String, PlayerTimeline> timelineByTeam = {};
    json.forEach((teamId, players) {
      timelineByTeam[teamId] = PlayerTimeline.fromJson(players);
    });
    return Timeline(timelineByTeam: timelineByTeam);
  }
}

class PlayerTimeline {
  final Map<String, PlayerAction> actions;

  PlayerTimeline({required this.actions});

  factory PlayerTimeline.fromJson(Map<String, dynamic> json) {
    Map<String, PlayerAction> actions = {};
    json.forEach((playerId, action) {
      actions[playerId] = PlayerAction.fromJson(action);
    });
    return PlayerTimeline(actions: actions);
  }
}

class PlayerAction {
  final List<String> yellowcards;
  final List<String> goals;
  final List<String> sub;
  final List<String> secondcard;

  PlayerAction({
    required this.yellowcards,
    required this.goals,
    required this.sub,
    required this.secondcard,
  });

  factory PlayerAction.fromJson(Map<String, dynamic> json) {
    return PlayerAction(
      yellowcards: json['yellowcards'] != null
          ? List<String>.from(json['yellowcards'])
          : [],
      goals: json['goals'] != null ? List<String>.from(json['goals']) : [],
      sub: json['sub'] != null ? List<String>.from(json['sub']) : [],
      secondcard: json['secondcard'] != null
          ? List<String>.from(json['secondcard'])
          : [],
    );
  }
}

class Winner {
  final int? teamId;
  final String? teamName;

  Winner({this.teamId, this.teamName});

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      teamId: json['team_id'],
      teamName: json['team_name'],
    );
  }
}

class Commentary {
  final String id;
  final String postId;
  final String minute;
  final String text;
  final String icon;
  final String? confId;
  final String playerId;
  final DateTime date;
  final DateTime updated;

  Commentary({
    required this.id,
    required this.postId,
    required this.minute,
    required this.text,
    required this.icon,
    this.confId,
    required this.playerId,
    required this.date,
    required this.updated,
  });

  factory Commentary.fromJson(Map<String, dynamic> json) {
    return Commentary(
      id: json['id'],
      postId: json['post_id'],
      minute: json['minute'],
      text: json['text'],
      icon: json['icon'],
      confId: json['conf_id'],
      playerId: json['player_id'],
      date: DateTime.parse(json['date']),
      updated: DateTime.parse(json['updated']),
    );
  }
}