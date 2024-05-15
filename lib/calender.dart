import 'package:calender_app/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime today = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay? timeOfDay;

  TextEditingController _eventController = TextEditingController();
  Map<DateTime, List<Event>> events = {};

  void _onDaySelected(DateTime day, DateTime focusDay) {
    setState(() {
      today = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xibet Calender'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              scrollable: true,
              title: Text('Event Creator'),
              content: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    TextField(
                      controller: _eventController,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              initialEntryMode: TimePickerEntryMode.dial);
                        },
                        child: Text('Choose Time'))
                  ],
                ),
              ),
              actions: [
                ElevatedButton(onPressed: () {
                  
                }, child: Text('Submit'))
              ],
            );
          },
        );
      }),
      body: Container(
          child: Column(
        children: [
          const Text('Xibet'),
          Container(
            child: TableCalendar(
              rowHeight: 43,
              headerStyle:
                  HeaderStyle(formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 10, 16),
              onDaySelected: _onDaySelected,
            ),
          ),
        ],
      )),
    );
  }
}
