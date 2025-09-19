import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student1/screens/bottom_nav/bottom_nav.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Event {
  String title;
  String description;
  DateTime Startdate;
  DateTime EndDate;

  Event(
      {required this.title,
      required this.description,
      required this.Startdate,
      required this.EndDate});

  // Factory method to create an Event from Firestore data
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      title: data['name'] ?? 'No Title',
      description: data['description'] ?? 'No description',
      Startdate: (data['StartDate'] != null)
          ? (data['StartDate'] as Timestamp).toDate()
          : DateTime.now(), // Default to current date if null
      EndDate: (data['EndDate'] != null)
          ? (data['EndDate'] as Timestamp).toDate()
          : DateTime.now(), // Default to current date if null
    );
  }
}

class AcademicScreen extends StatefulWidget {
  final String schoolId;
  final String phoneNumber;
  final String classNumber;
  final String section;
  final String registrationNumber;
  final String studentName;

  const AcademicScreen(
      {Key? key,
      required this.schoolId,
      required this.phoneNumber,
      required this.classNumber,
      required this.section,
      required this.studentName,
      required this.registrationNumber})
      : super(key: key);

  static String routeName = 'AcademicScreen';

  @override
  _AcademicScreenState createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  late String schoolId;
  late String phoneNumber;
  String classNumber = '';
  String registrationNumber = '';
  String studentName = '';
  String section = '';
  List<Event> events = [];
  DateTime _selectedDate = DateTime.now();
  int _selectedIndex = 2;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<DateTime, List<String>> _events = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        schoolId = args?['schoolId'] ?? widget.schoolId;
        studentName = args?['studentName'] ?? widget.studentName;
        phoneNumber = args?['phoneNumber'] ?? widget.phoneNumber;
        classNumber = args?['class'] ?? widget.classNumber;
        section = args?['section'] ?? widget.section;
        registrationNumber =
            args?['registrationNumber'] ?? widget.registrationNumber;
        _fetchEvents();
      });
    });
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PaperBox')
          .doc('schools')
          .collection(schoolId)
          .doc(schoolId)
          .collection('events')
          .get();

      setState(() {
        events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

        // Clear old events
        _events.clear();

        for (var event in events) {
          DateTime currentDate = DateTime(
              event.Startdate.year, event.Startdate.month, event.Startdate.day);
          DateTime endDate = DateTime(
              event.EndDate.year, event.EndDate.month, event.EndDate.day);

          while (!currentDate.isAfter(endDate)) {
            if (_events.containsKey(currentDate)) {
              _events[currentDate]!.add(event.title);
            } else {
              _events[currentDate] = [event.title];
            }
            currentDate = currentDate.add(Duration(days: 1));
          }
        }
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Event Details',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Title: ${event.title}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 10),
                  Text('Description: ${event.description}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 10),
                  Text(
                      'Start Date: ${DateFormat.yMMMd().format(event.Startdate)}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  SizedBox(height: 10),
                  Text('End Date: ${DateFormat.yMMMd().format(event.EndDate)}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String schoolId = args['schoolId'];
    final String phoneNumber = args['phoneNumber'];
    final String classNumber = args['class'] ?? '';
    final String section = args['section'] ?? '';
    final String studentName = args['studentName'] ?? '';
    final String registrationNumber = args['registratioNumber'] ?? '';

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        schoolId: schoolId,
        phoneNumber: phoneNumber,
        classNumber: classNumber,
        section: section,
        registrationNumber: registrationNumber,
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          //  Makes the content scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = _selectedDay;
                    });
                  },
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon:
                        const Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon:
                        const Icon(Icons.chevron_right, color: Colors.black),
                    titleTextStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    weekendStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    cellMargin: const EdgeInsets.all(4),
                    todayDecoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: GoogleFonts.poppins(
                      fontSize: 14, //  Uniform font size
                      color: Colors.black,
                    ),
                    weekendTextStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    outsideTextStyle: GoogleFonts.poppins(
                      fontSize: 14, //  Match size for previous/next month dates
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // No Upcoming Events Message
              SizedBox(
                height: 100, // Prevents overflow

                child: ListView(
                  children: _buildEventList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventList() {
    List<Widget> eventWidgets = [];
    DateTime selectedDate =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    if (_events.containsKey(selectedDate)) {
      for (var eventTitle in _events[selectedDate]!) {
        // Find the full event object based on the title
        Event? event = events.firstWhere((e) => e.title == eventTitle,
            orElse: () => Event(
                title: eventTitle,
                description: "No description available",
                Startdate: selectedDate,
                EndDate: selectedDate));

        eventWidgets.add(
          GestureDetector(
            onTap: () {
              _showEventDetails(event);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      eventWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "No events today",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return eventWidgets;
  }
}
