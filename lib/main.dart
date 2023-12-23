import 'dart:typed_data';
import '../EventDetail.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './SearchResultsPage.dart';

void main() {
  runApp(const MyApp());
}

late Event selectedEvent;
bool isLoading = true;

class Event {
  final int id;
  final String title;
  final String description;
  final String bannerImage;
  final DateTime dateTime;
  final String organiserName;
  final String organiserIcon;
  final String venueName;
  final String venueCity;
  final String venueCountry;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.dateTime,
    required this.organiserName,
    required this.organiserIcon,
    required this.venueName,
    required this.venueCity,
    required this.venueCountry,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      bannerImage: json['banner_image'],
      dateTime: DateTime.parse(json['date_time']),
      organiserName: json['organiser_name'],
      organiserIcon: json['organiser_icon'],
      venueName: json['venue_name'],
      venueCity: json['venue_city'],
      venueCountry: json['venue_country'],
    );
  }
}

Future<Uint8List?> loadImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  } catch (e) {
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        EventDetail.routeName: (ctx) => EventDetail(
              event: selectedEvent,
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late List<Event> events;

  late EventSearch eventSearch;
  @override
  void initState() {
    super.initState();
    events = [];
    selectedEvent = Event(
      id: 1,
      title: "GopherCon Europe",
      description:
          "A conference for Go developers in Europe. GopherCon Europe is a conference for Go developers that takes place annually in Europe. It's a great opportunity to meet and learn from fellow Gophers, network with companies using Go, and get insights on the latest developments and trends in the Go community.",
      bannerImage:
          "https://files.realpython.com/media/PyGame-Update_Watermarked.bb0aa2dfe80b.jpg",
      dateTime: DateTime.now(),
      organiserName: "GopherCon Europe",
      organiserIcon:
          "https://icons-for-free.com/iconfiles/png/512/vscode+icons+type+go+gopher-1324451308133525243.png",
      venueName: "Beurs van Berlage",
      venueCity: "Amsterdam",
      venueCountry: "Netherlands",
    );
    eventSearch = EventSearch(events);
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await http.get(Uri.parse(
        'https://sde-007.api.assignment.theinternetfolks.works/v1/event'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> eventList = jsonData['content']['data'];
      setState(() {
        events =
            eventList.map((eventJson) => Event.fromJson(eventJson)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> fetchEventById(int id) async {
    try {
      final response = await http.get(Uri.parse(
          'https://sde-007.api.assignment.theinternetfolks.works/v1/event/$id'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final selected = Event.fromJson(jsonData['content']['data']);
        setState(() {
          selectedEvent = selected;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetail(event: selectedEvent),
          ),
        );
      } else {
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['error']['message'];

        print('Error fetching event: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching event: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: EventSearch(events));
            },
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  height: 118,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      title: SizedBox(
                        height: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 4),
                              child: Text(
                                DateFormat('EEE, MMM d ~ hh:mm a')
                                    .format(events[index].dateTime),
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              child: Text(
                                events[index].title,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: SizedBox(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.location_on, size: 16),
                            Flexible(
                              child: Text(
                                '${events[index].venueName}, ${events[index].venueCity}, ${events[index].venueCountry}',
                                style: TextStyle(fontSize: 11),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      leading: FutureBuilder(
                        future: loadImage(events[index].bannerImage),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return Image.asset('assets/placeholder_image.png');
                          } else {
                            return Container(
                              width: 100,
                              height: 118,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.cover,
                                    snapshot.data as Uint8List),
                              ),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        fetchEventById(events[index].id);
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 5),
            ),
    );
  }
}

class EventSearch extends SearchDelegate<Event> {
  final List<Event> events;

  EventSearch(this.events);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = events
        .where((event) =>
            event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestion = suggestionList[index];
        return ListTile(
          leading: SizedBox(
              height: 50, child: Image.network(suggestion.bannerImage)),
          title: SizedBox(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    DateFormat('EEE, MMM d ~ hh:mm a')
                        .format(suggestion.dateTime),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  child: Text(
                    suggestion.title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          subtitle: SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.location_on, size: 16),
                Flexible(
                  child: Text(
                    '${suggestion.venueName}, ${suggestion.venueCity}, $suggestion.venueCountry}',
                    style: TextStyle(fontSize: 11),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetail(event: suggestion),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? events
        : events
            .where((event) =>
                event.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestion = suggestionList[index];
        return ListTile(
          leading: SizedBox(
              height: 50, child: Image.network(suggestion.bannerImage)),
          title: SizedBox(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    DateFormat('EEE, MMM d ~ hh:mm a')
                        .format(suggestion.dateTime),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  child: Text(
                    suggestion.title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          subtitle: SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.location_on, size: 16),
                Flexible(
                  child: Text(
                    '${suggestion.venueName}, ${suggestion.venueCity}, $suggestion.venueCountry}',
                    style: TextStyle(fontSize: 11),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetail(event: suggestion),
              ),
            );
          },
        );
      },
    );
  }
}
