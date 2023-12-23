import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';

class EventDetail extends StatefulWidget {
  final Event event;
  static const routeName = '/event-detail';
  const EventDetail({required this.event});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.event.bannerImage,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 240,
                    child: ListView(
                      children: [
                        Card(
                          elevation: 0,
                          child: ListTile(
                            leading: Icon(Icons.mood_rounded),
                            title: Text("The Internet folks"),
                            subtitle: Text(
                              "Organizer",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 0,
                          child: ListTile(
                            leading: Icon(Icons.calendar_month),
                            title: Text(
                              DateFormat('d MMMM yyyy')
                                  .format(widget.event.dateTime),
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                            ),
                            subtitle: Text(
                              DateFormat('EEEE hh:mm a')
                                  .format(widget.event.dateTime),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 0,
                          child: ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text('${widget.event.venueName}'),
                            subtitle: Container(
                              height: 20,
                              child: Text(
                                ' ${widget.event.venueCity}, ${widget.event.venueCountry}',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${widget.event.title}',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      child: Text(
                        'About Event\n ${widget.event.description}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          label: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Book Now"),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
