import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

var times = [
  ["8:00", "8:40"],
  ["8:50", "9:30"],
  ["9:40", "10:20"],
  ["10:30", "11:10"],
  ["11:20", "12:00"],
  ["14:00", "14:40"],
  ["15:50", "14:30"],
  ["14:10","16:50"],
  ["16:30","17:10"],
  ["6:50","8:30"],
  ["8:45","10:00"]
]; //"[Start HH:MM,End HH:MM]"

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

int durationTo(DateTime target) {
  Duration diff = DateTime.now().difference(target);
  return diff.inSeconds;
}

bool inDateTimeRange(DateTime dateTime, DateTimeRange range) {
  return range.start.isBefore(dateTime) && range.end.isAfter(dateTime);
}

class _MyHomePageState extends State<MyHomePage> {
  double counter = 0;
  DateTimeRange? currentRange;
  late DateTime now;
  List<DateTimeRange> timeRanges = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    now = DateTime.now();
    for (var i in times) {
      timeRanges.add(DateTimeRange(
          start: DateTime(now.year, now.month, now.day,
              int.parse(i[0].split(":")[0]), int.parse(i[0].split(":")[1])),
          end: DateTime(now.year, now.month, now.day,
              int.parse(i[1].split(":")[0]), int.parse(i[1].split(":")[1]))));
    }
    Timer.periodic(
        Duration(microseconds: (Duration.millisecondsPerSecond).toInt()),
        (Timer t) => this.upadteTime());
    upadteTime();
  }

  upadteTime() {
    now = DateTime.now();
    List sortedRanges =
        timeRanges.where((element) => inDateTimeRange(now, element)).toList();

    sortedRanges.sort((range1, range2) => range1.end.compareTo(range2.end));
    setState(() {
      currentRange = sortedRanges.firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = 1;
    String text = "";
    Color indicatorColor = Colors.white;
    if (currentRange == null) {
      print(1);
      progressValue = 1;
      text = "已下课";
      indicatorColor = Colors.green;
    } else {
      progressValue = now.difference(currentRange!.start).inMinutes /
          currentRange!.duration.inMinutes;
      int restTime = currentRange!.end.difference(now).inMinutes;
      text = "距离下课${restTime}分钟";
      if (restTime < 1) {
        print(2);
        restTime = currentRange!.end.difference(now).inSeconds;
        progressValue = now.difference(currentRange!.start).inSeconds /
            currentRange!.duration.inSeconds;
        text = "距离下课${restTime}秒";
      }
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark().copyWith(primary: Colors.white)),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: WatchShape(
              builder: (BuildContext context, WearShape shape, Widget? child) {
                return child!;
              },
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Stack(children: [
                        SizedBox(
                          child: CircularProgressIndicator(
                              color: indicatorColor,
                              strokeWidth: 10,
                              value: progressValue),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Center(child: Text(text))
                      ])))),
        ),
      ),
    );
  }
}
