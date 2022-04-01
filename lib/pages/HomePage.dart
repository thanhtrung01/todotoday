// ignore_for_file: file_names

import 'dart:io';
import 'package:get/get.dart';
import 'package:todotoday/screen/list_note.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todotoday/Custom/TodoCard.dart';
import 'package:todotoday/services/Auth_Service.dart';
import 'package:todotoday/pages/AddTodo.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'package:todotoday/pages/Profile.dart';
import 'package:todotoday/pages/view_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todotoday/pages/SignUpPage.dart';
import 'package:todotoday/services/theme_service.dart';

import '../screen/theme.dart';
import '../screen/widget/button.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
// import 'AddTodo.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  PickedFile _imageFile;
  AuthClass authClass = AuthClass();
  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection("Todo").snapshots();

  List<Select> selected = [];

  var notifyHelper;
  @override
  void initState() {
    super.initState();

    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(), //trang tiêu đề
      body: _addToBody(), //trang nội dung
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        items: [
          BottomNavigationBarItem(
            label: "",
            icon: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => ListNote()));
              },
              child: Icon(
                Icons.edit_calendar_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => AddTodoPage()));
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Color.fromARGB(255, 132, 24, 219),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => Profile()));
              },
              child: Icon(
                Icons.settings,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getTimeFromUser({bool isStartTime}) async {
    var _pickedTime = await _showTimePicker(isStartTime: isStartTime);
    //String _formatedTime = _pickedTime.format(context);
    String _formatedTime = _pickedTime.format(context);

    if (_pickedTime == null) {
      debugPrint("Time canceled");
    } else if (isStartTime) {
      setState(() {
        _startTime = _formatedTime;
      });
    }
  }

  _showTimePicker({bool isStartTime}) {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: isStartTime ??
          TimeOfDay(
            hour: int.parse(_startTime.split(":")[0]),
            minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
          ),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      // pembatas antara appbar dan main screen
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: "Today' Schedule",
            body:
                Get.isDarkMode ? "Activated LightTheme" : "Activated DarkTheme",
          );
          notifyHelper.scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        Container(
          height: 100,
          margin: const EdgeInsets.only(right: 50, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Today' Schedule",
                style: headingStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.logout,
            color: Get.isDarkMode ? Colors.white : Colors.black,
            size: 28,
          ),
        ),
        SizedBox(
          width: 5,
        ),
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(
        left: 0,
        right: 150,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMd().format(DateTime.now()),
            style: subHeadingStyle,
          ),
        ],
      ),
    );
  }

  _addToBody() {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            IconData iconData;
            Color iconColor;
            Map<String, dynamic> document =
                snapshot.data.docs[index].data() as Map<String, dynamic>;
            switch (document["Category"]) {
              case "Work":
                iconData = Icons.work_off_rounded;
                iconColor = Colors.yellow;
                break;
              case "WorkOut":
                iconData = Icons.alarm;
                iconColor = Colors.teal;
                break;
              case "Food":
                iconData = Icons.local_grocery_store;
                iconColor = Colors.deepPurpleAccent;
                break;
              case "Design":
                iconData = Icons.design_services_sharp;
                iconColor = Colors.green;
                break;
              case "Music":
                iconData = Icons.audiotrack;
                iconColor = Colors.pinkAccent;
                break;
              default:
                iconData = Icons.run_circle_outlined;
                iconColor = Colors.red;
            }
            selected.add(
              Select(id: snapshot.data.docs[index].id, checkValue: false),
            );
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => ViewData(
                        document: document, id: snapshot.data.docs[index].id),
                  ),
                );
              },
              child: TodoCard(
                title: document["title"] ?? "Hello world",
                check: selected[index].checkValue,
                iconBgColor: Colors.white,
                iconColor: iconColor,
                iconData: iconData,
                time: document["startTime"],
                index: index,
                onChange: onChange,
              ),
            );
          },
        );
      },
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.getImage(
      source: source,
    );
    setState(() {
      _imageFile = pickedFile;
    });
  }

  void onChange(int index) {
    setState(() {
      selected[index].checkValue = !selected[index].checkValue;
    });
  }

  DateTime date;
  String getText() {
    DateTime now = DateTime.now();
    // ignore: avoid_print
    print(now.hour.toString() +
        ":" +
        now.minute.toString() +
        ":" +
        now.second.toString());
  }
}

class Select {
  String id;
  bool checkValue = false;
  Select({
    this.id,
    this.checkValue,
  });
}
