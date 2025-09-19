import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EventsList extends StatefulWidget {
  final String schoolId;
  final DateTime selectedDate;

  const EventsList(
      {Key? key, required this.schoolId, required this.selectedDate})
      : super(key: key);

  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  List<Event> events = [];
  final PageController _pageController =
      PageController(viewportFraction: 1.0); // Controls page scrolling

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    print('widget.schoolId: ${widget.schoolId}');
    print('widget.selectedDate: ${widget.selectedDate}');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(widget.schoolId)
          .doc(widget.schoolId)
          .collection('events')
          .get();

      setState(() {
        events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      });

      for (var event in events) {}
    } catch (e) {
      print(' Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime todayStart = DateTime(today.year, today.month, today.day);
    DateTime todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    List<Event> todayEvents = events.where((event) {
      return event.startDate
              .isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
          event.startDate.isBefore(todayEnd.add(const Duration(seconds: 1)));
    }).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 380,
          height: 70,
          child: PageView.builder(
            controller: _pageController,
            itemCount: todayEvents.isEmpty ? 1 : todayEvents.length,
            itemBuilder: (context, index) {
              if (todayEvents.isEmpty) {
                return _buildNoEventsCard();
              } else {
                return _buildEventCard(todayEvents[index]);
              }
            },
          ),
        ),
        const SizedBox(height: 5),
        SmoothPageIndicator(
          controller: _pageController,
          count: todayEvents.isEmpty ? 1 : todayEvents.length,
          effect: ExpandingDotsEffect(
            activeDotColor: Colors.red,
            dotColor: Colors.grey.shade400,
            dotHeight: 5,
            dotWidth: 5,
            expansionFactor: 2,
          ),
        ),
        
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: Colors.red, size: 18),
              const SizedBox(width: 5),
              Text(
                '${event.startDate.day}-${event.startDate.month}-${event.startDate.year}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Events Today',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  String title;
  DateTime startDate;
  String description;

  Event(
      {required this.title,
      required this.startDate,
      required this.description});

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parsedDate;
    try {
      // Convert Firestore Timestamp to Local Time
      parsedDate = (data['StartDate'] as Timestamp).toDate().toLocal();
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Event(
      title: data['name'] ?? 'No Title',
      startDate: parsedDate,
      description: data['description'] ?? 'No description',
    );
  }
}
