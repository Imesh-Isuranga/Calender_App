import 'package:calender_app/event.dart';
import 'package:calender_app/notificationservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime selectedHoliday = DateTime.now();
  int secondsDifferencefor_15min = 0;
  int secondsDifferencefor_1h = 0;
  int secondsDifferencefor_1d = 0;
  int secondsDifferencefor_ontime = 0;
  int id = 0;
  List<String> stringList = [];
  List<String> dateString = [];
  List<String> timeString = [];
  List<String> dateStringHolidays = [];
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("HH:mm");
  final TextEditingController _eventController = TextEditingController();
  Map<DateTime, List<Event>> events = {};

  Future<void> _loadStringList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      stringList = prefs.getStringList('myStringList') ?? [];
      dateString = prefs.getStringList('dateString') ?? [];
      timeString = prefs.getStringList('timeString') ?? [];
      dateStringHolidays = prefs.getStringList('dateStringHolidays') ?? [];
    });

    checkNotified();
  }

  Future<void> _saveHolidayList(List<String> holList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('dateStringHolidays', holList);
  }

  Future<void> _saveStringList(
      List<String> list, List<String> dateSave, List<String> timeSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('myStringList', list);
    prefs.setStringList('dateString', dateSave);
    prefs.setStringList('timeString', timeSave);
  }

  Future<void> _saveStringListOnly(List<String> list) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('myStringList', list);
  }

  void addList(String label) {
    String temp = _eventController.text;
    setState(() {
      if (temp.trim().isEmpty) {
        temp = 'Task';
      }
      DateTime dateTime = selectedDateTime;
      String date = dateFormat.format(dateTime);
      String time = timeFormat.format(dateTime);
      stringList.add('$date | $time - ${temp} - $label');
      dateString.add(date);
      timeString.add(time);
      _saveStringList(stringList, dateString, timeString);
    });
  }

  void checkNotified() {
    DateTime now = DateTime.now();
    List<String> copyDateString = List.from(dateString);
    int i = -1;
    for (var date in copyDateString) {
      DateTime day = DateTime.parse(date);

      String nowDate = dateFormat.format(now);
      DateTime nowDate1 = DateTime.parse(nowDate);
      i++;
      if (nowDate1.isAfter(day)) {
        _removeItemFromList(i);
        i--;
      } else if (nowDate1.isAtSameMomentAs(day)) {
        DateTime time1 = timeFormat.parse(timeString[i]);
        if (now.hour > (time1.hour)) {
          _removeItemFromList(i);
          i--;
          _saveStringList(stringList, dateString, timeString);
        } else if (now.hour == (time1.hour) && now.minute > (time1.minute)) {
          _removeItemFromList(i);
          i--;
          _saveStringList(stringList, dateString, timeString);
        } else {}
      }
    }
  }

  void _removeItemFromList(int i) {
    stringList.removeAt(i);
    dateString.removeAt(i);
    timeString.removeAt(i);
  }

  void _onDaySelected(DateTime day, DateTime focusDay) {
    setState(() {
      selectedDateTime = day;
    });
  }

  void _calculateDif() {
    setState(() {
      DateTime now = DateTime.now();
      // Calculate the difference in seconds
      Duration difference = selectedDateTime.difference(now);
      // Get the difference in seconds
      secondsDifferencefor_15min = difference.inSeconds - (15 * 60);
      secondsDifferencefor_1h = difference.inSeconds - (60 * 60);
      secondsDifferencefor_1d = difference.inSeconds - (60 * 60 * 24);
      secondsDifferencefor_ontime = difference.inSeconds;
    });
  }

  void showHolidaysDays() {
    List<String> copydateStringHolidays = List.from(dateStringHolidays);
    for (var holDays in copydateStringHolidays) {
      DateTime day = DateTime.parse(holDays);
    }
  }

  bool isHoliday(DateTime day) {
    // Convert holiday dates from strings to DateTime objects
    List<DateTime> holidayDates = dateStringHolidays
        .map((dateString) => DateTime.parse(dateString))
        .toList();

    // Check if the given day is in the list of holiday dates
    return holidayDates.any((holidayDate) => isSameDay(holidayDate, day));
  }

  LocalNotifications notificationService = LocalNotifications();

  @override
  void initState() {
    //stringList.clear();
    //dateString.clear();
    //timeString.clear();
    //_saveStringList(stringList, dateString, timeString);
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
        backgroundColor: const Color.fromARGB(255, 9, 6, 94),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 162, 19, 19),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                content: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const Text(
                        'Task',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
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
                            });
                            _calculateDif();
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
                            duration: secondsDifferencefor_15min,
                            payload: "This is schedule data",
                          );
                          if (secondsDifferencefor_15min > 5) {
                            addList('15 mins before');
                            checkNotified();
                          }
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
                            duration: secondsDifferencefor_1h,
                            payload: "This is schedule data",
                          );
                          if (secondsDifferencefor_1h > 5) {
                            addList('1 hour before');
                            checkNotified();
                          }
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
                            duration: secondsDifferencefor_1d,
                            payload: "This is schedule data",
                          );
                          if (secondsDifferencefor_1d > 5) {
                            addList('1 day before');
                            checkNotified();
                          }
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
                          addList('On-time');
                          checkNotified();
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
        child: const Text(
          '+',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
      ),
      body: ListView(
        children: [
          Container(
            child: TableCalendar(
              rowHeight: 43,
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, selectedDateTime),
              focusedDay: selectedDateTime,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 10, 16),
              onDaySelected: _onDaySelected,
              holidayPredicate: isHoliday,
            ),
          ),
          Container(
            child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        scrollable: true,
                        content: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(children: [
                            const Text(
                              'Add Holidays',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                selectedHoliday = (await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2010),
                                    lastDate: DateTime(2030)))!;

                                setState(() {
                                  DateFormat dateFormat = DateFormat(
                                      "yyyy-MM-dd"); // how you want it to be formatted
                                  String holDate = dateFormat
                                      .format(selectedHoliday); // format it
                                  dateStringHolidays.add(holDate);
                                  _saveHolidayList(dateStringHolidays);
                                });
                              },
                              child: const Text('Choose Date'),
                            )
                          ]),
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  'Holidays',
                  style: TextStyle(color: Color.fromARGB(255, 39, 5, 106)),
                )),
          ),
          const SizedBox(
            height: 20, // Adjust the height according to your preference
          ),
          const Text(
            'Sheduled Tasks',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromARGB(255, 4, 19, 85),
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(
            height: 20, // Adjust the height according to your preference
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
                    dateString.removeAt(index);
                    timeString.removeAt(index);
                    LocalNotifications.cancel(index + 1);
                    _saveStringListOnly(stringList); // Save the updated list
                  });
                },
                background: Container(
                  color: Colors.red,
                  child: const ListTile(
                    leading: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                child: Card(
                  color: const Color.fromARGB(255, 9, 6, 94),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      stringList[index],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
