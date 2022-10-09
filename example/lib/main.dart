import 'package:flutter/material.dart';
import 'package:almanac/almanac.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'almanac',
      home: MyHomePage(title: 'Kalendar Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: VerticalDateRangePicker(
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 10),
          highLightColor: Colors.redAccent,
          onEndDateChanged: (date) {},
          selectedColor: Colors.redAccent,
          onStartDateChanged: (date) {},
          splashColor: Colors.redAccent,
          presentDayStrokeColor: Colors.black,
          selectedTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          dayTextStyle: const TextStyle(
            color: Colors.black,
          ),
          initialDateRange: DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(
              const Duration(days: 3),
            ),
          ),

        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
