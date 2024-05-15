import 'package:calender_app/event.dart';
import 'package:calender_app/notificationservice.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  TimeOfDay? selectedTime = TimeOfDay.now();
  DateTime selectedDateTime = DateTime.now();
  int secondsDifferencefor_15min = 0;
  int secondsDifferencefor_1h = 0;
  int secondsDifferencefor_1d = 0;
  int secondsDifferencefor_ontime = 0;
  int id = 0;
  List<String> stringList = [];

  final TextEditingController _eventController = TextEditingController();
  Map<DateTime, List<Event>> events = {};

  Future<void> _loadStringList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      stringList = prefs.getStringList('myStringList') ?? [];
    });
  }

  Future<void> _saveStringList(List<String> list) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('myStringList', list);
  }

  void addList() {
    setState(() {
      stringList.add(
          '${selectedDateTime.year}/${selectedDateTime.month}/${selectedDateTime.day} | ${selectedDateTime.hour}:${selectedDateTime.minute} - ${_eventController.text}');
      _saveStringList(stringList);
    });
  }

  void _onDaySelected(DateTime day, DateTime focusDay) {
    setState(() {
      selectedDateTime = day;
    });
  }

  LocalNotifications notificationService = LocalNotifications();

  @override
  void initState() {
    _loadStringList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xibet Calender',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 15, 3, 66),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Event Creator'),
                content: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const Text(
                        'Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _eventController,
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10)),
                      ElevatedButton(
                        onPressed: () async {
                          selectedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime!,
                            initialEntryMode: TimePickerEntryMode.dial,
                          );

                          if (selectedTime != null) {
                            setState(() {
                              id++;

                              selectedDateTime = DateTime(
                                selectedDateTime.year,
                                selectedDateTime.month,
                                selectedDateTime.day,
                                selectedTime!.hour,
                                selectedTime!.minute,
                              );

                              DateTime now = DateTime.now();
                              // Calculate the difference in seconds
                              Duration difference =
                                  selectedDateTime.difference(now);
                              // Get the difference in seconds
                              secondsDifferencefor_15min =
                                  difference.inSeconds - (15 * 60);
                              secondsDifferencefor_1h =
                                  difference.inSeconds - (60 * 60);
                              secondsDifferencefor_1d =
                                  difference.inSeconds - (60 * 60 * 24);
                              secondsDifferencefor_ontime =
                                  difference.inSeconds;
                            });
                          }
                        },
                        child: const Text('Choose Time'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          LocalNotifications.showScheduleNotification(
                            id: id,
                            title: "Xibet",
                            body: _eventController.text,
                            duration: secondsDifferencefor_15min <= 0
                                ? secondsDifferencefor_15min = 0
                                : secondsDifferencefor_15min,
                            payload: "This is schedule data",
                          );
                          addList();
                          _eventController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('15 mins before'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          LocalNotifications.showScheduleNotification(
                            id: id,
                            title: "Xibet",
                            body: _eventController.text,
                            duration: secondsDifferencefor_1h <= 0
                                ? secondsDifferencefor_1h = 0
                                : secondsDifferencefor_1h,
                            payload: "This is schedule data",
                          );
                          addList();
                          _eventController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('1 hour before'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          LocalNotifications.showScheduleNotification(
                            id: id,
                            title: "Xibet",
                            body: _eventController.text,
                            duration: secondsDifferencefor_1d <= 0
                                ? secondsDifferencefor_1d = 0
                                : secondsDifferencefor_1d,
                            payload: "This is schedule data",
                          );
                          addList();
                          _eventController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('1 day before'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          LocalNotifications.showScheduleNotification(
                            id: id,
                            title: "Xibet",
                            body: _eventController.text,
                            duration: secondsDifferencefor_ontime,
                            payload: "This is schedule data",
                          );
                          addList();
                          _eventController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('On-time'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        child: const Text('+'),
      ),
      body: ListView(
        children: [
          Container(
            child: TableCalendar(
              rowHeight: 43,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, selectedDateTime),
              focusedDay: selectedDateTime,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 10, 16),
              onDaySelected: _onDaySelected,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stringList.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(), // Unique key for each item
                onDismissed: (direction) {
                  setState(() {
                    stringList.removeAt(index); // Remove the item from the list
                    LocalNotifications.cancel(index + 1);
                    _saveStringList(stringList); // Save the updated list
                  });
                },
                background: Container(
                  color: Colors.red,
                  child: const ListTile(
                    leading: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(stringList[index]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
